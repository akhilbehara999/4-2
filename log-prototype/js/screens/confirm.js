/**
 * LOG Prototype - Confirm Entry Screen (#/confirm)
 * Form to confirm voice or typed entries before saving to store.
 * Dynamic field display based on entry type, live balance and stock hints.
 */

(function (window) {
  'use strict';

  var TYPES = [
    ['credit', 'Credit', 'ఉధార్'],
    ['cash', 'Cash sale', 'నగదు'],
    ['pay', 'Received', 'జమ'],
    ['stock', 'Restock', 'స్టాక్'],
    ['exp', 'Expense', 'ఖర్చు']
  ];

  var UNITS = ['kg', 'L', 'pcs'];

  function render(params) {
    var store = window.LOG.store;
    var engine = window.LOG.engine;
    var router = window.LOG.router;

    params = params || {};
    var parsed = params.parsed || {};
    var rawText = params.rawText || (parsed.spokenText || 'రామేష్‌కి 5 కిలోల బియ్యం అప్పు ఇచ్చాను, 300 రూపాయలు');
    var editEntry = null;

    if (params.editEntryId) {
      editEntry = store.getEntries().find(function (e) { return e.id === params.editEntryId; });
      if (editEntry) {
        var custObj = store.getCustomerById(editEntry.customerId);
        var itemObj = store.getItemById(editEntry.itemId);
        parsed = {
          type: editEntry.type,
          customer: custObj ? custObj.name : '',
          item: itemObj ? itemObj.name : '',
          qty: editEntry.qty,
          unit: editEntry.unit || 'kg',
          amount: editEntry.amount,
          spokenText: editEntry.spokenText
        };
        rawText = editEntry.spokenText || 'Edited entry';
      }
    }

    // Default values
    var curType = params.type || parsed.type || 'credit';
    var curUnit = parsed.unit || 'kg';
    var defaultCust = params.customer || parsed.customer || 'Ramesh';
    var defaultItem = params.item || parsed.item || 'Rice';
    var defaultQty = parsed.qty !== undefined && parsed.qty !== null ? parsed.qty : 5;
    var defaultAmt = parsed.amount !== undefined && parsed.amount !== null ? parsed.amount : 300;

    var el = document.createElement('div');
    el.className = 'screen confirm-screen';
    el.innerHTML = [
      '<div class="top">',
      '  <button class="ib" id="cfm-close" aria-label="Close" type="button"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M18 6 6 18M6 6l12 12"/></svg></button>',
      '  <h1>Confirm entry<span>నిర్ధారించండి</span></h1>',
      '</div>',
      '<div class="scroll" style="display:flex;flex-direction:column;gap:16px;padding-top:4px">',
      '  <!-- Heard section -->',
      '  <section class="grp" style="padding:16px;background:var(--container);border-radius:24px;display:flex;flex-direction:column;gap:10px" aria-label="What I heard">',
      '    <div style="font:500 12px var(--f);letter-spacing:.04em;text-transform:uppercase;color:var(--muted)">I heard<span style="font-family:var(--te);text-transform:none;letter-spacing:0;margin-left:6px">విన్నది</span></div>',
      '    <p id="cfm-heard-text" style="margin:0;font:500 18px/1.45 var(--te);color:var(--fg)">“' + rawText + '”</p>',
      '    <button class="btn" id="cfm-again" type="button" style="align-self:flex-start;height:38px;padding:0 14px 0 10px;font-size:13px;border-radius:19px"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v4"/></svg>Wrong? Speak again</button>',
      '  </section>',
      '  <!-- Entry type chips -->',
      '  <section>',
      '    <div style="font:500 13px var(--f);letter-spacing:.04em;text-transform:uppercase;color:var(--muted);margin-bottom:8px">Entry type<span style="font-family:var(--te);text-transform:none;letter-spacing:0;margin-left:6px">రకం</span></div>',
      '    <div class="chips" id="cfm-types" role="group" aria-label="Entry type" style="flex-wrap:wrap"></div>',
      '  </section>',
      '  <!-- Dynamic Fields Form -->',
      '  <section class="form" id="cfm-form" style="display:flex;flex-direction:column;gap:14px">',
      '    <div class="fld" id="fld-cust" data-for="credit pay">',
      '      <label for="cfm-cust">Customer<span>కస్టమర్</span></label>',
      '      <input class="in" id="cfm-cust" value="' + defaultCust + '" autocomplete="off" placeholder="e.g. Ramesh">',
      '      <div class="hint" id="cfm-cust-hint" style="display:flex;gap:8px;align-items:flex-start;margin:6px 4px 0;font:400 13px/1.4 var(--f)"></div>',
      '    </div>',
      '    <div class="fld" id="fld-item" data-for="credit cash stock exp">',
      '      <label for="cfm-item" id="cfm-item-lab">Item<span>వస్తువు</span></label>',
      '      <input class="in" id="cfm-item" value="' + defaultItem + '" autocomplete="off" placeholder="e.g. Rice">',
      '    </div>',
      '    <div class="row" id="fld-qty-row" data-for="credit cash stock" style="display:flex;gap:10px;padding:0;min-height:0;background:none">',
      '      <div class="fld" style="flex:1;min-width:0;margin-bottom:0"><label for="cfm-qty">Quantity<span>పరిమాణం</span></label><input class="in" id="cfm-qty" inputmode="decimal" value="' + defaultQty + '"></div>',
      '      <div class="fld" style="flex:1;min-width:0;margin-bottom:0"><label id="cfm-unit-lab">Unit<span>యూనిట్</span></label><div class="chips" id="cfm-units" role="group" aria-labelledby="cfm-unit-lab" style="height:56px;display:flex"></div></div>',
      '    </div>',
      '    <div class="fld" id="fld-amt" style="margin-bottom:0">',
      '      <label for="cfm-amt">Amount<span>మొత్తం</span></label>',
      '      <div style="position:relative"><b style="position:absolute;left:16px;top:0;height:64px;display:flex;align-items:center;font:700 24px var(--f);color:var(--muted)">₹</b><input class="in" id="cfm-amt" inputmode="numeric" value="' + defaultAmt + '" style="height:64px;padding-left:38px;font:700 26px var(--f);font-variant-numeric:tabular-nums"></div>',
      '      <div class="hint" id="cfm-amt-hint" style="display:flex;gap:8px;align-items:flex-start;margin:6px 4px 0;font:400 13px/1.4 var(--f);color:var(--muted)"></div>',
      '    </div>',
      '    <div class="hint" id="cfm-stock-hint" data-for="credit cash stock" style="display:flex;gap:8px;align-items:flex-start;margin:2px 4px 0;font:400 13px/1.4 var(--f);color:var(--muted)"></div>',
      '  </section>',
      '</div>',
      '<div class="srow" style="padding:12px 16px calc(14px + env(safe-area-inset-bottom, 0px));background:var(--container);margin-top:auto">',
      '  <button class="btn" id="cfm-cancel" type="button" style="flex:1">Cancel</button>',
      '  <button class="btn fill" id="cfm-save" type="button" style="flex:2">Save entry · సేవ్</button>',
      '</div>'
    ].join('\n');

    el.querySelector('#cfm-close').addEventListener('click', function () {
      router.back();
    });

    el.querySelector('#cfm-cancel').addEventListener('click', function () {
      router.toast('Entry discarded');
      router.back();
    });

    el.querySelector('#cfm-again').addEventListener('click', function () {
      router.navigate('listen');
    });

    // Populate type chips
    var typesContainer = el.querySelector('#cfm-types');
    TYPES.forEach(function (t) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'chip';
      btn.dataset.k = t[0];
      btn.setAttribute('aria-pressed', t[0] === curType ? 'true' : 'false');
      btn.style.cssText = 'min-height:42px;padding:6px 14px;border-radius:12px;display:flex;flex-direction:column;align-items:flex-start;line-height:1.2;cursor:pointer';
      btn.innerHTML = '<span style="font-weight:500">' + t[1] + '</span><small style="font:400 12px var(--te);color:var(--muted)">' + t[2] + '</small>';

      btn.addEventListener('click', function () {
        curType = t[0];
        typesContainer.querySelectorAll('.chip').forEach(function (x) {
          x.setAttribute('aria-pressed', x === btn ? 'true' : 'false');
        });
        syncFields();
      });
      typesContainer.appendChild(btn);
    });

    // Populate unit buttons
    var unitsContainer = el.querySelector('#cfm-units');
    UNITS.forEach(function (u) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.textContent = u;
      btn.setAttribute('aria-pressed', u === curUnit ? 'true' : 'false');
      btn.style.cssText = 'flex:1;height:56px;border-radius:14px;border:1.5px solid var(--outline);background:none;color:var(--fg);font:500 15px var(--f);cursor:pointer';
      btn.addEventListener('click', function () {
        curUnit = u;
        unitsContainer.querySelectorAll('button').forEach(function (x) {
          x.setAttribute('aria-pressed', x === btn ? 'true' : 'false');
        });
        syncFields();
      });
      unitsContainer.appendChild(btn);
    });

    var custIn = el.querySelector('#cfm-cust');
    var itemIn = el.querySelector('#cfm-item');
    var qtyIn = el.querySelector('#cfm-qty');
    var amtIn = el.querySelector('#cfm-amt');
    var itemLab = el.querySelector('#cfm-item-lab');
    var custHint = el.querySelector('#cfm-cust-hint');
    var amtHint = el.querySelector('#cfm-amt-hint');
    var stockHint = el.querySelector('#cfm-stock-hint');

    var ICON_INFO = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" style="flex:none;margin-top:1px"><circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/></svg>';
    var ICON_OK = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:1px;color:var(--good)"><path d="M20 6 9 17l-5-5"/></svg>';
    var ICON_PLUS = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" style="flex:none;margin-top:1px;color:var(--amber)"><path d="M12 5v14M5 12h14"/></svg>';

    function syncFields() {
      // Toggle elements based on data-for
      el.querySelectorAll('[data-for]').forEach(function (e) {
        var allowed = e.dataset.for.split(' ');
        e.style.display = allowed.indexOf(curType) >= 0 ? '' : 'none';
      });

      // Item label changes if expense
      if (curType === 'exp') {
        itemLab.innerHTML = 'What for<span>దేనికి</span>';
      } else {
        itemLab.innerHTML = 'Item<span>వస్తువు</span>';
      }

      // Customer hint
      var custVal = custIn.value.trim();
      var amtVal = parseInt(amtIn.value.replace(/[^\d]/g, ''), 10) || 0;
      custHint.innerHTML = '';

      if (!custVal) {
        custHint.innerHTML = ICON_INFO + '<span>Enter who this is for.</span>';
      } else {
        var existingCust = store.getCustomers().find(function (c) {
          return c.name.toLowerCase() === custVal.toLowerCase() || (c.nameTe && c.nameTe === custVal);
        });

        if (existingCust) {
          var bal = engine.getCustomerBalance(existingCust.id);
          var after = curType === 'pay' ? Math.max(0, bal - amtVal) : (bal + amtVal);
          custHint.innerHTML = ICON_OK + '<span>Existing customer. Owes <b>' + engine.inr(bal) + '</b> now, <b>' + engine.inr(after) + '</b> after saving.</span>';
        } else {
          custHint.innerHTML = ICON_PLUS + '<span style="color:var(--amber)">New customer. <b>' + custVal + '</b> will be added to Udhar.</span>';
        }
      }

      // Amount hint
      amtHint.innerHTML = ICON_INFO;
      if (curType === 'credit') {
        amtHint.innerHTML += '<span>Given on credit. Nothing is paid today.</span>';
      } else if (curType === 'cash') {
        amtHint.innerHTML += '<span>Paid in cash today.</span>';
      } else if (curType === 'pay') {
        amtHint.innerHTML += '<span>Reduces the customer\'s udhar balance.</span>';
      } else if (curType === 'stock') {
        amtHint.innerHTML += '<span>Cost of the new stock.</span>';
      } else {
        amtHint.innerHTML += '<span>Counted in today\'s expenses.</span>';
      }

      // Stock hint
      var itName = itemIn.value.trim();
      var qVal = qtyIn.value.trim();
      stockHint.innerHTML = '';
      if (itName && qVal && curType !== 'pay' && curType !== 'exp') {
        var verb = curType === 'stock' ? 'increase' : 'reduce';
        stockHint.innerHTML = ICON_INFO + '<span>' + itName + ' stock will ' + verb + ' by <b>' + qVal + ' ' + curUnit + '</b>.</span>';
      }
    }

    [custIn, itemIn, qtyIn, amtIn].forEach(function (inp) {
      inp.addEventListener('input', syncFields);
    });

    // Save button logic
    el.querySelector('#cfm-save').addEventListener('click', function () {
      var amt = parseInt(amtIn.value.replace(/[^\d]/g, ''), 10) || 0;
      var cName = custIn.value.trim();
      var iName = itemIn.value.trim();
      var qNum = parseFloat(qtyIn.value);

      // Resolve or create Customer
      var customerId = null;
      if (curType === 'credit' || curType === 'pay') {
        if (!cName) {
          custIn.focus();
          return;
        }
        var foundCust = store.getCustomers().find(function (c) {
          return c.name.toLowerCase() === cName.toLowerCase() || (c.nameTe && c.nameTe === cName);
        });
        if (foundCust) {
          customerId = foundCust.id;
        } else {
          var newC = store.addCustomer({ name: cName, nameTe: '', phone: '' });
          customerId = newC.id;
        }
      }

      // Resolve Item
      var itemId = null;
      if (curType !== 'pay') {
        if (iName) {
          var foundItem = store.getItems().find(function (i) {
            return i.name.toLowerCase() === iName.toLowerCase() || (i.nameTe && i.nameTe === iName);
          });
          if (foundItem) {
            itemId = foundItem.id;
          }
        }
      }

      var entryData = {
        type: curType,
        customerId: customerId,
        itemId: itemId,
        qty: !isNaN(qNum) ? qNum : null,
        unit: curUnit,
        amount: amt,
        spokenText: rawText || (cName ? cName + ' ' : '') + (iName ? iName + ' ' : '') + amt + ' rs'
      };

      if (editEntry) {
        // Edit mode: delete old entry and add revised one
        store.deleteEntry(editEntry.id);
      }

      store.addEntry(entryData);
      router.toast('Saved · సేవ్ చేయబడింది');
      router.navigate('home', {}, true);
    });

    syncFields();
    return el;
  }

  window.LOG.screens.confirm = {
    render: render
  };
})(window);
