/**
 * LOG Prototype - Dashboard Screen (#/dashboard)
 * Financial metrics, SVG charts, Table toggle, and breakdowns for Today, Week, and Month.
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
    var engine = window.LOG.engine;
    var router = window.LOG.router;

    var el = document.createElement('div');
    el.className = 'screen dashboard-screen';

    var currentPeriod = 'week';
    var isTableView = false;

    el.innerHTML = [
      '<div class="top">',
      '  <button class="ib" id="dash-back" aria-label="Back" type="button"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg></button>',
      '  <h1>Dashboard<span>డాష్‌బోర్డ్</span></h1>',
      '</div>',
      '<div class="scroll" style="display:flex;flex-direction:column;gap:14px;padding-top:4px">',
      '  <!-- Period Selector -->',
      '  <div class="seg" id="dash-seg" role="group" aria-label="Period">',
      '    <button data-p="today" aria-pressed="false" type="button">Today · ఈ రోజు</button>',
      '    <button data-p="week" aria-pressed="true" type="button">Week · వారం</button>',
      '    <button data-p="month" aria-pressed="false" type="button">Month · నెల</button>',
      '  </div>',
      '  <!-- 4 Summary KPI Tiles -->',
      '  <div class="tiles" id="dash-tiles" style="display:grid;grid-template-columns:1fr 1fr;gap:10px"></div>',
      '  <!-- Revenue Chart Card with Table Toggle -->',
      '  <section class="card" aria-label="Revenue">',
      '    <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:8px;margin-bottom:8px">',
      '      <div><h2 id="dash-rt" style="margin:0;font:500 16px var(--f)">Revenue</h2><span style="display:block;font:400 13px var(--te);color:var(--muted)">ఆదాయం</span></div>',
      '      <button class="btn" id="dash-tgl" type="button" style="height:32px;padding:0 14px;font-size:13px;border-radius:16px">Table</button>',
      '    </div>',
      '    <div class="big" id="dash-rv" style="font:700 22px var(--f);font-variant-numeric:tabular-nums"></div>',
      '    <div id="dash-chart-box" style="margin-top:6px"></div>',
      '  </section>',
      '  <!-- Sales Split Donut -->',
      '  <section class="card" aria-label="Where sales went">',
      '    <div style="margin-bottom:10px"><h2 style="margin:0;font:500 16px var(--f)">Sales split</h2><span style="display:block;font:400 13px var(--te);color:var(--muted)">అమ్మకాల విభజన</span></div>',
      '    <div style="display:flex;align-items:center;gap:16px">',
      '      <svg id="dash-donut" viewBox="0 0 100 100" style="width:112px;flex:none" role="img" aria-label="Donut of credit, expenditure and profit"></svg>',
      '      <div id="dash-donut-leg" style="flex:1;min-width:0;display:flex;flex-direction:column;gap:8px"></div>',
      '    </div>',
      '  </section>',
      '  <!-- Top Selling Items -->',
      '  <section class="card" aria-label="Top selling items">',
      '    <div style="margin-bottom:12px"><h2 style="margin:0;font:500 16px var(--f)">Top selling items</h2><span style="display:block;font:400 13px var(--te);color:var(--muted)">ఎక్కువ అమ్ముడైనవి</span></div>',
      '    <ul class="rank" id="dash-top-items" style="display:flex;flex-direction:column;gap:12px;margin:0;padding:0;list-style:none"></ul>',
      '  </section>',
      '  <!-- Credit vs Cash Split -->',
      '  <section class="card" aria-label="Credit versus cash">',
      '    <div style="margin-bottom:8px"><h2 style="margin:0;font:500 16px var(--f)">Credit vs cash</h2><span style="display:block;font:400 13px var(--te);color:var(--muted)">ఉధార్ · నగదు</span></div>',
      '    <div class="split" id="dash-cc-bar" style="display:flex;gap:2px;height:20px;border-radius:10px;overflow:hidden;margin:6px 0 10px"></div>',
      '    <div id="dash-cc-leg" style="display:flex;flex-direction:column;gap:6px"></div>',
      '    <p id="dash-cc-note" style="font-size:13px;color:var(--muted);margin:10px 0 0"></p>',
      '  </section>',
      '  <!-- Biggest Expenses -->',
      '  <section class="card" aria-label="Biggest expenses">',
      '    <div style="margin-bottom:12px"><h2 style="margin:0;font:500 16px var(--f)">Biggest expenses</h2><span style="display:block;font:400 13px var(--te);color:var(--muted)">ప్రధాన ఖర్చులు</span></div>',
      '    <ul class="rank" id="dash-expenses" style="display:flex;flex-direction:column;gap:12px;margin:0;padding:0;list-style:none"></ul>',
      '  </section>',
      '</div>'
    ].join('\n');

    el.querySelector('#dash-back').addEventListener('click', function () {
      router.back();
    });

    var seg = el.querySelector('#dash-seg');
    var tilesBox = el.querySelector('#dash-tiles');
    var chartBox = el.querySelector('#dash-chart-box');
    var rv = el.querySelector('#dash-rv');
    var tglBtn = el.querySelector('#dash-tgl');
    var donutSvg = el.querySelector('#dash-donut');
    var donutLeg = el.querySelector('#dash-donut-leg');
    var topItemsList = el.querySelector('#dash-top-items');
    var ccBar = el.querySelector('#dash-cc-bar');
    var ccLeg = el.querySelector('#dash-cc-leg');
    var ccNote = el.querySelector('#dash-cc-note');
    var expensesList = el.querySelector('#dash-expenses');

    function drawLineOrTable(data) {
      chartBox.innerHTML = '';
      if (isTableView) {
        var tbl = document.createElement('table');
        tbl.style.cssText = 'width:100%;border-collapse:collapse;font-size:14px;font-variant-numeric:tabular-nums';
        tbl.innerHTML = '<thead><tr><th style="padding:8px 0;border-bottom:1px solid var(--line);text-align:left;color:var(--muted);font-size:12px">' + data.unit.split(' ')[0] + '</th><th style="padding:8px 0;border-bottom:1px solid var(--line);text-align:right;color:var(--muted);font-size:12px">Sales</th></tr></thead>';
        var tbody = document.createElement('tbody');
        data.revSeries.forEach(function (v, idx) {
          var tr = document.createElement('tr');
          tr.innerHTML = '<td style="padding:8px 0;border-bottom:1px solid var(--line);text-align:left">' + data.labels[idx] + '</td><td style="padding:8px 0;border-bottom:1px solid var(--line);text-align:right;font-weight:500">' + engine.inr(v) + '</td>';
          tbody.appendChild(tr);
        });
        tbl.appendChild(tbody);
        chartBox.appendChild(tbl);
        return;
      }

      var W = 300, H = 150, L = 34, R = 12, T = 10, B = 26;
      var n = data.revSeries.length;
      var mx = Math.max(1000, Math.ceil(Math.max.apply(null, data.revSeries) / 1000) * 1000);

      var svg = elSvg('svg', { viewBox: '0 0 ' + W + ' ' + H, width: '100%', role: 'img', 'aria-label': data.unit + ' line chart' }, chartBox);

      function X(i) { return L + i * (W - L - R) / (n - 1); }
      function Y(v) { return T + (1 - (v / mx)) * (H - T - B); }

      [0, 0.5, 1].forEach(function (f) {
        var v = mx * f;
        elSvg('line', { x1: L, x2: W - R, y1: Y(v), y2: Y(v), stroke: 'var(--grid)', 'stroke-width': 1 }, svg);
        elSvg('text', { x: L - 6, y: Y(v) + 3, 'font-size': 9, 'text-anchor': 'end', fill: 'var(--muted)' }, svg).textContent = v >= 1000 ? '₹' + Math.round(v / 1000) + 'k' : '₹0';
      });

      var p = 'M' + data.revSeries.map(function (v, i) { return X(i) + ' ' + Y(v); }).join(' L');
      var df = elSvg('defs', {}, svg);
      var g = elSvg('linearGradient', { id: 'dash-ag', x1: 0, y1: 0, x2: 0, y2: 1 }, df);
      elSvg('stop', { offset: '0', 'stop-color': 'var(--accent)', 'stop-opacity': 0.22 }, g);
      elSvg('stop', { offset: '1', 'stop-color': 'var(--accent)', 'stop-opacity': 0 }, g);

      elSvg('path', { d: p + ' L' + X(n - 1) + ' ' + Y(0) + ' L' + X(0) + ' ' + Y(0) + 'Z', fill: 'url(#dash-ag)' }, svg);
      elSvg('path', { d: p, fill: 'none', stroke: 'var(--accent)', 'stroke-width': 2, 'stroke-linejoin': 'round', 'stroke-linecap': 'round' }, svg);

      data.labels.forEach(function (l, i) {
        elSvg('text', { x: X(i), y: H - 8, 'font-size': 9, 'text-anchor': 'middle', fill: 'var(--muted)' }, svg).textContent = l;
      });

      var cur = elSvg('line', { y1: T, y2: Y(0), stroke: 'var(--muted)', 'stroke-width': 1, 'stroke-dasharray': '2 2', opacity: 0 }, svg);
      var dot = elSvg('circle', { r: 4.5, fill: 'var(--accent)', stroke: 'var(--card)', 'stroke-width': 2 }, svg);

      function sel(i, on) {
        dot.setAttribute('cx', X(i));
        dot.setAttribute('cy', Y(data.revSeries[i]));
        cur.setAttribute('x1', X(i));
        cur.setAttribute('x2', X(i));
        cur.setAttribute('opacity', on ? 1 : 0);
        rv.innerHTML = engine.inr(data.revSeries[i]) + '<small style="font:400 12px var(--f);color:var(--muted);margin-left:6px">' + data.labels[i] + '</small>';
      }

      function resetLine() {
        sel(n - 1, false);
        rv.innerHTML = engine.inr(data.sales) + '<small style="font:400 12px var(--f);color:var(--muted);margin-left:6px">total</small>';
      }

      data.revSeries.forEach(function (v, i) {
        var r = elSvg('rect', { x: X(i) - (W - L - R) / (n - 1) / 2, y: 0, width: (W - L - R) / (n - 1), height: H - B, class: 'hit' }, svg);
        r.addEventListener('mouseenter', function (e) { e.stopPropagation(); sel(i, true); });
        r.addEventListener('click', function (e) { e.stopPropagation(); sel(i, true); });
        r.addEventListener('mouseleave', resetLine);
      });

      resetLine();
    }

    function renderRankBars(ul, rows, color) {
      ul.innerHTML = '';
      var maxVal = Math.max.apply(null, rows.map(function (r) { return r[2]; })) || 1;
      rows.forEach(function (r) {
        var li = document.createElement('li');
        li.style.cssText = 'display:grid;grid-template-columns:1fr auto;gap:4px 12px;align-items:baseline';
        var pct = Math.round((r[2] / maxVal) * 100);

        li.innerHTML = [
          '<div style="font-size:14px;min-width:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + r[0] + '<span style="font:400 13px var(--te);color:var(--muted);margin-left:6px">' + r[1] + '</span></div>',
          '<div style="font:500 14px var(--f);font-variant-numeric:tabular-nums">' + engine.inr(r[2]) + '</div>',
          '<div style="grid-column:1/-1;height:8px;border-radius:4px;background:var(--grid);overflow:hidden">',
          '  <i style="display:block;height:100%;border-radius:4px;background:' + color + ';width:' + pct + '%"></i>',
          '</div>'
        ].join('\n');
        ul.appendChild(li);
      });
    }

    function update() {
      var data = engine.getDashboardData(currentPeriod);

      // KPI Tiles
      tilesBox.innerHTML = '';
      var kpis = [
        ['Sales', 'var(--accent)', data.sales, data.changes[0]],
        ['Expenses', 'var(--c-exp)', data.expenses, data.changes[1]],
        ['Profit', 'var(--c-profit)', data.profit, data.changes[2]],
        ['Credit given', 'var(--c-credit)', data.credit, data.changes[3]]
      ];

      kpis.forEach(function (k) {
        var isNeg = k[3][0] === '-';
        var tile = document.createElement('div');
        tile.className = 'grp';
        tile.style.cssText = 'background:var(--container);border-radius:20px;padding:14px 14px 12px;min-width:0';
        tile.innerHTML = [
          '<div style="font:500 12px var(--f);letter-spacing:.03em;text-transform:uppercase;color:var(--muted);display:flex;align-items:center;gap:6px">',
          '  <i style="width:8px;height:8px;border-radius:50%;flex:none;background:' + k[1] + '"></i>' + k[0],
          '</div>',
          '<div style="font:700 24px/1.2 var(--f);font-variant-numeric:tabular-nums;letter-spacing:-.01em;margin-top:4px">' + engine.inr(k[2]) + '</div>',
          '<div style="font:500 12px var(--f);margin-top:2px;color:' + (isNeg ? 'var(--red)' : 'var(--good)') + '">' +
            (isNeg ? '▼ ' : '▲ ') + k[3].slice(1) + ' <small style="font-weight:400;color:var(--muted)">vs ' + data.cmpText + '</small>',
          '</div>'
        ].join('\n');
        tilesBox.appendChild(tile);
      });

      // Line chart
      drawLineOrTable(data);

      // Donut Chart
      donutSvg.innerHTML = '';
      donutLeg.innerHTML = '';
      var C = 2 * Math.PI * 38;
      var off = 0;
      var sumSales = (data.split.credit + data.split.exp + data.split.profit) || 1;

      elSvg('circle', { cx: 50, cy: 50, r: 38, fill: 'none', stroke: 'var(--grid)', 'stroke-width': 12 }, donutSvg);

      var donutParts = [
        ['Credit', 'ఉధార్', 'var(--c-credit)', data.split.credit],
        ['Expenditure', 'ఖర్చు', 'var(--c-exp)', data.split.exp],
        ['Profit', 'లాభం', 'var(--c-profit)', data.split.profit]
      ];

      donutParts.forEach(function (p) {
        var len = (p[3] / sumSales) * C;
        if (len > 0) {
          elSvg('circle', {
            cx: 50, cy: 50, r: 38, fill: 'none', stroke: p[2], 'stroke-width': 12,
            'stroke-dasharray': Math.max(0, len - 3) + ' ' + (C - len + 3),
            'stroke-dashoffset': -off,
            transform: 'rotate(-90 50 50)'
          }, donutSvg);
        }
        off += len;

        var pct = Math.round((p[3] / sumSales) * 100);
        var legRow = document.createElement('div');
        legRow.style.cssText = 'display:flex;align-items:center;gap:8px;font-size:14px';
        legRow.innerHTML = [
          '<i style="width:10px;height:10px;border-radius:50%;flex:none;background:' + p[2] + '"></i>',
          '<em style="font-style:normal;flex:1;min-width:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + p[0] + '</em>',
          '<b style="font-weight:500;font-variant-numeric:tabular-nums">' + engine.inr(p[3]) + '</b>',
          '<small style="color:var(--muted);width:32px;text-align:right;font-variant-numeric:tabular-nums">' + pct + '%</small>'
        ].join('\n');
        donutLeg.appendChild(legRow);
      });

      elSvg('text', { x: 50, y: 47, 'font-size': 8, 'text-anchor': 'middle', fill: 'var(--muted)' }, donutSvg).textContent = 'Sales';
      var tSum = elSvg('text', { x: 50, y: 60, 'font-size': 12, 'font-weight': 700, 'text-anchor': 'middle', fill: 'var(--fg)' }, donutSvg);
      tSum.textContent = engine.inr(data.sales);

      // Top selling items
      renderRankBars(topItemsList, data.topItems, 'var(--accent)');

      // Credit vs Cash split bar
      ccBar.innerHTML = '';
      ccLeg.innerHTML = '';
      var cashVal = Math.max(0, data.sales - data.credit);
      var creditPct = Math.round((data.credit / (data.sales || 1)) * 100);
      var cashPct = 100 - creditPct;

      ccBar.innerHTML = [
        '<i style="display:block;height:100%;width:' + creditPct + '%;background:var(--c-credit)"></i>',
        '<i style="display:block;height:100%;width:' + cashPct + '%;background:var(--c-cash)"></i>'
      ].join('\n');

      ccLeg.innerHTML = [
        '<div style="display:flex;align-items:center;gap:8px;font-size:14px"><i style="width:10px;height:10px;border-radius:50%;background:var(--c-credit)"></i><em>Credit (ఉధార్)</em><b style="font-weight:500;margin-left:auto">' + engine.inr(data.credit) + '</b><small style="color:var(--muted);width:32px;text-align:right">' + creditPct + '%</small></div>',
        '<div style="display:flex;align-items:center;gap:8px;font-size:14px"><i style="width:10px;height:10px;border-radius:50%;background:var(--c-cash)"></i><em>Cash (నగదు)</em><b style="font-weight:500;margin-left:auto">' + engine.inr(cashVal) + '</b><small style="color:var(--muted);width:32px;text-align:right">' + cashPct + '%</small></div>'
      ].join('\n');

      ccNote.textContent = creditPct + '% of sales was given on credit and is still to be collected.';

      // Biggest expenses
      renderRankBars(expensesList, data.expensesList, 'var(--c-exp)');
    }

    // Segment events
    seg.querySelectorAll('button').forEach(function (btn) {
      btn.addEventListener('click', function () {
        currentPeriod = btn.dataset.p;
        seg.querySelectorAll('button').forEach(function (b) {
          b.setAttribute('aria-pressed', b === btn ? 'true' : 'false');
        });
        update();
      });
    });

    tglBtn.addEventListener('click', function () {
      isTableView = !isTableView;
      tglBtn.textContent = isTableView ? 'Chart' : 'Table';
      update();
    });

    update();
    return el;
  }

  window.LOG.screens.dashboard = {
    render: render
  };
})(window);
