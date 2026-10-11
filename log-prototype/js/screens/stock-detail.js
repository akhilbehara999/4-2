/**
 * LOG Prototype - Stock Detail Screen (#/stock/:itemId)
 * Inventory item detail with 14-day usage bar chart, weighted average line,
 * history ledger, correct count sheet, and edit item sheet.
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

  function dleftText(d) {
    if (d === null) return 'no usage data';
    if (d <= 1.2) return 'about 1 day';
    return 'about ' + Math.round(d) + ' days';
  }

  function render(params) {
    var store = window.LOG.store;
    var engine = window.LOG.engine;
    var router = window.LOG.router;

    params = params || {};
    var itemId = params.itemId || 'i1';
    var item = store.getItemById(itemId);

    if (!item) {
      item = store.getItems()[0] || { id: 'i1', name: 'Rice', nameTe: 'బియ్యం', unit: 'kg', price: 60, reorderLevel: 5, spokenNames: ['biyyam', 'rice'], qty: 3 };
      itemId = item.id;
    }

    var el = document.createElement('div');
    el.className = 'screen stock-detail-screen';

    var stockStatus = engine.getItemStockStatus(itemId);
    var usageInfo = engine.getItem14DayUsage(itemId);
    var use = usageInfo.usage;
    var wavg = usageInfo.wavg;

    var statusColor = stockStatus.status === 'red' ? 'var(--red)' : (stockStatus.status === 'amber' ? 'var(--amber)' : (stockStatus.status === 'grey' ? 'var(--grey)' : 'var(--green)'));
    var statusBg = stockStatus.status === 'red' ? 'var(--red-tonal)' : (stockStatus.status === 'amber' ? 'var(--amber-tonal)' : (stockStatus.status === 'grey' ? 'var(--grey-tonal)' : 'var(--green-tonal)'));

    el.innerHTML = [
      '<div class="top">',
      '  <button class="ib" id="sd-back" aria-label="Back" type="button"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg></button>',
      '  <button class="ib" id="sd-edit-btn" aria-label="Edit item" type="button"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"/></svg></button>',
      '</div>',
      '<div class="scroll">',
      '  <!-- Item Header -->',
      '  <div class="who" style="padding:0 4px 14px">',
      '    <h1 style="margin:0;font:500 26px/1.2 var(--f)"><b style="font-weight:500">' + item.name + '</b><span style="font:400 18px var(--te);color:var(--muted);margin-left:10px">' + (item.nameTe || '') + '</span></h1>',
      '    <span class="stt" style="display:inline-flex;align-items:center;gap:6px;margin-top:8px;padding:4px 12px;border-radius:10px;font:500 13px var(--f);background:' + statusBg + ';color:' + statusColor + '"><i style="width:8px;height:8px;border-radius:50%;background:' + statusColor + '"></i>' + stockStatus.label + '</span>',
      '  </div>',
      '  <!-- Quantity Panel -->',
      '  <section class="qty" style="border-radius:28px;padding:18px 20px;background:' + statusBg + ';display:flex;flex-direction:column;gap:6px" aria-label="Current stock">',
      '    <div style="font:500 13px var(--f);letter-spacing:.04em;text-transform:uppercase;color:var(--muted)">In stock<span style="font-family:var(--te);text-transform:none;letter-spacing:0;margin-left:6px">ప్రస్తుత స్టాక్</span></div>',
      '    <div style="font:700 40px/1.1 var(--f);font-variant-numeric:tabular-nums;color:var(--fg)">' + item.qty + '<small style="font:500 20px var(--f);color:var(--muted);margin-left:6px">' + item.unit + '</small></div>',
      '    <div style="font:500 15px var(--f);color:' + statusColor + '">Lasts ' + dleftText(stockStatus.daysLeft) + '</div>',
      '    <div style="font:400 13px var(--f);color:var(--muted)">Based on ' + wavg.toFixed(1) + ' ' + item.unit + ' used per day</div>',
      '  </section>',
      '  <!-- Action Buttons -->',
      '  <div class="acts" style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:12px">',
      '    <button class="btn fill" id="sd-cnt-btn" type="button"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 11l3 3 8-8M20 12v7a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h9"/></svg>Correct count</button>',
      '    <button class="btn" id="sd-res-btn" type="button"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>Restock · స్టాక్</button>',
      '  </div>',
      '  <!-- 14-day Usage Card -->',
      '  <section class="card" style="margin-top:16px" aria-label="Daily use">',
      '    <div style="display:flex;justify-content:space-between;align-items:flex-start;gap:8px">',
      '      <div><h2 style="margin:0;font:500 16px var(--f)">Daily use</h2><span style="display:block;font:400 13px var(--te);color:var(--muted)">రోజువారీ వినియోగం · last 14 days</span></div>',
      '      <div id="sd-rd" style="font:700 17px var(--f);font-variant-numeric:tabular-nums;text-align:right;min-width:90px">' + wavg.toFixed(1) + ' ' + item.unit + '/day<small style="display:block;font:400 12px var(--f);color:var(--muted)">weighted average</small></div>',
      '    </div>',
      '    <div id="sd-chart" style="margin-top:8px"></div>',
      '    <div class="key" style="display:flex;gap:14px;align-items:center;margin-top:6px;font:400 12px var(--f);color:var(--muted)">',
      '      <span style="display:flex;align-items:center;gap:6px"><i style="width:10px;height:10px;border-radius:3px;background:var(--accent)"></i>Used per day</span>',
      '      <span style="display:flex;align-items:center;gap:6px"><i style="width:18px;height:0;border-top:2px dashed var(--orange)"></i>Weighted average</span>',
      '    </div>',
      '    <p class="why" id="sd-why" style="margin:12px 0 0;font:400 14px/1.5 var(--f);color:var(--muted)"></p>',
      '  </section>',
      '  <!-- Stock Threshold & Price Info -->',
      '  <div class="info" style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:12px">',
      '    <div style="background:var(--container);border-radius:16px;padding:12px 14px"><small style="display:block;font:500 12px var(--f);letter-spacing:.03em;text-transform:uppercase;color:var(--muted)">Turns red at</small><b style="font:700 17px var(--f);font-variant-numeric:tabular-nums">' + item.reorderLevel + ' ' + item.unit + '</b></div>',
      '    <div style="background:var(--container);border-radius:16px;padding:12px 14px"><small style="display:block;font:500 12px var(--f);letter-spacing:.03em;text-transform:uppercase;color:var(--muted)">Price</small><b style="font:700 17px var(--f);font-variant-numeric:tabular-nums">' + engine.inr(item.price) + '/' + item.unit + '</b></div>',
      '  </div>',
      '  <!-- History ledger -->',
      '  <div class="sec" style="display:flex;justify-content:space-between;align-items:baseline;margin:20px 4px 4px">',
      '    <h2 style="margin:0;font:500 18px var(--f)">History<span style="font:400 14px var(--te);color:var(--muted);margin-left:6px">చరిత్ర</span></h2>',
      '  </div>',
      '  <ul class="list" id="sd-history-list"></ul>',
      '</div>',
      '<!-- Correct Count Bottom Sheet -->',
      '<div class="sheet" id="sd-cnt-sheet" role="dialog" aria-label="Correct count">',
      '  <div class="grab"></div><h3>Correct count<span>లెక్క సరిచేయండి</span></h3>',
      '  <div class="fld"><label for="sd-cq">How much is in the shop now?</label>',
      '    <div style="display:flex;gap:10px;align-items:center"><button class="btn" id="sd-cm" type="button" aria-label="Less" style="width:56px;height:56px;border-radius:50%;font-size:24px;padding:0">−</button><input class="in" id="sd-cq" inputmode="decimal" autocomplete="off" value="' + item.qty + '" style="text-align:center;font:700 28px var(--f);height:64px"><button class="btn" id="sd-cp" type="button" aria-label="More" style="width:56px;height:56px;border-radius:50%;font-size:24px;padding:0">+</button></div>',
      '  </div>',
      '  <div id="sd-cmsg" style="font:400 14px var(--f);color:var(--muted);margin:8px 4px 14px;min-height:20px"></div>',
      '  <div class="srow"><button class="btn" id="sd-c-cancel" type="button">Cancel</button><button class="btn fill" id="sd-c-save" type="button">Save count</button></div>',
      '</div>',
      '<!-- Edit Item Bottom Sheet -->',
      '<div class="sheet" id="sd-edit-sheet" role="dialog" aria-label="Edit item">',
      '  <div class="grab"></div><h3>Edit item<span>మార్చు</span></h3>',
      '  <div class="fld"><label for="sd-en">Name</label><input class="in" id="sd-en" value="' + item.name + '" autocomplete="off"></div>',
      '  <div class="fld"><label for="sd-et">Name in Telugu · తెలుగులో పేరు</label><input class="in" id="sd-et" value="' + (item.nameTe || '') + '" autocomplete="off"></div>',
      '  <div class="fld"><label>Other spoken names · ఇతర పేర్లు</label>',
      '    <div class="tags" id="sd-tags" style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:8px"></div>',
      '    <div style="display:flex;gap:8px"><input class="in" id="sd-ea" placeholder="Add a spelling, e.g. biyyam" autocomplete="off" style="height:44px;font-size:15px"><button class="btn" id="sd-e-add" type="button" style="height:44px;padding:0 16px;flex:none">Add</button></div>',
      '  </div>',
      '  <div class="fld"><label id="sd-ul">Unit</label><div class="chips" id="sd-units" role="group" aria-labelledby="sd-ul" style="height:56px;display:flex"></div></div>',
      '  <div class="row" style="display:flex;gap:10px;padding:0;min-height:0;background:none">',
      '    <div class="fld" style="flex:1;min-width:0"><label for="sd-er">Turns red at</label><input class="in" id="sd-er" inputmode="decimal" value="' + item.reorderLevel + '"></div>',
      '    <div class="fld" style="flex:1;min-width:0"><label for="sd-ep">Price per unit (₹)</label><input class="in" id="sd-ep" inputmode="numeric" value="' + item.price + '"></div>',
      '  </div>',
      '  <div class="srow"><button class="btn" id="sd-e-cancel" type="button">Cancel</button><button class="btn fill" id="sd-e-save" type="button">Save</button></div>',
      '  <div class="danger" id="sd-danger"></div>',
      '</div>'
    ].join('\n');

    el.querySelector('#sd-back').addEventListener('click', function () {
      router.back();
    });

    // Draw Bar Chart
    var chartBox = el.querySelector('#sd-chart');
    var W = 300, H2 = 140, L = 30, R = 8, T = 8, B = 22;
    var mx = Math.max(5, Math.ceil(Math.max.apply(null, use) * 1.2));
    var n = use.length, slot = (W - L - R) / n, bw = slot - 5;

    var svg = elSvg('svg', { viewBox: '0 0 ' + W + ' ' + H2, width: '100%', role: 'img', 'aria-label': 'Bar chart of daily usage' }, chartBox);

    function Y(v) { return T + (1 - (v / mx)) * (H2 - T - B); }

    [0, Math.round(mx / 2), mx].forEach(function (g) {
      elSvg('line', { x1: L, x2: W - R, y1: Y(g), y2: Y(g), stroke: 'var(--grid)', 'stroke-width': 1 }, svg);
      elSvg('text', { x: L - 6, y: Y(g) + 3, 'font-size': 9, 'text-anchor': 'end', fill: 'var(--muted)' }, svg).textContent = g + (g === mx ? ' ' + item.unit : '');
    });

    var bars = [];
    use.forEach(function (v, i) {
      var x = L + i * slot + 2.5;
      bars.push(elSvg('rect', { x: x, y: Y(v), width: bw, height: Math.max(1, Y(0) - Y(v)), rx: 3, fill: 'var(--accent)' }, svg));
    });

    // Weighted average dashed line
    elSvg('line', { x1: L, x2: W - R, y1: Y(wavg), y2: Y(wavg), stroke: 'var(--orange)', 'stroke-width': 2, 'stroke-dasharray': '5 4' }, svg);

    // Labels
    var nowD = new Date();
    [[0, '13d ago'], [6, '7d ago'], [13, 'Today']].forEach(function (p) {
      elSvg('text', { x: L + p[0] * slot + slot / 2, y: H2 - 6, 'font-size': 9, 'text-anchor': p[0] === 0 ? 'start' : (p[0] === 13 ? 'end' : 'middle'), fill: 'var(--muted)' }, svg).textContent = p[1];
    });

    var rd = el.querySelector('#sd-rd');
    function showBar(i) {
      bars.forEach(function (b, j) { b.setAttribute('opacity', j === i ? 1 : 0.45); });
      rd.innerHTML = use[i] + ' ' + item.unit + '<small style="display:block;font:400 12px var(--f);color:var(--muted)">' + (i === 13 ? 'Today' : (13 - i) + ' days ago') + '</small>';
    }

    function resetBar() {
      bars.forEach(function (b) { b.setAttribute('opacity', 1); });
      rd.innerHTML = wavg.toFixed(1) + ' ' + item.unit + '/day<small style="display:block;font:400 12px var(--f);color:var(--muted)">weighted average</small>';
    }

    use.forEach(function (v, i) {
      var r = elSvg('rect', { x: L + i * slot, y: 0, width: slot, height: H2 - B, class: 'hit' }, svg);
      r.addEventListener('mouseenter', function (e) { e.stopPropagation(); showBar(i); });
      r.addEventListener('click', function (e) { e.stopPropagation(); showBar(i); });
      r.addEventListener('mouseleave', resetBar);
    });

    // Why explanation text
    var whyEl = el.querySelector('#sd-why');
    whyEl.innerHTML = 'Why ' + stockStatus.label.split(' ·')[0].toLowerCase() + '? At <b>' + wavg.toFixed(1) + ' ' + item.unit + '/day</b>, ' + item.qty + ' ' + item.unit + ' lasts <b>' + dleftText(stockStatus.daysLeft) + '</b>. Recent days count more than older days.';

    // Populate history ledger
    var historyList = el.querySelector('#sd-history-list');
    var entries = store.getEntries().filter(function (e) { return e.itemId === itemId; });

    var ICONS = {
      cash: '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="2.5"/></svg>',
      credit: '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 6v6l4 2M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0"/></svg>',
      stock: '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 8 12 3 3 8v8l9 5 9-5zM3 8l9 5 9-5M12 13v8"/></svg>',
      count: '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 11l3 3 8-8M20 12v7a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h9"/></svg>'
    };

    if (!entries.length) {
      var noHistLi = document.createElement('li');
      noHistLi.style.cssText = 'padding:14px 4px;color:var(--muted);font-size:14px';
      noHistLi.textContent = 'Initial stock: ' + item.qty + ' ' + item.unit;
      historyList.appendChild(noHistLi);
    } else {
      entries.slice(0, 10).forEach(function (e) {
        var li = document.createElement('li');
        li.style.cssText = 'display:flex;gap:12px;align-items:center;padding:12px 4px;border-bottom:1px solid var(--line)';

        var isStock = e.type === 'stock';
        var isCount = e.type === 'count';
        var col = isStock ? 'var(--purple)' : (isCount ? 'var(--blue)' : (e.type === 'credit' ? 'var(--orange)' : 'var(--green)'));
        var dateFormatted = new Date(e.createdAt).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });

        var title = isCount ? 'Count corrected' : (isStock ? 'Restock' : (e.type === 'credit' ? 'Credit sale' : 'Cash sale'));

        li.innerHTML = [
          '<span style="width:36px;height:36px;border-radius:50%;display:grid;place-items:center;flex:none;background:color-mix(in srgb,' + col + ' 16%,transparent);color:' + col + '">' + (ICONS[e.type] || ICONS.cash) + '</span>',
          '<div style="flex:1;min-width:0">',
          '  <div style="font:500 15px var(--f)">' + title + '</div>',
          '  <div style="font:400 12px var(--f);color:var(--muted)">' + dateFormatted + '</div>',
          '</div>',
          '<div style="text-align:right;flex:none">',
          '  <div style="font:700 15px var(--f);font-variant-numeric:tabular-nums;color:' + (isStock ? 'var(--green)' : 'var(--fg)') + '">' + (e.qty ? (isStock ? '+' : '−') + e.qty + ' ' + item.unit : '') + '</div>',
          '  <div style="font:400 12px var(--f);color:var(--muted);font-variant-numeric:tabular-nums">' + (e.amount ? engine.inr(e.amount) : '') + '</div>',
          '</div>'
        ].join('\n');

        historyList.appendChild(li);
      });
    }

    // Restock button -> confirm screen as stock
    el.querySelector('#sd-res-btn').addEventListener('click', function () {
      router.navigate('confirm', {
        type: 'stock',
        item: item.name
      });
    });

    // Correct count sheet logic
    var cntSheet = el.querySelector('#sd-cnt-sheet');
    var cqIn = el.querySelector('#sd-cq');
    var cmsg = el.querySelector('#sd-cmsg');

    function previewCount() {
      var v = parseFloat(cqIn.value);
      if (isNaN(v) || v < 0) {
        cmsg.textContent = 'Enter the amount in the shop.';
        return null;
      }
      var dLeft = wavg > 0 ? (v / wavg) : null;
      var lbl = dLeft === null ? 'Fine' : (dLeft <= 2 ? 'Low' : (dLeft <= 6 ? 'Getting low' : 'Fine'));
      cmsg.textContent = 'Status after saving: ' + lbl + ', lasts ' + dleftText(dLeft) + '.';
      return v;
    }

    el.querySelector('#sd-cnt-btn').addEventListener('click', function () {
      cqIn.value = item.qty;
      previewCount();
      router.openSheet(cntSheet, el.querySelector('#sd-cnt-btn'));
    });

    cqIn.addEventListener('input', previewCount);

    el.querySelector('#sd-cm').addEventListener('click', function () {
      var v = parseFloat(cqIn.value) || 0;
      cqIn.value = Math.max(0, Math.round((v - 1) * 10) / 10);
      previewCount();
    });

    el.querySelector('#sd-cp').addEventListener('click', function () {
      var v = parseFloat(cqIn.value) || 0;
      cqIn.value = Math.round((v + 1) * 10) / 10;
      previewCount();
    });

    el.querySelector('#sd-c-cancel').addEventListener('click', function () { router.closeSheet(); });

    el.querySelector('#sd-c-save').addEventListener('click', function () {
      var v = previewCount();
      if (v === null) return;

      store.addEntry({
        type: 'count',
        itemId: itemId,
        customerId: null,
        qty: v,
        unit: item.unit,
        amount: 0,
        spokenText: 'Count corrected to ' + v + ' ' + item.unit
      });

      store.updateItem(itemId, { qty: v });
      router.closeSheet();
      router.toast('Count saved · లెక్క సేవ్ చేయబడింది');
      render(params);
    });

    // Edit item sheet logic
    var editSheet = el.querySelector('#sd-edit-sheet');
    var enIn = el.querySelector('#sd-en');
    var etIn = el.querySelector('#sd-et');
    var eaIn = el.querySelector('#sd-ea');
    var erIn = el.querySelector('#sd-er');
    var epIn = el.querySelector('#sd-ep');
    var tagsBox = el.querySelector('#sd-tags');
    var unitsBox = el.querySelector('#sd-units');
    var dangerBox = el.querySelector('#sd-danger');

    var currentTags = (item.spokenNames || []).slice();
    var currentUnit = item.unit || 'kg';

    function renderTags() {
      tagsBox.innerHTML = '';
      currentTags.forEach(function (t, idx) {
        var tagSpan = document.createElement('span');
        tagSpan.style.cssText = 'display:inline-flex;align-items:center;gap:4px;height:34px;padding:0 6px 0 12px;border-radius:10px;border:1px solid var(--line);font:400 14px var(--te);background:var(--container)';
        tagSpan.appendChild(document.createTextNode(t));

        var rmBtn = document.createElement('button');
        rmBtn.type = 'button';
        rmBtn.setAttribute('aria-label', 'Remove ' + t);
        rmBtn.style.cssText = 'width:26px;height:26px;border:0;border-radius:50%;background:none;color:var(--muted);cursor:pointer;display:grid;place-items:center';
        rmBtn.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><path d="M18 6 6 18M6 6l12 12"/></svg>';
        rmBtn.addEventListener('click', function () {
          currentTags.splice(idx, 1);
          renderTags();
        });
        tagSpan.appendChild(rmBtn);
        tagsBox.appendChild(tagSpan);
      });
    }

    function renderUnits() {
      unitsBox.innerHTML = '';
      ['kg', 'L', 'pcs'].forEach(function (u) {
        var btn = document.createElement('button');
        btn.type = 'button';
        btn.textContent = u;
        btn.setAttribute('aria-pressed', u === currentUnit ? 'true' : 'false');
        btn.style.cssText = 'flex:1;height:56px;border-radius:14px;border:1.5px solid var(--outline);background:none;color:var(--fg);font:500 15px var(--f);cursor:pointer';
        btn.addEventListener('click', function () {
          currentUnit = u;
          renderUnits();
        });
        unitsBox.appendChild(btn);
      });
    }

    el.querySelector('#sd-e-add').addEventListener('click', function () {
      var val = eaIn.value.trim();
      if (val && currentTags.indexOf(val) < 0) {
        currentTags.push(val);
        renderTags();
      }
      eaIn.value = '';
    });

    function renderDangerInitial() {
      dangerBox.innerHTML = '';
      var delBtn = document.createElement('button');
      delBtn.type = 'button';
      delBtn.className = 'dbtn';
      delBtn.textContent = 'Delete item';
      delBtn.addEventListener('click', function () {
        dangerBox.innerHTML = [
          '<div class="confirm">',
          '  <span>Delete item? (Entries will be preserved)</span>',
          '  <button class="dbtn" id="di-cancel" type="button" style="color:var(--fg)">Cancel</button>',
          '  <button class="dbtn yes" id="di-yes" type="button">Delete</button>',
          '</div>'
        ].join('\n');

        dangerBox.querySelector('#di-cancel').addEventListener('click', renderDangerInitial);
        dangerBox.querySelector('#di-yes').addEventListener('click', function () {
          store.deleteItem(itemId);
          router.closeSheet();
          router.toast('Item deleted · తొలగించబడింది');
          router.navigate('stock', {}, true);
        });
      });
      dangerBox.appendChild(delBtn);
    }

    el.querySelector('#sd-edit-btn').addEventListener('click', function () {
      enIn.value = item.name;
      etIn.value = item.nameTe || '';
      erIn.value = item.reorderLevel;
      epIn.value = item.price;
      currentUnit = item.unit;
      currentTags = (item.spokenNames || []).slice();
      renderTags();
      renderUnits();
      renderDangerInitial();
      router.openSheet(editSheet, el.querySelector('#sd-edit-btn'));
    });

    el.querySelector('#sd-e-cancel').addEventListener('click', function () { router.closeSheet(); });

    el.querySelector('#sd-e-save').addEventListener('click', function () {
      var nVal = enIn.value.trim();
      if (!nVal) { enIn.focus(); return; }

      store.updateItem(itemId, {
        name: nVal,
        nameTe: etIn.value.trim(),
        unit: currentUnit,
        spokenNames: currentTags.slice(),
        reorderLevel: parseFloat(erIn.value) || item.reorderLevel,
        price: parseInt(epIn.value, 10) || item.price
      });

      router.closeSheet();
      router.toast('Item updated · మార్చబడింది');
      render(params);
    });

    return el;
  }

  window.LOG.screens['stock-detail'] = {
    render: render
  };
})(window);
