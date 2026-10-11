/**
 * LOG Prototype - Udhar Detail Screen (#/udhar/:customerId)
 * Single customer ledger, balance card, payment sheet, remind copying, and edit customer sheet.
 */

(function (window) {
  'use strict';

  function render(params) {
    var store = window.LOG.store;
    var engine = window.LOG.engine;
    var router = window.LOG.router;

    params = params || {};
    var customerId = params.customerId || 'c1';
    var customer = store.getCustomerById(customerId);

    if (!customer) {
      customer = store.getCustomers()[0] || { id: 'c1', name: 'Ramesh', nameTe: 'రామేష్', phone: '+91 98480 12345' };
      customerId = customer.id;
    }

    var el = document.createElement('div');
    el.className = 'screen udhar-detail-screen';

    var balance = engine.getCustomerBalance(customerId);
    var totals = engine.getCustomerTotals(customerId);
    var lastDays = engine.getCustomerLastEntryDays(customerId);
    var isOverdue = engine.isCustomerOverdue(customerId);

    el.innerHTML = [
      '<div class="top">',
      '  <button class="ib" id="ud-back" aria-label="Back" type="button"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg></button>',
      '  <button class="ib" id="ud-edit-btn" aria-label="Edit customer" type="button"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"/></svg></button>',
      '</div>',
      '<div class="scroll">',
      '  <!-- Customer Header -->',
      '  <div class="who" style="display:flex;align-items:center;gap:14px;padding:0 4px 14px">',
      '    <div id="ud-av" style="width:64px;height:64px;border-radius:50%;background:var(--accent-tonal);color:var(--accent);display:grid;place-items:center;font:500 28px var(--f);flex:none">' + customer.name[0].toUpperCase() + '</div>',
      '    <div>',
      '      <h1 id="ud-name" style="margin:0;font:500 24px/1.2 var(--f)">' + customer.name + '</h1>',
      '      <div id="ud-nte" style="font:400 16px var(--te);color:var(--muted)">' + (customer.nameTe || '') + '</div>',
      '      <div id="ud-phone" style="font:400 14px var(--f);color:var(--muted);font-variant-numeric:tabular-nums;margin-top:2px">' + (customer.phone || 'No phone number') + '</div>',
      '    </div>',
      '  </div>',
      '  <!-- Balance Panel -->',
      '  <section class="bal" id="ud-bal" style="border-radius:28px;padding:18px 20px;background:' + (balance === 0 ? 'var(--good-tonal)' : 'var(--orange-tonal)') + ';display:flex;flex-direction:column;gap:6px" aria-label="Balance">',
      '    <div style="font:500 13px var(--f);letter-spacing:.04em;text-transform:uppercase;color:var(--muted)">' + (balance === 0 ? 'All settled' : 'Owes you') + '<span style="font-family:var(--te);text-transform:none;letter-spacing:0;margin-left:6px">' + (balance === 0 ? 'బాకీ లేదు' : 'ఇవ్వవలసినది') + '</span></div>',
      '    <div style="font:700 38px/1.1 var(--f);font-variant-numeric:tabular-nums;letter-spacing:-.01em;color:var(--fg)">' + engine.inr(balance) + '</div>',
      '    <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;font-size:14px;color:var(--muted)">',
      '      <span class="badge ' + (balance === 0 || !isOverdue ? 'ok' : '') + '" style="background:' + (balance === 0 || !isOverdue ? 'var(--good-tonal)' : 'var(--red-tonal)') + ';color:' + (balance === 0 || !isOverdue ? 'var(--good)' : 'var(--red)') + ';border-radius:8px;padding:2px 10px;font:500 12px var(--f)">' + (balance === 0 ? 'Settled' : (isOverdue ? 'Overdue' : 'On track')) + '</span>',
      '      <span>' + (balance === 0 ? 'Nothing to collect' : (lastDays === 0 ? 'Last entry today' : 'Last entry ' + lastDays + ' days ago')) + '</span>',
      '    </div>',
      '  </section>',
      '  <!-- Action Buttons -->',
      '  <div class="acts" style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:12px">',
      '    <button class="btn fill" id="ud-pay-btn" type="button" style="grid-column:1/-1;height:56px;font-size:17px"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12l7 7 7-7"/></svg>జమ · Payment received</button>',
      '    <button class="btn" id="ud-add-btn" type="button"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>Add udhar</button>',
      '    <button class="btn" id="ud-rem-btn" type="button"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 0 1-3.4 0"/></svg>Remind</button>',
      '  </div>',
      '  <!-- Total given & paid -->',
      '  <div class="tot" style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-top:14px">',
      '    <div style="background:var(--container);border-radius:16px;padding:12px 14px"><small style="display:block;font:500 12px var(--f);letter-spacing:.03em;text-transform:uppercase;color:var(--muted)">Total given</small><b style="font:700 18px var(--f);font-variant-numeric:tabular-nums">' + engine.inr(totals.totalGiven) + '</b></div>',
      '    <div style="background:var(--container);border-radius:16px;padding:12px 14px"><small style="display:block;font:500 12px var(--f);letter-spacing:.03em;text-transform:uppercase;color:var(--muted)">Total paid</small><b style="font:700 18px var(--f);font-variant-numeric:tabular-nums">' + engine.inr(totals.totalPaid) + '</b></div>',
      '  </div>',
      '  <!-- History ledger -->',
      '  <div class="sec" style="display:flex;justify-content:space-between;align-items:baseline;margin:20px 4px 4px">',
      '    <h2 style="margin:0;font:500 18px var(--f)">History<span style="font:400 14px var(--te);color:var(--muted);margin-left:6px">చరిత్ర</span></h2>',
      '    <small style="font:400 12px var(--f);color:var(--muted)">Newest first</small>',
      '  </div>',
      '  <ul class="list" id="ud-history-list"></ul>',
      '</div>',
      '<!-- Payment Received Bottom Sheet -->',
      '<div class="sheet" id="ud-pay-sheet" role="dialog" aria-label="Payment received">',
      '  <div class="grab"></div><h3>Payment received<span>జమ</span></h3>',
      '  <div class="chips" id="ud-quick-chips" style="margin-bottom:10px;overflow-x:auto"></div>',
      '  <div class="fld"><label for="ud-pay-amt">Amount received</label><div style="position:relative"><b style="position:absolute;left:16px;top:0;height:64px;display:flex;align-items:center;font:700 24px var(--f);color:var(--muted)">₹</b><input class="in" id="ud-pay-amt" inputmode="numeric" placeholder="0" autocomplete="off" style="height:64px;padding-left:38px;font:700 26px var(--f);font-variant-numeric:tabular-nums"></div></div>',
      '  <div id="ud-pay-msg" style="font:400 13px var(--f);color:var(--muted);margin:6px 4px 14px;min-height:18px"></div>',
      '  <div class="srow"><button class="btn" id="ud-pay-cancel" type="button">Cancel</button><button class="btn fill" id="ud-pay-save" type="button" disabled>Save payment</button></div>',
      '</div>',
      '<!-- Edit Customer Bottom Sheet -->',
      '<div class="sheet" id="ud-edit-sheet" role="dialog" aria-label="Edit customer">',
      '  <div class="grab"></div><h3>Edit customer<span>మార్చు</span></h3>',
      '  <div class="fld"><label for="ud-en">Name</label><input class="in" id="ud-en" value="' + customer.name + '" autocomplete="off"></div>',
      '  <div class="fld"><label for="ud-et">Name in Telugu · తెలుగులో పేరు</label><input class="in" id="ud-et" value="' + (customer.nameTe || '') + '" autocomplete="off"></div>',
      '  <div class="fld"><label for="ud-ep">Phone number</label><input class="in" id="ud-ep" inputmode="tel" value="' + (customer.phone || '') + '" autocomplete="off"></div>',
      '  <div class="srow"><button class="btn" id="ud-edit-cancel" type="button">Cancel</button><button class="btn fill" id="ud-edit-save" type="button">Save</button></div>',
      '  <div class="danger" id="ud-danger"></div>',
      '</div>',
      '<!-- Fallback Remind Message Sheet -->',
      '<div class="sheet" id="ud-rem-sheet" role="dialog" aria-label="Reminder message">',
      '  <div class="grab"></div><h3>Reminder message<span>బాకీ సందేశం</span></h3>',
      '  <div class="fld"><label>Telugu reminder</label><textarea class="in" id="ud-rem-text" rows="3" readonly style="height:auto;padding:12px 14px;font:400 16px var(--te);resize:none"></textarea></div>',
      '  <div class="srow"><button class="btn fill" id="ud-rem-close" type="button">Done · పూర్తి</button></div>',
      '</div>'
    ].join('\n');

    el.querySelector('#ud-back').addEventListener('click', function () {
      router.back();
    });

    // Populate history ledger
    var historyList = el.querySelector('#ud-history-list');
    var rows = engine.getCustomerHistory(customerId);

    rows.forEach(function (r) {
      var entry = r.entry;
      var li = document.createElement('li');
      li.style.cssText = 'display:flex;gap:12px;align-items:center;padding:12px 4px;border-bottom:1px solid var(--line)';

      var isCredit = entry.type === 'credit';
      var icColor = isCredit ? 'var(--orange)' : 'var(--blue)';
      var icSvg = isCredit ?
        '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 6v6l4 2M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0"/></svg>' :
        '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12l7 7 7-7"/></svg>';

      var itObj = entry.itemId ? store.getItemById(entry.itemId) : null;
      var itemTitle = itObj ? itObj.name : (isCredit ? 'Credit given' : 'Payment received');
      var dateFormatted = new Date(entry.createdAt).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' });

      li.innerHTML = [
        '<span style="width:36px;height:36px;border-radius:50%;display:grid;place-items:center;flex:none;background:color-mix(in srgb,' + icColor + ' 16%,transparent);color:' + icColor + '">' + icSvg + '</span>',
        '<div style="flex:1;min-width:0">',
        '  <div style="font:500 15px var(--f);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + itemTitle + (entry.qty ? ' <em style="font-style:normal;color:var(--muted);font-weight:400">(' + entry.qty + ' ' + (entry.unit || '') + ')</em>' : '') + '</div>',
        '  <div style="font:italic 13px var(--te);color:var(--muted);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">“' + (entry.spokenText || '') + '”</div>',
        '  <div style="font:400 12px var(--f);color:var(--muted)">' + dateFormatted + '</div>',
        '</div>',
        '<div style="text-align:right;flex:none">',
        '  <div style="font:700 15px var(--f);font-variant-numeric:tabular-nums;color:' + (isCredit ? 'var(--fg)' : 'var(--blue)') + '">' + (isCredit ? '+' : '−') + engine.inr(entry.amount) + '</div>',
        '  <div style="font:400 12px var(--f);color:var(--muted);font-variant-numeric:tabular-nums">Bal ' + engine.inr(r.runningBalance) + '</div>',
        '</div>'
      ].join('\n');

      historyList.appendChild(li);
    });

    // Add udhar button -> confirm screen with Credit & customer preselected
    el.querySelector('#ud-add-btn').addEventListener('click', function () {
      router.navigate('confirm', {
        type: 'credit',
        customer: customer.name
      });
    });

    // Remind message logic
    el.querySelector('#ud-rem-btn').addEventListener('click', function () {
      var shopNameTe = store.getState().settings.shopNameTe || store.getState().settings.shopName || 'మా కిరాణా';
      var reminderText = customer.nameTe ?
        (customer.nameTe + ', మీ బాకీ ' + engine.inr(balance) + '. దయచేసి చెల్లించండి. – ' + shopNameTe) :
        (customer.name + ', మీ బాకీ ' + engine.inr(balance) + '. దయచేసి చెల్లించండి. – ' + shopNameTe);

      try {
        if (navigator.clipboard && typeof navigator.clipboard.writeText === 'function') {
          navigator.clipboard.writeText(reminderText).then(function () {
            router.toast('Reminder copied · కాపీ చేయబడింది');
          }).catch(function () {
            showRemindSheet(reminderText);
          });
        } else {
          showRemindSheet(reminderText);
        }
      } catch (err) {
        showRemindSheet(reminderText);
      }
    });

    function showRemindSheet(msg) {
      var remSheet = el.querySelector('#ud-rem-sheet');
      el.querySelector('#ud-rem-text').value = msg;
      router.openSheet(remSheet);
    }

    el.querySelector('#ud-rem-close').addEventListener('click', function () {
      router.closeSheet();
    });

    // Payment sheet logic
    var paySheet = el.querySelector('#ud-pay-sheet');
    var payAmtIn = el.querySelector('#ud-pay-amt');
    var payMsg = el.querySelector('#ud-pay-msg');
    var paySave = el.querySelector('#ud-pay-save');
    var payCancel = el.querySelector('#ud-pay-cancel');
    var quickContainer = el.querySelector('#ud-quick-chips');

    function checkPayment() {
      var v = parseInt(payAmtIn.value.replace(/[^\d]/g, ''), 10) || 0;
      if (!v) {
        payMsg.style.color = 'var(--muted)';
        payMsg.textContent = 'Enter the amount the customer paid.';
        paySave.disabled = true;
      } else if (v > balance) {
        payMsg.style.color = 'var(--red)';
        payMsg.textContent = 'That is more than the balance of ' + engine.inr(balance) + '.';
        paySave.disabled = true;
      } else {
        payMsg.style.color = 'var(--muted)';
        payMsg.textContent = 'New balance: ' + engine.inr(balance - v);
        paySave.disabled = false;
      }
    }

    el.querySelector('#ud-pay-btn').addEventListener('click', function () {
      if (balance <= 0) {
        router.toast('All settled! No balance due.');
        return;
      }
      payAmtIn.value = '';
      quickContainer.innerHTML = '';

      var quickVals = [
        ['Full ' + engine.inr(balance), balance],
        ['₹500', 500],
        ['₹1,000', 1000]
      ];

      quickVals.forEach(function (q) {
        if (q[1] > balance || q[1] <= 0) return;
        var chip = document.createElement('button');
        chip.type = 'button';
        chip.className = 'chip';
        chip.textContent = q[0];
        chip.addEventListener('click', function () {
          payAmtIn.value = q[1];
          checkPayment();
        });
        quickContainer.appendChild(chip);
      });

      checkPayment();
      router.openSheet(paySheet, el.querySelector('#ud-pay-btn'));
    });

    payAmtIn.addEventListener('input', checkPayment);
    payCancel.addEventListener('click', function () { router.closeSheet(); });

    paySave.addEventListener('click', function () {
      var v = parseInt(payAmtIn.value.replace(/[^\d]/g, ''), 10) || 0;
      if (!v || v > balance) return;

      store.addEntry({
        type: 'pay',
        customerId: customerId,
        itemId: null,
        amount: v,
        spokenText: customer.name + ' ' + v + ' రూపాయలు ఇచ్చాడు'
      });

      router.closeSheet();
      router.toast('Saved · ' + engine.inr(v) + ' received');
      render(params); // Re-render live
    });

    // Edit customer sheet logic
    var editSheet = el.querySelector('#ud-edit-sheet');
    var enIn = el.querySelector('#ud-en');
    var etIn = el.querySelector('#ud-et');
    var epIn = el.querySelector('#ud-ep');
    var dangerBox = el.querySelector('#ud-danger');

    function renderDangerInitial() {
      dangerBox.innerHTML = '';
      var delBtn = document.createElement('button');
      delBtn.type = 'button';
      delBtn.className = 'dbtn';
      delBtn.textContent = 'Delete customer';
      delBtn.addEventListener('click', function () {
        dangerBox.innerHTML = [
          '<div class="confirm">',
          '  <span>Delete and remove ' + rows.length + ' entries?</span>',
          '  <button class="dbtn" id="dc-cancel" type="button" style="color:var(--fg)">Cancel</button>',
          '  <button class="dbtn yes" id="dc-yes" type="button">Delete</button>',
          '</div>'
        ].join('\n');

        dangerBox.querySelector('#dc-cancel').addEventListener('click', renderDangerInitial);
        dangerBox.querySelector('#dc-yes').addEventListener('click', function () {
          store.deleteCustomer(customerId);
          router.closeSheet();
          router.toast('Customer deleted · తొలగించబడింది');
          router.navigate('udhar', {}, true);
        });
      });
      dangerBox.appendChild(delBtn);
    }

    el.querySelector('#ud-edit-btn').addEventListener('click', function () {
      enIn.value = customer.name;
      etIn.value = customer.nameTe || '';
      epIn.value = customer.phone || '';
      renderDangerInitial();
      router.openSheet(editSheet, el.querySelector('#ud-edit-btn'));
    });

    el.querySelector('#ud-edit-cancel').addEventListener('click', function () { router.closeSheet(); });

    el.querySelector('#ud-edit-save').addEventListener('click', function () {
      var nVal = enIn.value.trim();
      if (!nVal) { enIn.focus(); return; }

      store.updateCustomer(customerId, {
        name: nVal,
        nameTe: etIn.value.trim(),
        phone: epIn.value.trim()
      });

      router.closeSheet();
      router.toast('Customer updated · మార్చబడింది');
      render(params);
    });

    return el;
  }

  window.LOG.screens['udhar-detail'] = {
    render: render
  };
})(window);
