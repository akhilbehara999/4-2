/**
 * LOG Prototype - More Screen (#/more)
 * 2x2 grid navigation hub for Udhar, Stock, Dashboard, and Ask.
 */

(function (window) {
  'use strict';

  function render() {
    var store = window.LOG.store;
    var engine = window.LOG.engine;
    var router = window.LOG.router;
    var state = store ? store.getState() : {};

    var el = document.createElement('div');
    el.className = 'screen more-screen';

    // Live data calculations
    var udharSummary = engine.getUdharSummary();
    var stockCounts = engine.getStockSummaryCounts();
    var checkDue = !state.weeklyCheckDone && state.settings.weeklyCheck && state.settings.weeklyCheck.on;

    el.innerHTML = [
      '<div class="top" style="padding:16px 20px 4px">',
      '  <div>',
      '    <h1 style="margin:0;font:500 28px/1.2 var(--f)">More</h1>',
      '    <p style="margin:2px 0 0;font:400 15px var(--te);color:var(--muted)">మరిన్ని</p>',
      '  </div>',
      '</div>',
      '<div class="scroll" style="display:grid;grid-template-columns:1fr 1fr;grid-auto-rows:1fr;gap:12px;padding:12px 16px 8px">',
      '  <!-- Udhar Tile -->',
      '  <button class="tile udhar" id="more-udhar" type="button" style="position:relative;border:0;border-radius:28px;background:var(--t-udhar);color:var(--fg);text-align:left;padding:18px 16px 16px;display:flex;flex-direction:column;cursor:pointer;min-height:0;min-width:0;font:inherit">',
      '    <svg class="arrow" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position:absolute;top:18px;right:14px;color:var(--muted)"><path d="M7 17 17 7M8 7h9v9"/></svg>',
      '    <span class="ico" style="width:56px;height:56px;border-radius:18px;background:color-mix(in srgb,var(--i-udhar) 16%,transparent);color:var(--i-udhar);display:grid;place-items:center"><svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h12a4 4 0 0 1 4 4v12H8a4 4 0 0 1-4-4zM8 9h8M8 13h5"/></svg></span>',
      '    <span class="name" style="margin-top:auto;font:500 20px/1.2 var(--f)">Udhar</span>',
      '    <span class="te" style="font:500 15px var(--te);color:var(--muted);margin-top:2px">ఉధార్</span>',
      '    <span class="stat" style="margin-top:10px;font:500 13px/1.35 var(--f);color:var(--i-udhar)">' + engine.inr(udharSummary.totalToCollect) + ' to collect<br>' + udharSummary.customerCount + ' customers</span>',
      '  </button>',
      '  <!-- Stock Tile -->',
      '  <button class="tile stock" id="more-stock" type="button" style="position:relative;border:0;border-radius:28px;background:var(--t-stock);color:var(--fg);text-align:left;padding:18px 16px 16px;display:flex;flex-direction:column;cursor:pointer;min-height:0;min-width:0;font:inherit">',
      '    <svg class="arrow" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position:absolute;top:18px;right:14px;color:var(--muted)"><path d="M7 17 17 7M8 7h9v9"/></svg>',
      '    <span class="ico" style="width:56px;height:56px;border-radius:18px;background:color-mix(in srgb,var(--i-stock) 16%,transparent);color:var(--i-stock);display:grid;place-items:center"><svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"><path d="M21 8 12 3 3 8v8l9 5 9-5zM3 8l9 5 9-5M12 13v8"/></svg></span>',
      '    <span class="name" style="margin-top:auto;font:500 20px/1.2 var(--f)">Stock</span>',
      '    <span class="te" style="font:500 15px var(--te);color:var(--muted);margin-top:2px">స్టాక్</span>',
      '    <span class="stat ' + (stockCounts.red > 0 ? 'warn' : '') + '" style="margin-top:10px;font:500 13px/1.35 var(--f);color:' + (stockCounts.red > 0 ? 'var(--red)' : 'var(--i-stock)') + '">' + stockCounts.red + ' items running low<br>' + (checkDue ? 'Weekly check due' : 'Stock up to date') + '</span>',
      '  </button>',
      '  <!-- Dashboard Tile -->',
      '  <button class="tile dash" id="more-dash" type="button" style="position:relative;border:0;border-radius:28px;background:var(--t-dash);color:var(--fg);text-align:left;padding:18px 16px 16px;display:flex;flex-direction:column;cursor:pointer;min-height:0;min-width:0;font:inherit">',
      '    <svg class="arrow" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position:absolute;top:18px;right:14px;color:var(--muted)"><path d="M7 17 17 7M8 7h9v9"/></svg>',
      '    <span class="ico" style="width:56px;height:56px;border-radius:18px;background:color-mix(in srgb,var(--i-dash) 16%,transparent);color:var(--i-dash);display:grid;place-items:center"><svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/></svg></span>',
      '    <span class="name" style="margin-top:auto;font:500 20px/1.2 var(--f)">Dashboard</span>',
      '    <span class="te" style="font:500 15px var(--te);color:var(--muted);margin-top:2px">డాష్‌బోర్డ్</span>',
      '    <span class="stat" style="margin-top:10px;font:500 13px/1.35 var(--f);color:var(--i-dash)">Sales, expenses<br>and profit</span>',
      '  </button>',
      '  <!-- Ask Tile -->',
      '  <button class="tile ask" id="more-ask" type="button" style="position:relative;border:0;border-radius:28px;background:var(--t-ask);color:var(--fg);text-align:left;padding:18px 16px 16px;display:flex;flex-direction:column;cursor:pointer;min-height:0;min-width:0;font:inherit">',
      '    <svg class="arrow" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position:absolute;top:18px;right:14px;color:var(--muted)"><path d="M7 17 17 7M8 7h9v9"/></svg>',
      '    <span class="ico" style="width:56px;height:56px;border-radius:18px;background:color-mix(in srgb,var(--i-ask) 16%,transparent);color:var(--i-ask);display:grid;place-items:center"><svg width="30" height="30" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.6A8 8 0 1 1 21 12zM9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.6.3-1 .8-1 1.4M12 16.5h.01"/></svg></span>',
      '    <span class="name" style="margin-top:auto;font:500 20px/1.2 var(--f)">Ask</span>',
      '    <span class="te" style="font:500 15px var(--te);color:var(--muted);margin-top:2px">అడగండి</span>',
      '    <span class="stat" style="margin-top:10px;font:500 13px/1.35 var(--f);color:var(--i-ask)">Ask about your shop<br>in Telugu or English</span>',
      '  </button>',
      '</div>'
    ].join('\n');

    el.querySelector('#more-udhar').addEventListener('click', function () {
      router.navigate('udhar');
    });
    el.querySelector('#more-stock').addEventListener('click', function () {
      router.navigate('stock');
    });
    el.querySelector('#more-dash').addEventListener('click', function () {
      router.navigate('dashboard');
    });
    el.querySelector('#more-ask').addEventListener('click', function () {
      router.navigate('ask');
    });

    return el;
  }

  window.LOG.screens.more = {
    render: render
  };
})(window);
