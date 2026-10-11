/**
 * LOG Prototype - Udhar Screen (#/udhar)
 * List of customers who owe money with live balance, overdue tracking, search, and sorting.
 */

(function (window) {
  'use strict';

  function whenText(d) {
    if (d === null) return 'No entries yet';
    if (d === 0) return 'Today';
    if (d === 1) return 'Yesterday';
    return d + ' days ago';
  }

  function render() {
    var store = window.LOG.store;
    var engine = window.LOG.engine;
    var router = window.LOG.router;

    var el = document.createElement('div');
    el.className = 'screen udhar-screen';

    var summary = engine.getUdharSummary();

    el.innerHTML = [
      '<div class="top">',
      '  <button class="ib" id="udhar-back" aria-label="Back" type="button"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg></button>',
      '  <h1>Udhar<span>ఉధార్</span></h1>',
      '</div>',
      '<div class="scroll">',
      '  <!-- Summary Panel -->',
      '  <section class="sum" style="background:var(--orange-tonal);border-radius:28px;padding:18px 20px;display:flex;flex-direction:column;gap:12px" aria-label="Total to collect">',
      '    <div style="font:500 13px var(--f);letter-spacing:.04em;text-transform:uppercase;color:var(--muted)">To collect<span style="font-family:var(--te);text-transform:none;letter-spacing:0;margin-left:6px">రావలసినది</span></div>',
      '    <div id="udhar-total" style="font:700 36px/1.1 var(--f);font-variant-numeric:tabular-nums;color:var(--fg)">' + engine.inr(summary.totalToCollect) + '</div>',
      '    <div style="display:flex;gap:20px;font-size:14px;color:var(--muted)">',
      '      <span><b id="udhar-cnt" style="color:var(--fg);font-weight:500">' + summary.customerCount + '</b> customers</span>',
      '      <span style="color:var(--red)"><b id="udhar-odc" style="color:var(--red);font-weight:500">' + summary.overdueCount + '</b> overdue</span>',
      '    </div>',
      '  </section>',
      '  <!-- Search Input -->',
      '  <div class="search" style="margin-top:14px">',
      '    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>',
      '    <input id="udhar-q" type="search" placeholder="Search customer · పేరు వెతకండి" aria-label="Search customer">',
      '  </div>',
      '  <!-- Filter Chips -->',
      '  <div class="chips" id="udhar-chips" role="group" aria-label="Filter" style="margin-top:12px">',
      '    <button class="chip" data-f="all" aria-pressed="true" type="button">All</button>',
      '    <button class="chip" data-f="od" aria-pressed="false" type="button">Overdue</button>',
      '    <button class="chip" data-f="recent" aria-pressed="false" type="button">This week</button>',
      '    <button class="chip" id="udhar-sort" aria-label="Sort order" type="button" style="margin-left:auto">Sort: Amount</button>',
      '  </div>',
      '  <!-- List -->',
      '  <ul class="list" id="udhar-list" style="margin-top:6px"></ul>',
      '</div>'
    ].join('\n');

    el.querySelector('#udhar-back').addEventListener('click', function () {
      router.back();
    });

    var filt = 'all';
    var byAmt = true;
    var query = '';

    var listEl = el.querySelector('#udhar-list');
    var qInput = el.querySelector('#udhar-q');
    var sortBtn = el.querySelector('#udhar-sort');

    function renderList() {
      var allCustomers = store.getCustomers();
      var data = [];

      allCustomers.forEach(function (c) {
        var bal = engine.getCustomerBalance(c.id);
        if (bal > 0) {
          var d = engine.getCustomerLastEntryDays(c.id);
          var isOd = engine.isCustomerOverdue(c.id);
          data.push({
            id: c.id,
            name: c.name,
            nameTe: c.nameTe,
            balance: bal,
            days: d !== null ? d : 999,
            overdue: isOd
          });
        }
      });

      var filtered = data.filter(function (c) {
        if (filt === 'od' && !c.overdue) return false;
        if (filt === 'recent' && c.days > 7) return false;
        var s = query.toLowerCase();
        return !s || c.name.toLowerCase().indexOf(s) > -1 || (c.nameTe && c.nameTe.indexOf(query) > -1);
      });

      filtered.sort(function (a, b) {
        return byAmt ? (b.balance - a.balance) : (a.days - b.days);
      });

      listEl.innerHTML = '';
      if (!filtered.length) {
        var emptyLi = document.createElement('li');
        emptyLi.style.cssText = 'padding:32px 0;text-align:center;color:var(--muted);font-size:14px';
        emptyLi.textContent = 'No customers match.';
        listEl.appendChild(emptyLi);
        return;
      }

      filtered.forEach(function (c) {
        var li = document.createElement('li');
        li.style.cssText = 'display:flex;align-items:center;gap:14px;padding:12px 4px;border-bottom:1px solid var(--line);cursor:pointer;border-radius:12px';

        var avColor = c.overdue ? 'var(--red)' : 'var(--accent)';
        var avBg = c.overdue ? 'var(--red-tonal)' : 'var(--accent-tonal)';
        var subText = c.overdue ?
          '<span style="color:var(--red);font-weight:500">Overdue · last entry ' + c.days + ' days ago</span>' :
          'Last entry ' + whenText(c.days);

        li.innerHTML = [
          '<span style="width:44px;height:44px;border-radius:50%;background:' + avBg + ';color:' + avColor + ';display:grid;place-items:center;font:500 18px var(--f);flex:none">' + c.name[0].toUpperCase() + '</span>',
          '<div style="flex:1;min-width:0">',
          '  <div style="font:500 16px var(--f);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + c.name + (c.nameTe ? '<span style="font:400 14px var(--te);color:var(--muted);margin-left:6px">' + c.nameTe + '</span>' : '') + '</div>',
          '  <div style="font-size:13px;color:var(--muted);margin-top:2px">' + subText + '</div>',
          '</div>',
          '<div style="font:700 17px var(--f);font-variant-numeric:tabular-nums;flex:none">' + engine.inr(c.balance) + '</div>'
        ].join('\n');

        li.addEventListener('click', function () {
          router.navigate('udhar-detail', { customerId: c.id });
        });

        listEl.appendChild(li);
      });
    }

    el.querySelectorAll('.chip[data-f]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        filt = btn.dataset.f;
        el.querySelectorAll('.chip[data-f]').forEach(function (x) {
          x.setAttribute('aria-pressed', x === btn ? 'true' : 'false');
        });
        renderList();
      });
    });

    sortBtn.addEventListener('click', function () {
      byAmt = !byAmt;
      sortBtn.textContent = 'Sort: ' + (byAmt ? 'Amount' : 'Recent');
      renderList();
    });

    qInput.addEventListener('input', function () {
      query = qInput.value.trim();
      renderList();
    });

    renderList();
    return el;
  }

  window.LOG.screens.udhar = {
    render: render
  };
})(window);
