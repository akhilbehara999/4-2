/**
 * LOG Prototype - Items Screen (#/items)
 * Catalog of all shop items with unit filtering, spoken names management,
 * FAB to add, and bottom sheet to add or edit.
 */

(function (window) {
  'use strict';

  var BOX_SVG = '<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round"><path d="M21 8 12 3 3 8v8l9 5 9-5zM3 8l9 5 9-5M12 13v8"/></svg>';

  function render() {
    var store = window.LOG.store;
    var engine = window.LOG.engine;
    var router = window.LOG.router;

    var el = document.createElement('div');
    el.className = 'screen items-screen';
    el.style.cssText = 'position:relative;display:flex;flex-direction:column;min-height:100%';

    el.innerHTML = [
      '<div class="top">',
      '  <button class="ib" id="itm-back" aria-label="Back" type="button"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg></button>',
      '  <h1>Items<span>వస్తువులు</span></h1>',
      '</div>',
      '<div style="padding:4px 16px 0;flex:none">',
      '  <div class="search">',
      '    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>',
      '    <input id="itm-q" type="search" placeholder="Search item · వస్తువు వెతకండి" aria-label="Search items">',
      '  </div>',
      '  <div class="chips" id="itm-chips" role="group" aria-label="Unit" style="margin-top:10px">',
      '    <button class="chip" data-f="all" aria-pressed="true" type="button">All</button>',
      '    <button class="chip" data-f="kg" aria-pressed="false" type="button">kg</button>',
      '    <button class="chip" data-f="L" aria-pressed="false" type="button">Litres</button>',
      '    <button class="chip" data-f="pcs" aria-pressed="false" type="button">Pieces</button>',
      '  </div>',
      '</div>',
      '<div id="itm-count" style="padding:10px 20px 4px;font:400 13px var(--f);color:var(--muted);flex:none"></div>',
      '<div class="scroll" id="itm-scroll" style="padding-bottom:86px"><ul class="list" id="itm-list"></ul></div>',
      '<button class="fab" id="itm-fab" type="button"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>Add item</button>',
      '<!-- Add / Edit Item Bottom Sheet -->',
      '<div class="sheet" id="itm-sheet" role="dialog" aria-label="Item">',
      '  <div class="grab"></div>',
      '  <h3 id="itm-sheet-title">Add item<span>కొత్త వస్తువు</span></h3>',
      '  <div class="fld"><label for="itm-fn">Name</label><input class="in" id="itm-fn" autocomplete="off" placeholder="e.g. Rice"></div>',
      '  <div id="itm-fmsg" style="font:400 13px var(--f);color:var(--red);margin:-6px 4px 10px;display:none"></div>',
      '  <div class="fld"><label for="itm-ft">Name in Telugu · తెలుగులో పేరు</label><input class="in" id="itm-ft" autocomplete="off" placeholder="బియ్యం"></div>',
      '  <div class="fld"><label>Other spoken names · ఇతర పేర్లు</label>',
      '    <div class="tags" id="itm-tags" style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:8px"></div>',
      '    <div style="display:flex;gap:8px"><input class="in" id="itm-fa" placeholder="Add a spelling, e.g. biyyam" autocomplete="off" style="height:44px;font-size:15px"><button class="btn" id="itm-fadd" type="button" style="height:44px;padding:0 16px;flex:none">Add</button></div>',
      '    <p style="font:400 13px var(--f);color:var(--muted);margin:6px 4px 0">Add every way you say it. The voice parser matches these.</p>',
      '  </div>',
      '  <div class="fld"><label id="itm-ul">Unit</label><div class="chips" id="itm-units" role="group" aria-labelledby="itm-ul" style="height:56px;display:flex"></div></div>',
      '  <div class="row" style="display:flex;gap:10px;padding:0;min-height:0;background:none">',
      '    <div class="fld" style="flex:1;min-width:0"><label for="itm-fr">Turns red at</label><input class="in" id="itm-fr" inputmode="decimal"></div>',
      '    <div class="fld" style="flex:1;min-width:0"><label for="itm-fp">Price per unit (₹)</label><input class="in" id="itm-fp" inputmode="numeric"></div>',
      '  </div>',
      '  <div class="srow"><button class="btn" id="itm-fcancel" type="button">Cancel</button><button class="btn fill" id="itm-fsave" type="button">Save</button></div>',
      '  <div class="danger" id="itm-danger"></div>',
      '</div>'
    ].join('\n');

    el.querySelector('#itm-back').addEventListener('click', function () {
      router.back();
    });

    var filt = 'all';
    var query = '';
    var activeItem = null;

    var countEl = el.querySelector('#itm-count');
    var listEl = el.querySelector('#itm-list');
    var qInput = el.querySelector('#itm-q');
    var fabBtn = el.querySelector('#itm-fab');

    var sheet = el.querySelector('#itm-sheet');
    var sheetTitle = el.querySelector('#itm-sheet-title');
    var fnIn = el.querySelector('#itm-fn');
    var ftIn = el.querySelector('#itm-ft');
    var faIn = el.querySelector('#itm-fa');
    var frIn = el.querySelector('#itm-fr');
    var fpIn = el.querySelector('#itm-fp');
    var fMsg = el.querySelector('#itm-fmsg');
    var tagsBox = el.querySelector('#itm-tags');
    var unitsBox = el.querySelector('#itm-units');
    var dangerBox = el.querySelector('#itm-danger');

    var currentTags = [];
    var currentUnit = 'kg';

    function renderList() {
      var items = store.getItems().slice();
      var s = query.toLowerCase();

      var filtered = items.filter(function (it) {
        if (filt !== 'all' && it.unit !== filt) return false;
        if (!s) return true;
        var nameMatch = it.name.toLowerCase().indexOf(s) > -1 || (it.nameTe && it.nameTe.indexOf(query) > -1);
        var tagMatch = it.spokenNames && it.spokenNames.some(function (t) { return t.toLowerCase().indexOf(s) > -1; });
        return nameMatch || tagMatch;
      });

      filtered.sort(function (a, b) {
        return a.name.localeCompare(b.name);
      });

      countEl.textContent = items.length + ' items';
      listEl.innerHTML = '';

      if (!filtered.length) {
        var emptyEl = document.createElement('li');
        emptyEl.style.cssText = 'padding:40px 0;text-align:center;color:var(--muted);font-size:14px';
        emptyEl.textContent = 'No items match.';
        listEl.appendChild(emptyEl);
        return;
      }

      filtered.forEach(function (it) {
        var li = document.createElement('li');
        var rowBtn = document.createElement('button');
        rowBtn.type = 'button';
        rowBtn.className = 'row';
        rowBtn.style.cssText = 'display:flex;align-items:center;gap:14px;padding:10px 4px;border-bottom:1px solid var(--line);width:100%;background:none;border-left:0;border-right:0;border-top:0;color:inherit;font:inherit;text-align:left;cursor:pointer;border-radius:12px';

        var tagCount = it.spokenNames ? it.spokenNames.length : 0;

        rowBtn.innerHTML = [
          '<span style="width:44px;height:44px;border-radius:50%;background:color-mix(in srgb,var(--purple) 15%,transparent);color:var(--purple);display:grid;place-items:center;flex:none">' + BOX_SVG + '</span>',
          '<span style="flex:1;min-width:0">',
          '  <div style="font:500 16px var(--f);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + it.name + (it.nameTe ? '<span style="font:400 14px var(--te);color:var(--muted);margin-left:6px">' + it.nameTe + '</span>' : '') + '</div>',
          '  <div style="font:400 13px var(--f);color:var(--muted);font-variant-numeric:tabular-nums">Turns red at ' + it.reorderLevel + ' ' + it.unit + '</div>',
          '</span>',
          '<span style="text-align:right;flex:none">',
          '  <b style="display:block;font:700 16px var(--f);font-variant-numeric:tabular-nums">' + engine.inr(it.price) + '/' + it.unit + '</b>',
          '  <small style="font:400 12px var(--f);color:var(--muted)">' + tagCount + ' spoken names</small>',
          '</span>'
        ].join('\n');

        rowBtn.addEventListener('click', function () {
          router.navigate('stock-detail', { itemId: it.id });
        });

        li.appendChild(rowBtn);
        listEl.appendChild(li);
      });
    }

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

    el.querySelector('#itm-fadd').addEventListener('click', function () {
      var val = faIn.value.trim();
      if (val && currentTags.indexOf(val) < 0) {
        currentTags.push(val);
        renderTags();
      }
      faIn.value = '';
    });

    function openSheet(it) {
      activeItem = it;
      sheetTitle.innerHTML = it ? 'Edit item<span>మార్చు</span>' : 'Add item<span>కొత్త వస్తువు</span>';
      fnIn.value = it ? it.name : '';
      ftIn.value = it ? (it.nameTe || '') : '';
      frIn.value = it ? it.reorderLevel : 3;
      fpIn.value = it ? it.price : 60;
      currentUnit = it ? it.unit : 'kg';
      currentTags = it && it.spokenNames ? it.spokenNames.slice() : [];

      fMsg.style.display = 'none';
      fnIn.classList.remove('bad');
      renderTags();
      renderUnits();

      dangerBox.innerHTML = '';
      if (it) {
        var delBtn = document.createElement('button');
        delBtn.type = 'button';
        delBtn.className = 'dbtn';
        delBtn.textContent = 'Delete item';
        delBtn.addEventListener('click', function () {
          dangerBox.innerHTML = [
            '<div class="confirm">',
            '  <span>Delete item? (Entries will be preserved)</span>',
            '  <button class="dbtn" id="itm-d-no" type="button" style="color:var(--fg)">Cancel</button>',
            '  <button class="dbtn yes" id="itm-d-yes" type="button">Delete</button>',
            '</div>'
          ].join('\n');

          dangerBox.querySelector('#itm-d-no').addEventListener('click', function () { openSheet(activeItem); });
          dangerBox.querySelector('#itm-d-yes').addEventListener('click', function () {
            store.deleteItem(activeItem.id);
            router.closeSheet();
            router.toast('Item deleted');
            renderList();
          });
        });
        dangerBox.appendChild(delBtn);
      }

      router.openSheet(sheet, fabBtn);
    }

    fabBtn.addEventListener('click', function () {
      openSheet(null);
    });

    el.querySelector('#itm-fcancel').addEventListener('click', function () {
      router.closeSheet();
    });

    el.querySelector('#itm-fsave').addEventListener('click', function () {
      var n = fnIn.value.trim();
      if (!n) {
        fMsg.textContent = 'Enter a name.';
        fMsg.style.display = 'block';
        fnIn.classList.add('bad');
        fnIn.focus();
        return;
      }

      var dup = store.getItems().some(function (i) {
        return (!activeItem || i.id !== activeItem.id) && i.name.toLowerCase() === n.toLowerCase();
      });

      if (dup) {
        fMsg.textContent = 'An item named ' + n + ' already exists.';
        fMsg.style.display = 'block';
        fnIn.classList.add('bad');
        return;
      }

      var dataObj = {
        name: n,
        nameTe: ftIn.value.trim(),
        unit: currentUnit,
        spokenNames: currentTags.slice(),
        reorderLevel: parseFloat(frIn.value) || 0,
        price: parseInt(fpIn.value, 10) || 0
      };

      if (activeItem) {
        store.updateItem(activeItem.id, dataObj);
        router.toast('Item updated · మార్చబడింది');
      } else {
        store.addItem(dataObj);
        router.toast(n + ' added · చేర్చబడింది');
      }

      router.closeSheet();
      renderList();
    });

    fnIn.addEventListener('input', function () {
      fMsg.style.display = 'none';
      fnIn.classList.remove('bad');
    });

    el.querySelectorAll('.chip[data-f]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        filt = btn.dataset.f;
        el.querySelectorAll('.chip[data-f]').forEach(function (x) {
          x.setAttribute('aria-pressed', x === btn ? 'true' : 'false');
        });
        renderList();
      });
    });

    qInput.addEventListener('input', function () {
      query = qInput.value.trim();
      renderList();
    });

    renderList();
    return el;
  }

  window.LOG.screens.items = {
    render: render
  };
})(window);
