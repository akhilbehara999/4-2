/**
 * LOG Prototype - Customers Screen (#/customers)
 * Alphabetical customer directory with balance tracking, FAB to add,
 * and bottom sheet to add or edit.
 */

(function (window) {
  'use strict';

  function render() {
    var store = window.LOG.store;
    var engine = window.LOG.engine;
    var router = window.LOG.router;

    var el = document.createElement('div');
    el.className = 'screen customers-screen';
    el.style.cssText = 'position:relative;display:flex;flex-direction:column;min-height:100%';

    el.innerHTML = [
      '<div class="top">',
      '  <button class="ib" id="cst-back" aria-label="Back" type="button"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg></button>',
      '  <h1>Customers<span>కస్టమర్లు</span></h1>',
      '</div>',
      '<div style="padding:4px 16px 0;flex:none">',
      '  <div class="search">',
      '    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>',
      '    <input id="cst-q" type="search" placeholder="Search name or phone · వెతకండి" aria-label="Search customers">',
      '  </div>',
      '  <div class="chips" id="cst-chips" role="group" aria-label="Filter" style="margin-top:10px">',
      '    <button class="chip" data-f="all" aria-pressed="true" type="button">All</button>',
      '    <button class="chip" data-f="owe" aria-pressed="false" type="button">Owes money</button>',
      '    <button class="chip" data-f="clear" aria-pressed="false" type="button">Settled</button>',
      '  </div>',
      '</div>',
      '<div id="cst-count" style="padding:10px 20px 4px;font:400 13px var(--f);color:var(--muted);flex:none"></div>',
      '<div class="scroll" id="cst-scroll" style="padding-bottom:86px"></div>',
      '<button class="fab" id="cst-fab" type="button"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>Add customer</button>',
      '<!-- Add / Edit Customer Bottom Sheet -->',
      '<div class="sheet" id="cst-sheet" role="dialog" aria-label="Customer">',
      '  <div class="grab"></div>',
      '  <h3 id="cst-sheet-title">Add customer<span>కొత్త కస్టమర్</span></h3>',
      '  <div class="fld"><label for="cst-fn">Name</label><input class="in" id="cst-fn" autocomplete="off" placeholder="e.g. Suresh"></div>',
      '  <div id="cst-fmsg" style="font:400 13px var(--f);color:var(--red);margin:-6px 4px 10px;display:none"></div>',
      '  <div class="fld"><label for="cst-ft">Name in Telugu · తెలుగులో పేరు</label><input class="in" id="cst-ft" autocomplete="off" placeholder="సురేష్"></div>',
      '  <div class="fld"><label for="cst-fp">Phone number (optional)</label><input class="in" id="cst-fp" inputmode="tel" autocomplete="off" placeholder="+91 98XXX XXXXX"></div>',
      '  <p style="font:400 13px var(--f);color:var(--muted);margin:0 4px 14px">The Telugu name helps the app recognise it when you say it.</p>',
      '  <div class="srow"><button class="btn" id="cst-fcancel" type="button">Cancel</button><button class="btn fill" id="cst-fsave" type="button">Save</button></div>',
      '  <div class="danger" id="cst-danger"></div>',
      '</div>'
    ].join('\n');

    el.querySelector('#cst-back').addEventListener('click', function () {
      router.back();
    });

    var filt = 'all';
    var query = '';
    var activeCust = null;

    var countEl = el.querySelector('#cst-count');
    var scrollBox = el.querySelector('#cst-scroll');
    var qInput = el.querySelector('#cst-q');
    var fabBtn = el.querySelector('#cst-fab');

    var sheet = el.querySelector('#cst-sheet');
    var sheetTitle = el.querySelector('#cst-sheet-title');
    var fnIn = el.querySelector('#cst-fn');
    var ftIn = el.querySelector('#cst-ft');
    var fpIn = el.querySelector('#cst-fp');
    var fMsg = el.querySelector('#cst-fmsg');
    var dangerBox = el.querySelector('#cst-danger');

    function renderList() {
      var customers = store.getCustomers().slice();
      var enriched = customers.map(function (c) {
        return {
          id: c.id,
          name: c.name,
          nameTe: c.nameTe,
          phone: c.phone,
          balance: engine.getCustomerBalance(c.id)
        };
      });

      var s = query.toLowerCase();
      var filtered = enriched.filter(function (c) {
        if (filt === 'owe' && c.balance <= 0) return false;
        if (filt === 'clear' && c.balance > 0) return false;
        if (!s) return true;
        var pClean = (c.phone || '').replace(/\s+/g, '');
        var sClean = s.replace(/\s+/g, '');
        return c.name.toLowerCase().indexOf(s) > -1 || (c.nameTe && c.nameTe.indexOf(query) > -1) || pClean.indexOf(sClean) > -1;
      });

      filtered.sort(function (a, b) {
        return a.name.localeCompare(b.name);
      });

      var oweCount = enriched.filter(function (c) { return c.balance > 0; }).length;
      countEl.textContent = enriched.length + ' customers · ' + oweCount + ' owe money';

      scrollBox.innerHTML = '';
      if (!filtered.length) {
        var emptyEl = document.createElement('div');
        emptyEl.style.cssText = 'padding:40px 0;text-align:center;color:var(--muted);font-size:14px';
        emptyEl.textContent = 'No customers match.';
        scrollBox.appendChild(emptyEl);
        return;
      }

      var curHeader = null;
      var curUl = null;

      filtered.forEach(function (c) {
        var letter = c.name[0].toUpperCase();
        if (letter !== curHeader) {
          curHeader = letter;
          var gh = document.createElement('div');
          gh.className = 'gh';
          gh.textContent = letter;
          scrollBox.appendChild(gh);

          curUl = document.createElement('ul');
          curUl.className = 'list';
          scrollBox.appendChild(curUl);
        }

        var li = document.createElement('li');
        var rowBtn = document.createElement('button');
        rowBtn.type = 'button';
        rowBtn.className = 'row';
        rowBtn.style.cssText = 'display:flex;align-items:center;gap:14px;padding:10px 4px;border-bottom:1px solid var(--line);width:100%;background:none;border-left:0;border-right:0;border-top:0;color:inherit;font:inherit;text-align:left;cursor:pointer;border-radius:12px';

        var rightHtml = c.balance > 0 ?
          '<div style="text-align:right;flex:none;font-variant-numeric:tabular-nums"><b style="display:block;font:700 16px var(--f);color:var(--orange)">' + engine.inr(c.balance) + '</b><small style="font:400 12px var(--f);color:var(--muted)">owes</small></div>' :
          '<div style="text-align:right;flex:none"><span style="font:500 13px var(--f);color:var(--good)">Settled</span></div>';

        rowBtn.innerHTML = [
          '<span style="width:44px;height:44px;border-radius:50%;background:var(--accent-tonal);color:var(--accent);display:grid;place-items:center;font:500 18px var(--f);flex:none">' + letter + '</span>',
          '<span style="flex:1;min-width:0">',
          '  <div style="font:500 16px var(--f);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">' + c.name + (c.nameTe ? '<span style="font:400 14px var(--te);color:var(--muted);margin-left:6px">' + c.nameTe + '</span>' : '') + '</div>',
          '  <div style="font:400 13px var(--f);color:var(--muted);font-variant-numeric:tabular-nums">' + (c.phone || 'No phone number') + '</div>',
          '</span>',
          rightHtml
        ].join('\n');

        rowBtn.addEventListener('click', function () {
          if (c.balance > 0) {
            router.navigate('udhar-detail', { customerId: c.id });
          } else {
            openSheet(c);
          }
        });

        li.appendChild(rowBtn);
        curUl.appendChild(li);
      });
    }

    function openSheet(c) {
      activeCust = c;
      sheetTitle.innerHTML = c ? 'Edit customer<span>మార్చు</span>' : 'Add customer<span>కొత్త కస్టమర్</span>';
      fnIn.value = c ? c.name : '';
      ftIn.value = c ? (c.nameTe || '') : '';
      fpIn.value = c ? (c.phone || '') : '';
      fMsg.style.display = 'none';
      fnIn.classList.remove('bad');

      dangerBox.innerHTML = '';
      if (c) {
        var delBtn = document.createElement('button');
        delBtn.type = 'button';
        delBtn.className = 'dbtn';
        delBtn.textContent = 'Delete customer';
        delBtn.addEventListener('click', function () {
          dangerBox.innerHTML = [
            '<div class="confirm">',
            '  <span>Delete customer and their history?</span>',
            '  <button class="dbtn" id="cst-d-no" type="button" style="color:var(--fg)">Cancel</button>',
            '  <button class="dbtn yes" id="cst-d-yes" type="button">Delete</button>',
            '</div>'
          ].join('\n');

          dangerBox.querySelector('#cst-d-no').addEventListener('click', function () { openSheet(activeCust); });
          dangerBox.querySelector('#cst-d-yes').addEventListener('click', function () {
            store.deleteCustomer(activeCust.id);
            router.closeSheet();
            router.toast('Customer deleted');
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

    el.querySelector('#cst-fcancel').addEventListener('click', function () {
      router.closeSheet();
    });

    el.querySelector('#cst-fsave').addEventListener('click', function () {
      var n = fnIn.value.trim();
      if (!n) {
        fMsg.textContent = 'Enter a name.';
        fMsg.style.display = 'block';
        fnIn.classList.add('bad');
        fnIn.focus();
        return;
      }

      var dup = store.getCustomers().some(function (c) {
        return (!activeCust || c.id !== activeCust.id) && c.name.toLowerCase() === n.toLowerCase();
      });

      if (dup) {
        fMsg.textContent = 'A customer named ' + n + ' already exists.';
        fMsg.style.display = 'block';
        fnIn.classList.add('bad');
        return;
      }

      if (activeCust) {
        store.updateCustomer(activeCust.id, {
          name: n,
          nameTe: ftIn.value.trim(),
          phone: fpIn.value.trim()
        });
        router.toast('Customer updated · మార్చబడింది');
      } else {
        store.addCustomer({
          name: n,
          nameTe: ftIn.value.trim(),
          phone: fpIn.value.trim()
        });
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

  window.LOG.screens.customers = {
    render: render
  };
})(window);
