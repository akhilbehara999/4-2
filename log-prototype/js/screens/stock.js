/**
 * LOG Prototype - Stock Screen (#/stock)
 * Inventory item list with days-left forecasting, 4 status filter cards,
 * search, and weekly recount banner.
 */

(function (window) {
  'use strict';

  var LABELS = {
    red: 'Low',
    amber: 'Getting low',
    green: 'Fine',
    grey: 'No data'
  };

  function render() {
    var store = window.LOG.store;
    var engine = window.LOG.engine;
    var router = window.LOG.router;
    var state = store ? store.getState() : {};
    var settings = state.settings || {};

    var el = document.createElement('div');
    el.className = 'screen stock-screen';

    var checkDue = !state.weeklyCheckDone && settings.weeklyCheck && settings.weeklyCheck.on;

    el.innerHTML = [
      '<div class="top">',
      '  <button class="ib" id="stk-back" aria-label="Back" type="button"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg></button>',
      '  <h1>Stock<span>స్టాక్</span></h1>',
      '</div>',
      '<div class="scroll">',
      '  <!-- Weekly stock check banner -->',
      '  <div id="stk-check-banner"></div>',
      '  <!-- 4 Status cards / filters -->',
      '  <div class="stats" id="stk-stats" role="group" aria-label="Filter by status" style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-top:4px"></div>',
      '  <!-- Search Input -->',
      '  <div class="search" style="margin-top:14px">',
      '    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>',
      '    <input id="stk-q" type="search" placeholder="Search item · వస్తువు వెతకండి" aria-label="Search item">',
      '  </div>',
      '  <!-- List -->',
      '  <ul class="list" id="stk-list" style="margin-top:8px"></ul>',
      '</div>'
    ].join('\n');

    el.querySelector('#stk-back').addEventListener('click', function () {
      router.back();
    });

    // Weekly check banner logic
    var bannerContainer = el.querySelector('#stk-check-banner');
    if (checkDue) {
      bannerContainer.innerHTML = [
        '<section class="grp check" style="background:var(--amber-tonal);padding:16px;margin-bottom:12px;border-radius:24px;display:flex;flex-direction:column;gap:10px" aria-label="Weekly stock check">',
        '  <div style="font:500 13px var(--f);letter-spacing:.04em;text-transform:uppercase;color:var(--amber)">Weekly check<span style="text-transform:none;letter-spacing:0;font-family:var(--te);margin-left:6px">వారం వారీ స్టాక్ తనిఖీ</span></div>',
        '  <p style="margin:0;font:500 18px/1.45 var(--te);color:var(--fg)">బియ్యం 12 కిలోలు ఉన్నాయా?<small style="display:block;font:400 13px var(--f);color:var(--muted)">Rice 12 kg undha?</small></p>',
        '  <div style="display:flex;gap:8px">',
        '    <button class="btn" id="stk-b-edit" type="button" style="flex:1;height:44px;font-size:15px">మార్చు · Edit</button>',
        '    <button class="btn fill" id="stk-b-yes" type="button" style="flex:1;height:44px;font-size:15px">అవును · Yes</button>',
        '  </div>',
        '</section>'
      ].join('\n');

      bannerContainer.querySelector('#stk-b-edit').addEventListener('click', function () {
        router.navigate('recount');
      });
      bannerContainer.querySelector('#stk-b-yes').addEventListener('click', function () {
        store.setWeeklyCheckDone(true);
        router.toast('Rice 12 kg confirmed · బియ్యం నిర్ధారించబడింది');
        render();
      });
    }

    var filt = 'all';
    var query = '';
    var statsContainer = el.querySelector('#stk-stats');
    var listEl = el.querySelector('#stk-list');
    var qInput = el.querySelector('#stk-q');

    // Build the 4 status cards
    var counts = engine.getStockSummaryCounts();
    ['red', 'amber', 'green', 'grey'].forEach(function (k) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'st s-' + k;
      btn.dataset.k = k;
      btn.setAttribute('aria-pressed', 'false');

      var bgVar = 'var(--' + k + '-tonal)';
      var fgVar = k === 'grey' ? 'var(--grey)' : 'var(--' + k + ')';

      btn.style.cssText = 'border:0;border-radius:16px;padding:10px 4px 8px;text-align:center;background:' + bgVar + ';color:' + fgVar + ';cursor:pointer;font:inherit;outline-offset:2px';
      btn.innerHTML = '<b style="display:block;font:700 22px/1.1 var(--f);font-variant-numeric:tabular-nums">' + (counts[k] || 0) + '</b><span style="font:500 12px var(--f)">' + LABELS[k] + '</span>';

      btn.addEventListener('click', function () {
        filt = filt === k ? 'all' : k;
        statsContainer.querySelectorAll('.st').forEach(function (x) {
          var isPressed = x.dataset.k === filt;
          x.setAttribute('aria-pressed', isPressed ? 'true' : 'false');
          x.style.boxShadow = isPressed ? 'inset 0 0 0 2px currentColor' : 'none';
        });
        renderItems();
      });

      statsContainer.appendChild(btn);
    });

    function renderItems() {
      var items = store.getItems();

      var data = items.map(function (it) {
        var st = engine.getItemStockStatus(it.id);
        return {
          id: it.id,
          name: it.name,
          nameTe: it.nameTe,
          qty: it.qty,
          unit: it.unit,
          status: st.status,
          daysLeft: st.daysLeft
        };
      });

      var filtered = data.filter(function (it) {
        if (filt !== 'all' && it.status !== filt) return false;
        var s = query.toLowerCase();
        return !s || it.name.toLowerCase().indexOf(s) > -1 || (it.nameTe && it.nameTe.indexOf(query) > -1);
      });

      listEl.innerHTML = '';
      if (!filtered.length) {
        var emptyLi = document.createElement('li');
        emptyLi.style.cssText = 'padding:32px 0;text-align:center;color:var(--muted);font-size:14px';
        emptyLi.textContent = 'No items match.';
        listEl.appendChild(emptyLi);
        return;
      }

      filtered.forEach(function (it) {
        var li = document.createElement('li');
        li.style.cssText = 'padding:12px 4px;border-bottom:1px solid var(--line);cursor:pointer;border-radius:12px';

        var dotColor = 'var(--' + (it.status === 'grey' ? 'grey' : (it.status === 'amber' ? 'amber-dot' : it.status)) + ')';
        var pct = it.daysLeft === null ? 0 : Math.max(6, Math.min(100, Math.round((it.daysLeft / 14) * 100)));
        var dlText = it.daysLeft === null ? 'No usage yet' : (it.daysLeft <= 1.2 ? '~1 day left' : '~' + Math.round(it.daysLeft) + ' days left');

        li.innerHTML = [
          '<div style="display:flex;align-items:center;gap:12px">',
          '  <span style="width:12px;height:12px;border-radius:50%;flex:none;background:' + dotColor + '"></span>',
          '  <div style="flex:1;min-width:0">',
          '    <div style="font:500 16px var(--f);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + it.name + (it.nameTe ? '<span style="font:400 14px var(--te);color:var(--muted);margin-left:6px">' + it.nameTe + '</span>' : '') + '</div>',
          '  </div>',
          '  <div style="font:700 16px var(--f);font-variant-numeric:tabular-nums;flex:none">' + it.qty + ' ' + it.unit + '</div>',
          '</div>',
          '<div style="display:flex;align-items:center;gap:10px;margin:8px 0 0 24px">',
          '  <div style="flex:1;height:6px;border-radius:3px;background:var(--track);overflow:hidden">',
          '    <i style="display:block;height:100%;border-radius:3px;background:' + dotColor + ';width:' + pct + '%"></i>',
          '  </div>',
          '  <div style="font:500 12px var(--f);color:' + dotColor + ';flex:none;min-width:84px;text-align:right">' + dlText + '</div>',
          '</div>'
        ].join('\n');

        li.addEventListener('click', function () {
          router.navigate('stock-detail', { itemId: it.id });
        });

        listEl.appendChild(li);
      });
    }

    qInput.addEventListener('input', function () {
      query = qInput.value.trim();
      renderItems();
    });

    renderItems();
    return el;
  }

  window.LOG.screens.stock = {
    render: render
  };
})(window);
