/**
 * LOG Prototype - Home Screen (#/home)
 * Today's business dashboard, weekly line chart, sales split donut,
 * weekly check banner, and recent activity ledger.
 */

(function (window) {
  'use strict';

  var NS = 'http://www.w3.org/2000/svg';

  function elSvg(name, attrs, parent) {
    var e = document.createElementNS(NS, name);
    for (var k in attrs) e.setAttribute(k, attrs[k]);
    if (parent) parent.appendChild(e);
    return e;
  }

  function render() {
    var store = window.LOG.store;
    var engine = window.LOG.engine;
    var router = window.LOG.router;
    var state = store ? store.getState() : {};
    var settings = state.settings || {};

    var el = document.createElement('div');
    el.className = 'screen home-screen';

    // Format current date
    var now = new Date();
    var options = { weekday: 'long', day: 'numeric', month: 'short', year: 'numeric' };
    var dateStr = now.toLocaleDateString('en-IN', options);

    el.innerHTML = [
      '<div class="top">',
      '  <div>',
      '    <h1 class="brand">LOG</h1>',
      '    <p class="shop" id="home-shop-name">' + (settings.shopNameTe ? settings.shopNameTe + ' · ' : '') + (settings.shopName || 'Sri Lakshmi Kirana') + '</p>',
      '  </div>',
      '  <button class="ib" id="home-settings-btn" aria-label="Settings">',
      '    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.8l.1.1a2 2 0 1 1-2.8 2.8l-.1-.1a1.7 1.7 0 0 0-1.8-.3 1.7 1.7 0 0 0-1 1.5V21a2 2 0 1 1-4 0v-.1a1.7 1.7 0 0 0-1.1-1.5 1.7 1.7 0 0 0-1.8.3l-.1.1a2 2 0 1 1-2.8-2.8l.1-.1a1.7 1.7 0 0 0 .3-1.8 1.7 1.7 0 0 0-1.5-1H3a2 2 0 1 1 0-4h.1a1.7 1.7 0 0 0 1.5-1.1 1.7 1.7 0 0 0-.3-1.8l-.1-.1a2 2 0 1 1 2.8-2.8l.1.1a1.7 1.7 0 0 0 1.8.3H9a1.7 1.7 0 0 0 1-1.5V3a2 2 0 1 1 4 0v.1a1.7 1.7 0 0 0 1 1.5 1.7 1.7 0 0 0 1.8-.3l.1-.1a2 2 0 1 1 2.8 2.8l-.1.1a1.7 1.7 0 0 0-.3 1.8V9a1.7 1.7 0 0 0 1.5 1H21a2 2 0 1 1 0 4h-.1a1.7 1.7 0 0 0-1.5 1z"/></svg>',
      '  </button>',
      '</div>',
      '<div class="scroll">',
      '  <div class="date" style="font:500 13px var(--f);color:var(--muted);letter-spacing:.02em;margin-top:2px">' + dateStr + '</div>',
      '  <div class="h" style="display:flex;align-items:baseline;gap:8px;flex-wrap:wrap;margin:2px 0 12px">',
      '    <h2 style="margin:0;font:700 22px/1.3 var(--f)">Today\'s business</h2><span style="font:500 17px var(--te);color:var(--muted)">ఈ రోజు వ్యాపారం</span>',
      '  </div>',
      '  <!-- Weekly Stock Check Banner (shown when due) -->',
      '  <div id="home-check-banner"></div>',
      '  <!-- Two Charts Side by Side -->',
      '  <div class="tiles" style="display:grid;grid-template-columns:1fr 1fr;gap:12px;cursor:pointer">',
      '    <section class="card tile" id="tile-revenue" aria-label="Weekly shop revenue" style="padding:14px 12px 12px;display:flex;flex-direction:column;gap:6px">',
      '      <div style="font:500 12px var(--f);color:var(--muted);letter-spacing:.03em;text-transform:uppercase">Weekly revenue<span style="display:block;text-transform:none;font:400 12px var(--te);letter-spacing:0">వారపు ఆదాయం</span></div>',
      '      <div class="big" id="home-lv" style="font:700 20px var(--f);font-variant-numeric:tabular-nums">₹0</div>',
      '      <svg id="home-line" viewBox="0 0 150 96" width="100%" role="img" aria-label="Line chart of revenue for the last seven days"></svg>',
      '    </section>',
      '    <section class="card tile" id="tile-donut" aria-label="Today\'s split" style="padding:14px 12px 12px;display:flex;flex-direction:column;gap:6px">',
      '      <div style="font:500 12px var(--f);color:var(--muted);letter-spacing:.03em;text-transform:uppercase">Today<span style="display:block;text-transform:none;font:400 12px var(--te);letter-spacing:0">ఈ రోజు</span></div>',
      '      <svg id="home-donut" viewBox="0 0 100 100" width="100%" style="max-width:104px;align-self:center" role="img" aria-label="Donut chart of today\'s credit, expenditure and profit"></svg>',
      '      <div class="legend" id="home-leg" style="display:flex;flex-direction:column;gap:3px;margin-top:2px"></div>',
      '    </section>',
      '  </div>',
      '  <!-- Recent Activity -->',
      '  <div class="sec" style="display:flex;align-items:center;justify-content:space-between;margin:22px 0 4px">',
      '    <h3 style="margin:0;font:500 18px var(--f)">Recent activity<span style="font:400 14px var(--te);color:var(--muted);margin-left:6px">ఇటీవలి</span></h3>',
      '    <button class="va" id="home-view-all" type="button" style="background:none;border:0;color:var(--accent);font:500 14px var(--f);cursor:pointer;height:40px;padding:0 8px;border-radius:20px;display:flex;align-items:center;gap:2px">View all<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="m9 6 6 6-6 6"/></svg></button>',
      '  </div>',
      '  <ul class="list" id="home-recent-list"></ul>',
      '</div>'
    ].join('\n');

    // Navigation events
    el.querySelector('#home-settings-btn').addEventListener('click', function () {
      router.navigate('settings');
    });

    el.querySelector('#home-view-all').addEventListener('click', function () {
      router.navigate('transactions');
    });

    el.querySelector('#tile-revenue').addEventListener('click', function () {
      router.navigate('dashboard');
    });

    el.querySelector('#tile-donut').addEventListener('click', function () {
      router.navigate('dashboard');
    });

    // Check banner logic
    var bannerContainer = el.querySelector('#home-check-banner');
    if (!state.weeklyCheckDone && settings.weeklyCheck && settings.weeklyCheck.on) {
      bannerContainer.innerHTML = [
        '<section class="grp check" style="background:var(--amber-tonal);padding:16px;margin-bottom:14px;border-radius:24px;display:flex;flex-direction:column;gap:10px" aria-label="Weekly stock check">',
        '  <div style="font:500 13px var(--f);letter-spacing:.04em;text-transform:uppercase;color:var(--amber)">Weekly check<span style="text-transform:none;letter-spacing:0;font-family:var(--te);margin-left:6px">వారం వారీ స్టాక్ తనిఖీ</span></div>',
        '  <p style="margin:0;font:500 18px/1.45 var(--te);color:var(--fg)">బియ్యం 12 కిలోలు ఉన్నాయా?<small style="display:block;font:400 13px var(--f);color:var(--muted)">Rice 12 kg undha?</small></p>',
        '  <div style="display:flex;gap:8px">',
        '    <button class="btn" id="hb-edit" type="button" style="flex:1;height:44px;font-size:15px">మార్చు · Edit</button>',
        '    <button class="btn fill" id="hb-yes" type="button" style="flex:1;height:44px;font-size:15px">అవును · Yes</button>',
        '  </div>',
        '</section>'
      ].join('\n');

      var editBtn = bannerContainer.querySelector('#hb-edit');
      var yesBtn = bannerContainer.querySelector('#hb-yes');
      if (editBtn) {
        editBtn.addEventListener('click', function () {
          router.navigate('recount');
        });
      }
      if (yesBtn) {
        yesBtn.addEventListener('click', function () {
          store.setWeeklyCheckDone(true);
          router.toast('Rice 12 kg confirmed · బియ్యం నిర్ధారించబడింది');
          render(); // re-render
        });
      }
    }

    // Line chart rendering
    var weekData = engine.getWeeklyRevenueSeries();
    var rev = weekData.rev;
    var days = weekData.labels;
    var totalRev = weekData.total;
    var lv = el.querySelector('#home-lv');
    var svg = el.querySelector('#home-line');
    var X0 = 10, X1 = 140, Y0 = 66, YH = 52, MAX = Math.max(6000, Math.ceil(Math.max.apply(null, rev) / 1000) * 1000);

    function X(i) { return X0 + i * (X1 - X0) / 6; }
    function Y(v) { return Y0 - (v / MAX) * YH; }

    [0, Math.round(MAX / 2), MAX].forEach(function (g) {
      elSvg('line', { x1: X0 - 4, x2: X1 + 6, y1: Y(g), y2: Y(g), stroke: 'var(--grid)', 'stroke-width': 1 }, svg);
    });
    elSvg('text', { x: X0 - 4, y: Y(MAX) - 3, 'font-size': 8, fill: 'var(--muted)' }, svg).textContent = '₹' + Math.round(MAX / 1000) + 'k';
    elSvg('text', { x: X0 - 4, y: Y(Math.round(MAX / 2)) - 3, 'font-size': 8, fill: 'var(--muted)' }, svg).textContent = '₹' + Math.round(MAX / 2000) + 'k';

    var d = 'M' + rev.map(function (v, i) { return X(i) + ' ' + Y(v); }).join(' L');
    var defs = elSvg('defs', {}, svg);
    var gr = elSvg('linearGradient', { id: 'home-ag', x1: 0, y1: 0, x2: 0, y2: 1 }, defs);
    elSvg('stop', { offset: '0', 'stop-color': 'var(--accent)', 'stop-opacity': 0.22 }, gr);
    elSvg('stop', { offset: '1', 'stop-color': 'var(--accent)', 'stop-opacity': 0 }, gr);

    elSvg('path', { d: d + ' L' + X(6) + ' ' + Y0 + ' L' + X(0) + ' ' + Y0 + 'Z', fill: 'url(#home-ag)' }, svg);
    elSvg('path', { d: d, fill: 'none', stroke: 'var(--accent)', 'stroke-width': 2, 'stroke-linejoin': 'round', 'stroke-linecap': 'round' }, svg);

    var cur = elSvg('line', { y1: 6, y2: Y0, stroke: 'var(--muted)', 'stroke-width': 1, 'stroke-dasharray': '2 2', opacity: 0 }, svg);
    var dot = elSvg('circle', { r: 4, fill: 'var(--accent)', stroke: 'var(--card)', 'stroke-width': 2 }, svg);

    days.forEach(function (l, i) {
      elSvg('text', { x: X(i), y: 82, 'font-size': 9, 'text-anchor': 'middle', fill: 'var(--muted)' }, svg).textContent = l;
    });

    var dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    function sel(i) {
      dot.setAttribute('cx', X(i));
      dot.setAttribute('cy', Y(rev[i]));
      cur.setAttribute('x1', X(i));
      cur.setAttribute('x2', X(i));
      cur.setAttribute('opacity', 1);
      lv.innerHTML = engine.inr(rev[i]) + '<small style="font:400 11px var(--f);color:var(--muted);margin-left:4px">' + dayNames[i] + '</small>';
    }

    function resetLine() {
      cur.setAttribute('opacity', 0);
      dot.setAttribute('cx', X(6));
      dot.setAttribute('cy', Y(rev[6]));
      lv.innerHTML = engine.inr(totalRev) + '<small style="font:400 11px var(--f);color:var(--muted);margin-left:4px">7 days</small>';
    }

    rev.forEach(function (v, i) {
      var r = elSvg('rect', { x: X(i) - 9, y: 0, width: 18, height: 90, class: 'hit' }, svg);
      r.addEventListener('mouseenter', function (e) { e.stopPropagation(); sel(i); });
      r.addEventListener('click', function (e) { e.stopPropagation(); sel(i); });
      r.addEventListener('mouseleave', function () { resetLine(); });
    });
    resetLine();

    // Donut chart rendering
    var todayStats = engine.getTodayStats();
    var parts = [
      { n: 'Credit', te: 'ఉధార్', v: todayStats.credit, c: 'var(--c-credit)' },
      { n: 'Expenditure', te: 'ఖర్చు', v: todayStats.exp, c: 'var(--c-exp)' },
      { n: 'Profit', te: 'లాభం', v: todayStats.profit, c: 'var(--c-profit)' }
    ];

    var sum = parts.reduce(function (a, p) { return a + p.v; }, 0) || 1;
    var C = 2 * Math.PI * 38;
    var off = 0;
    var ds = el.querySelector('#home-donut');
    var leg = el.querySelector('#home-leg');

    elSvg('circle', { cx: 50, cy: 50, r: 38, fill: 'none', stroke: 'var(--grid)', 'stroke-width': 12 }, ds);

    parts.forEach(function (p) {
      var len = (p.v / sum) * C;
      if (len > 0) {
        elSvg('circle', {
          cx: 50, cy: 50, r: 38, fill: 'none', stroke: p.c, 'stroke-width': 12,
          'stroke-dasharray': Math.max(0, len - 3) + ' ' + (C - len + 3),
          'stroke-dashoffset': -off,
          transform: 'rotate(-90 50 50)'
        }, ds);
      }
      off += len;

      var dRow = document.createElement('div');
      dRow.style.cssText = 'display:flex;align-items:center;gap:6px;font-size:12px;min-width:0';
      dRow.innerHTML = '<i style="width:8px;height:8px;border-radius:50%;flex:none;background:' + p.c + '"></i>' +
        '<em style="font-style:normal;color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + p.n + '</em>' +
        '<b style="margin-left:auto;font-weight:500;font-variant-numeric:tabular-nums">' + engine.inr(p.v) + '</b>';
      leg.appendChild(dRow);
    });

    elSvg('text', { x: 50, y: 48, 'font-size': 8, 'text-anchor': 'middle', fill: 'var(--muted)' }, ds).textContent = 'Sales';
    var tSum = elSvg('text', { x: 50, y: 62, 'font-size': 13, 'font-weight': 700, 'text-anchor': 'middle', fill: 'var(--fg)' }, ds);
    tSum.textContent = engine.inr(todayStats.sales);

    // Recent activity list
    var recentList = el.querySelector('#home-recent-list');
    var entries = store.getEntries().slice(0, 4);

    var ICONS = {
      credit: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 6v6l4 2M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0"/></svg>',
      cash: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2.5"/></svg>',
      pay: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12l7 7 7-7"/></svg>',
      exp: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M13 2 4 14h7l-1 8 9-12h-7z"/></svg>',
      stock: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 8 12 3 3 8v8l9 5 9-5zM3 8l9 5 9-5M12 13v8"/></svg>'
    };

    var TYPE_LABELS = {
      credit: 'ఉధార్ · Credit',
      cash: 'నగదు · Cash',
      pay: 'జమ · Received',
      exp: 'ఖర్చు · Expense',
      stock: 'స్టాక్ · Restock'
    };

    var TYPE_COLORS = {
      credit: 'var(--orange)',
      cash: 'var(--green)',
      pay: 'var(--blue)',
      exp: 'var(--red)',
      stock: 'var(--purple)'
    };

    entries.forEach(function (e) {
      var li = document.createElement('li');
      li.style.cssText = 'display:flex;gap:14px;align-items:center;padding:12px 0;border-bottom:1px solid var(--line);cursor:pointer';

      var title = '';
      if (e.customerId) {
        var cust = store.getCustomerById(e.customerId);
        title = cust ? cust.name : 'Customer';
      }
      if (e.itemId) {
        var it = store.getItemById(e.itemId);
        var itName = it ? it.name : 'Item';
        title = title ? title + ' · ' + itName : itName;
      }
      if (!title) {
        title = e.type === 'exp' ? 'Expense' : 'Transaction';
      }

      var color = TYPE_COLORS[e.type] || 'var(--accent)';
      li.innerHTML = [
        '<span style="width:40px;height:40px;border-radius:50%;display:grid;place-items:center;flex:none;background:color-mix(in srgb,' + color + ' 16%,transparent);color:' + color + '">',
        ICONS[e.type] || ICONS.cash,
        '</span>',
        '<div style="flex:1;min-width:0">',
        '  <div style="font-weight:500;font-size:15px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + title + (e.qty ? ' <em style="font-style:normal;color:var(--muted);font-weight:400">(' + e.qty + ' ' + (e.unit || '') + ')</em>' : '') + '</div>',
        '  <div style="font:italic 13px var(--te);color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">“' + (e.spokenText || '') + '”</div>',
        '</div>',
        '<div style="text-align:right;flex:none">',
        '  <div style="font:700 15px var(--f);font-variant-numeric:tabular-nums">' + engine.inr(e.amount) + '</div>',
        '  <div style="font:500 11px var(--te);color:' + color + ';margin-top:2px">' + (TYPE_LABELS[e.type] || e.type) + '</div>',
        '</div>'
      ].join('\n');

      // Tapping a recent entry opens Confirm screen in edit mode
      li.addEventListener('click', function () {
        router.navigate('confirm', { editEntryId: e.id });
      });

      recentList.appendChild(li);
    });

    return el;
  }

  window.LOG.screens.home = {
    render: render
  };
})(window);
