/**
 * LOG Prototype - Transactions Screen (#/transactions)
 * All entries ledger grouped by day, filters, expand/collapse row actions,
 * edit mode navigation, and delete with undo snackbar.
 */

(function (window) {
  'use strict';

  var TYPE_CHIPS = [
    ['all', 'All'],
    ['credit', 'Credit'],
    ['cash', 'Cash'],
    ['pay', 'Received'],
    ['stock', 'Restock'],
    ['exp', 'Expense']
  ];

  var PERIOD_CHIPS = [
    ['all', 'All time'],
    ['0', 'Today'],
    ['6', 'This week'],
    ['30', 'This month']
  ];

  var TYPE_META = {
    credit: { label: 'ఉధార్ · Credit', col: 'var(--orange)', icon: '<path d="M12 6v6l4 2M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0"/>' },
    cash: { label: 'నగదు · Cash', col: 'var(--green)', icon: '<rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2.5"/>' },
    pay: { label: 'జమ · Received', col: 'var(--blue)', icon: '<path d="M12 5v14M5 12l7 7 7-7"/>' },
    stock: { label: 'స్టాక్ · Restock', col: 'var(--purple)', icon: '<path d="M21 8 12 3 3 8v8l9 5 9-5zM3 8l9 5 9-5M12 13v8"/>' },
    exp: { label: 'ఖర్చు · Expense', col: 'var(--red)', icon: '<path d="M13 2 4 14h7l-1 8 9-12h-7z"/>' }
  };

  function formatDayHeader(dateObj) {
    var now = new Date();
    var a = new Date(dateObj.getFullYear(), dateObj.getMonth(), dateObj.getDate());
    var b = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    var diff = Math.floor((b - a) / (1000 * 60 * 60 * 24));

    var dayStr = dateObj.toLocaleDateString('en-IN', { weekday: 'short', day: 'numeric', month: 'short' });
    if (diff === 0) return 'Today · ' + dayStr;
    if (diff === 1) return 'Yesterday · ' + dayStr;
    return dayStr;
  }

  function render() {
    var store = window.LOG.store;
    var engine = window.LOG.engine;
    var router = window.LOG.router;

    var el = document.createElement('div');
    el.className = 'screen transactions-screen';

    el.innerHTML = [
      '<div class="top">',
      '  <button class="ib" id="tx-back" aria-label="Back" type="button"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg></button>',
      '  <h1>All transactions<span>లావాదేవీలు</span></h1>',
      '</div>',
      '<div style="padding:4px 16px 0;flex:none">',
      '  <div class="search">',
      '    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>',
      '    <input id="tx-q" type="search" placeholder="Search name or item · వెతకండి" aria-label="Search transactions">',
      '  </div>',
      '  <div class="chips" id="tx-type-chips" role="group" aria-label="Type" style="margin-top:10px"></div>',
      '  <div class="chips" id="tx-period-chips" role="group" aria-label="Period" style="margin-top:8px"></div>',
      '</div>',
      '<div id="tx-count" style="padding:10px 20px 4px;font:400 13px var(--f);color:var(--muted);flex:none"></div>',
      '<div class="scroll" id="tx-scroll"></div>'
    ].join('\n');

    el.querySelector('#tx-back').addEventListener('click', function () {
      router.back();
    });

    var filtType = 'all';
    var filtPeriod = 'all';
    var query = '';
    var openEntryId = null;
    var confirmDeleteId = null;

    var typeChipsBox = el.querySelector('#tx-type-chips');
    var periodChipsBox = el.querySelector('#tx-period-chips');
    var countEl = el.querySelector('#tx-count');
    var scrollBox = el.querySelector('#tx-scroll');
    var qInput = el.querySelector('#tx-q');

    // Build filter chips
    TYPE_CHIPS.forEach(function (tc) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'chip';
      btn.textContent = tc[1];
      btn.setAttribute('aria-pressed', tc[0] === filtType ? 'true' : 'false');
      btn.addEventListener('click', function () {
        filtType = tc[0];
        typeChipsBox.querySelectorAll('.chip').forEach(function (x) {
          x.setAttribute('aria-pressed', x === btn ? 'true' : 'false');
        });
        openEntryId = null;
        confirmDeleteId = null;
        renderList();
      });
      typeChipsBox.appendChild(btn);
    });

    PERIOD_CHIPS.forEach(function (pc) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'chip';
      btn.textContent = pc[1];
      btn.setAttribute('aria-pressed', pc[0] === filtPeriod ? 'true' : 'false');
      btn.addEventListener('click', function () {
        filtPeriod = pc[0];
        periodChipsBox.querySelectorAll('.chip').forEach(function (x) {
          x.setAttribute('aria-pressed', x === btn ? 'true' : 'false');
        });
        openEntryId = null;
        confirmDeleteId = null;
        renderList();
      });
      periodChipsBox.appendChild(btn);
    });

    function renderList() {
      var entries = store.getEntries();
      var now = new Date();

      var filtered = entries.filter(function (e) {
        if (filtType !== 'all' && e.type !== filtType) return false;
        if (filtPeriod !== 'all') {
          var d = new Date(e.createdAt);
          var daysAgo = Math.floor((now - d) / (1000 * 60 * 60 * 24));
          if (daysAgo > parseInt(filtPeriod, 10)) return false;
        }

        var s = query.toLowerCase();
        if (s) {
          var cust = e.customerId ? store.getCustomerById(e.customerId) : null;
          var item = e.itemId ? store.getItemById(e.itemId) : null;
          var nameMatch = cust && (cust.name.toLowerCase().indexOf(s) > -1 || (cust.nameTe && cust.nameTe.indexOf(query) > -1));
          var itemMatch = item && (item.name.toLowerCase().indexOf(s) > -1 || (item.nameTe && item.nameTe.indexOf(query) > -1));
          var spokenMatch = e.spokenText && (e.spokenText.toLowerCase().indexOf(s) > -1 || e.spokenText.indexOf(query) > -1);
          if (!nameMatch && !itemMatch && !spokenMatch) return false;
        }
        return true;
      });

      countEl.textContent = filtered.length + (filtered.length === 1 ? ' entry' : ' entries');
      scrollBox.innerHTML = '';

      if (!filtered.length) {
        var emptyEl = document.createElement('div');
        emptyEl.style.cssText = 'padding:40px 0;text-align:center;color:var(--muted);font-size:14px';
        emptyEl.textContent = 'No entries match.';
        scrollBox.appendChild(emptyEl);
        return;
      }

      // Group entries by calendar day
      var curDayHeader = null;
      var curUl = null;

      filtered.forEach(function (e) {
        var d = new Date(e.createdAt);
        var headerTitle = formatDayHeader(d);

        if (headerTitle !== curDayHeader) {
          curDayHeader = headerTitle;
          var gh = document.createElement('div');
          gh.className = 'gh';
          gh.textContent = headerTitle;
          scrollBox.appendChild(gh);

          curUl = document.createElement('ul');
          curUl.className = 'list';
          scrollBox.appendChild(curUl);
        }

        var cust = e.customerId ? store.getCustomerById(e.customerId) : null;
        var item = e.itemId ? store.getItemById(e.itemId) : null;
        var title = '';
        if (cust) title += cust.name;
        if (item) title += (title ? ' · ' : '') + item.name;
        if (!title) title = e.type === 'exp' ? 'Expense' : 'Entry';

        var meta = TYPE_META[e.type] || TYPE_META.cash;
        var isOpen = openEntryId === e.id;

        var li = document.createElement('li');
        li.style.cssText = 'border-bottom:1px solid var(--line)';

        var rowBtn = document.createElement('button');
        rowBtn.type = 'button';
        rowBtn.className = 'row';
        rowBtn.style.cssText = 'display:flex;gap:14px;align-items:center;padding:12px 4px;cursor:pointer;width:100%;border:0;background:none;color:inherit;text-align:left;font:inherit;border-radius:12px';

        rowBtn.innerHTML = [
          '<span style="width:40px;height:40px;border-radius:50%;display:grid;place-items:center;flex:none;background:color-mix(in srgb,' + meta.col + ' 16%,transparent);color:' + meta.col + '">',
          '  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' + meta.icon + '</svg>',
          '</span>',
          '<span style="flex:1;min-width:0">',
          '  <div style="font-weight:500;font-size:15px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + title + (e.qty ? ' <em style="font-style:normal;color:var(--muted);font-weight:400">(' + e.qty + ' ' + (e.unit || '') + ')</em>' : '') + '</div>',
          '  <div style="font:italic 13px var(--te);color:var(--muted);white-space:' + (isOpen ? 'normal' : 'nowrap') + ';overflow:hidden;text-overflow:ellipsis">“' + (e.spokenText || '') + '”</div>',
          '</span>',
          '<span style="text-align:right;flex:none">',
          '  <div style="font:700 15px var(--f);font-variant-numeric:tabular-nums">' + engine.inr(e.amount) + '</div>',
          '  <div style="font:500 11px var(--te);color:' + meta.col + ';margin-top:2px">' + meta.label + '</div>',
          '</span>'
        ].join('\n');

        rowBtn.addEventListener('click', function () {
          openEntryId = openEntryId === e.id ? null : e.id;
          confirmDeleteId = null;
          renderList();
        });
        li.appendChild(rowBtn);

        // Expanded action bar
        if (isOpen) {
          var actDiv = document.createElement('div');
          actDiv.style.cssText = 'display:flex;gap:8px;padding:0 4px 12px 58px;align-items:center';

          if (confirmDeleteId === e.id) {
            actDiv.innerHTML = [
              '<span style="font:500 14px var(--f);color:var(--red);margin-right:4px">Delete this entry?</span>',
              '<button class="ab" id="del-no" type="button" style="height:40px;padding:0 16px;border-radius:20px;border:1px solid var(--line);background:none;color:var(--fg);font:500 14px var(--f);cursor:pointer">Cancel</button>',
              '<button class="ab yes" id="del-yes" type="button" style="height:40px;padding:0 16px;border-radius:20px;border:0;background:var(--red);color:#fff;font:500 14px var(--f);cursor:pointer">Delete</button>'
            ].join('\n');

            actDiv.querySelector('#del-no').addEventListener('click', function () {
              confirmDeleteId = null;
              renderList();
            });

            actDiv.querySelector('#del-yes').addEventListener('click', function () {
              var delInfo = store.deleteEntry(e.id);
              openEntryId = null;
              confirmDeleteId = null;
              renderList();

              if (delInfo) {
                router.snack('Entry deleted', function () {
                  store.restoreEntry(delInfo.entry, delInfo.index);
                  router.toast('Entry restored · పునరుద్ధరించబడింది');
                  renderList();
                });
              }
            });
          } else {
            actDiv.innerHTML = [
              '<button class="ab" id="act-edit" type="button" style="height:40px;padding:0 16px;border-radius:20px;border:1px solid var(--line);background:none;color:var(--accent);font:500 14px var(--f);cursor:pointer;display:flex;align-items:center;gap:6px"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"/></svg>Edit · మార్చు</button>',
              '<button class="ab del" id="act-del" type="button" style="height:40px;padding:0 16px;border-radius:20px;border:1px solid var(--line);background:none;color:var(--red);font:500 14px var(--f);cursor:pointer;display:flex;align-items:center;gap:6px"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18M8 6V4h8v2M6 6l1 14h10l1-14"/></svg>Delete</button>'
            ].join('\n');

            actDiv.querySelector('#act-edit').addEventListener('click', function () {
              router.navigate('confirm', { editEntryId: e.id });
            });

            actDiv.querySelector('#act-del').addEventListener('click', function () {
              confirmDeleteId = e.id;
              renderList();
            });
          }

          li.appendChild(actDiv);
        }

        curUl.appendChild(li);
      });
    }

    qInput.addEventListener('input', function () {
      query = qInput.value.trim();
      openEntryId = null;
      confirmDeleteId = null;
      renderList();
    });

    renderList();
    return el;
  }

  window.LOG.screens.transactions = {
    render: render
  };
})(window);
