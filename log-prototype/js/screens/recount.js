/**
 * LOG - Weekly Recount Screen (Hidden Screen)
 * Route: #/recount
 * Review stock inventory 1 item at a time with Telugu & English prompts.
 * Prompts: "బియ్యం 12 కిలోలు ఉన్నాయా?" / "Rice 12 kg undha?"
 * Buttons: "అవును · Yes" and "మార్చు · Edit"
 * Summary view at the end of recount.
 * Marks weekly check as done and navigates to Stock.
 */
(function (window) {
  'use strict';

  function render(params) {
    var store = window.LOG.store;
    var router = window.LOG.router;

    var el = document.createElement('div');
    el.className = 'screen recount-screen';

    var items = store.getItems();
    if (!items || items.length === 0) {
      el.innerHTML = `
        <div class="top">
          <button class="ib" id="btnBack" aria-label="Back">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
          </button>
          <h1>Weekly recount<span>వారం వారీ లెక్క</span></h1>
        </div>
        <div class="scroll" style="display:flex;align-items:center;justify-content:center;text-align:center;padding:32px">
          <div>
            <p style="color:var(--muted)">No items found in inventory.</p>
            <button class="btn fill" id="btnEmptyDone" style="margin-top:16px">Back to Stock</button>
          </div>
        </div>
      `;
      el.querySelector('#btnBack').addEventListener('click', function () { router.navigate('stock'); });
      el.querySelector('#btnEmptyDone').addEventListener('click', function () { router.navigate('stock'); });
      return el;
    }

    var currentIndex = 0;
    var changes = []; // Array of { item, oldQty, newQty, confirmed: boolean }
    var isEditing = false;

    function renderStep() {
      // If completed all items, show Summary
      if (currentIndex >= items.length) {
        renderSummary();
        return;
      }

      var currentItem = items[currentIndex];
      var progressNum = currentIndex + 1;
      var totalNum = items.length;
      var pct = Math.round((progressNum / totalNum) * 100);

      el.innerHTML = `
        <div class="top">
          <button class="ib" id="btnBack" aria-label="Back">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
          </button>
          <h1>Weekly recount<span>వారం వారీ లెక్క</span></h1>
        </div>

        <div class="scroll" style="padding:16px 20px 24px;display:flex;flex-direction:column">
          <!-- Progress bar -->
          <div style="margin-bottom:20px">
            <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
              <span style="font:500 13px var(--f);letter-spacing:0.04em;text-transform:uppercase;color:var(--accent)">
                Item ${progressNum} of ${totalNum}
              </span>
              <span style="font:400 13px var(--te);color:var(--muted)">
                ${progressNum} / ${totalNum} వస్తువులు
              </span>
            </div>
            <div style="height:6px;background:var(--line);border-radius:3px;overflow:hidden">
              <div style="height:100%;width:${pct}%;background:var(--accent);transition:width 0.25s"></div>
            </div>
          </div>

          <!-- Question Card -->
          <div class="card" style="background:var(--container);border-radius:24px;padding:24px 20px;text-align:center;margin-bottom:20px;border:1px solid var(--line);box-shadow:0 4px 12px rgba(0,0,0,0.03)">
            <div style="width:64px;height:64px;border-radius:50%;background:var(--accent-tonal);color:var(--accent);display:grid;place-items:center;margin:0 auto 16px">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 8 12 3 3 8v8l9 5 9-5zM3 8l9 5 9-5M12 13v8"/>
              </svg>
            </div>

            <div style="font:500 20px var(--f);margin-bottom:4px">
              ${escapeHtml(currentItem.name)}
              <span style="font:400 17px var(--te);color:var(--muted);margin-left:6px">${escapeHtml(currentItem.nameTe || '')}</span>
            </div>

            <div style="margin:16px 0 12px;font:700 24px/1.3 var(--te);color:var(--fg)">
              “${escapeHtml(currentItem.nameTe || currentItem.name)} ${currentItem.qty} ${escapeHtml(currentItem.unit)} ఉన్నాయా?”
            </div>

            <div style="font:500 15px var(--f);color:var(--muted);margin-bottom:16px">
              ${escapeHtml(currentItem.name)} ${currentItem.qty} ${escapeHtml(currentItem.unit)} undha?
            </div>

            <div style="display:inline-block;padding:8px 20px;border-radius:16px;background:var(--surface);border:1.5px solid var(--outline);font:700 22px var(--f);color:var(--accent)">
              ${currentItem.qty} <span style="font:500 16px var(--f);color:var(--muted)">${escapeHtml(currentItem.unit)}</span>
            </div>
          </div>

          <!-- Dynamic Action Area -->
          <div id="actionArea">
            ${isEditing ? `
              <div style="background:var(--surface);border:1.5px solid var(--accent);border-radius:20px;padding:16px;margin-bottom:16px">
                <div style="font:500 14px var(--f);color:var(--muted);margin-bottom:8px;text-align:center">
                  Enter real count in shop · నిజమైన లెక్క
                </div>
                <div style="display:flex;align-items:center;justify-content:center;gap:12px;margin-bottom:16px">
                  <button type="button" class="ib" id="btnMinus" style="border:1px solid var(--outline);width:44px;height:44px">-</button>
                  <input type="number" step="any" min="0" id="inEditQty" class="in" style="width:120px;text-align:center;font:700 20px var(--f)" value="${currentItem.qty}">
                  <button type="button" class="ib" id="btnPlus" style="border:1px solid var(--outline);width:44px;height:44px">+</button>
                  <span style="font:500 16px var(--f);color:var(--muted)">${escapeHtml(currentItem.unit)}</span>
                </div>
                <div class="srow">
                  <button type="button" class="btn" id="btnCancelEdit">Cancel</button>
                  <button type="button" class="btn fill" id="btnSaveEdit">Save & Next · సేవ్ చేయి</button>
                </div>
              </div>
            ` : `
              <div style="display:flex;flex-direction:column;gap:12px">
                <button type="button" class="btn fill" id="btnYes" style="font-size:17px;height:56px">
                  అవును · Yes (Confirm ${currentItem.qty} ${escapeHtml(currentItem.unit)})
                </button>
                <button type="button" class="btn" id="btnEdit" style="font-size:16px;height:52px">
                  మార్చు · Edit count
                </button>
              </div>
            `}
          </div>
        </div>
      `;

      // Event listeners
      el.querySelector('#btnBack').addEventListener('click', function () {
        router.back();
      });

      if (!isEditing) {
        el.querySelector('#btnYes').addEventListener('click', function () {
          changes.push({
            item: currentItem,
            oldQty: currentItem.qty,
            newQty: currentItem.qty,
            confirmed: true
          });
          currentIndex++;
          renderStep();
        });

        el.querySelector('#btnEdit').addEventListener('click', function () {
          isEditing = true;
          renderStep();
        });
      } else {
        var inQty = el.querySelector('#inEditQty');
        var btnMinus = el.querySelector('#btnMinus');
        var btnPlus = el.querySelector('#btnPlus');

        btnMinus.addEventListener('click', function () {
          var val = parseFloat(inQty.value) || 0;
          inQty.value = Math.max(0, Math.round((val - 1) * 10) / 10);
        });

        btnPlus.addEventListener('click', function () {
          var val = parseFloat(inQty.value) || 0;
          inQty.value = Math.round((val + 1) * 10) / 10;
        });

        el.querySelector('#btnCancelEdit').addEventListener('click', function () {
          isEditing = false;
          renderStep();
        });

        el.querySelector('#btnSaveEdit').addEventListener('click', function () {
          var newQty = parseFloat(inQty.value);
          if (isNaN(newQty) || newQty < 0) {
            inQty.focus();
            return;
          }

          // If changed, persist to store
          if (newQty !== currentItem.qty) {
            store.addEntry({
              type: 'count',
              itemId: currentItem.id,
              customerId: null,
              qty: newQty,
              unit: currentItem.unit,
              amount: 0,
              spokenText: 'Weekly recount: ' + currentItem.name + ' set to ' + newQty + ' ' + currentItem.unit
            });
            store.updateItem(currentItem.id, { qty: newQty });
            changes.push({
              item: currentItem,
              oldQty: currentItem.qty,
              newQty: newQty,
              confirmed: false
            });
          } else {
            changes.push({
              item: currentItem,
              oldQty: currentItem.qty,
              newQty: currentItem.qty,
              confirmed: true
            });
          }

          isEditing = false;
          currentIndex++;
          renderStep();
        });
      }
    }

    function renderSummary() {
      var updatedCount = changes.filter(function (c) { return !c.confirmed; }).length;
      var confirmedCount = changes.filter(function (c) { return c.confirmed; }).length;

      el.innerHTML = `
        <div class="top">
          <button class="ib" id="btnBackSum" aria-label="Back">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
          </button>
          <h1>Weekly recount<span>వారం వారీ లెక్క</span></h1>
        </div>

        <div class="scroll" style="padding:16px 20px 24px">
          <!-- Celebration Card -->
          <div style="background:var(--accent-tonal);color:var(--accent);border-radius:24px;padding:24px 20px;text-align:center;margin-bottom:20px">
            <div style="width:56px;height:56px;border-radius:50%;background:var(--accent);color:var(--on-accent);display:grid;place-items:center;margin:0 auto 12px">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M20 6L9 17l-5-5"/>
              </svg>
            </div>
            <div style="font:700 20px var(--f)">Check complete! · పూర్తయింది</div>
            <div style="font:400 14px var(--f);margin-top:4px;color:var(--fg)">
              All ${items.length} items reviewed. ${confirmedCount} confirmed, ${updatedCount} updated.
            </div>
          </div>

          <div class="gl">Summary of changes<span>వివరాలు</span></div>
          <div class="grp" style="margin-bottom:24px">
            ${changes.map(function (c) {
              return `
                <div class="row" style="cursor:default">
                  <span class="ic" style="background:${c.confirmed ? 'color-mix(in srgb,var(--good) 15%,transparent)' : 'color-mix(in srgb,var(--accent) 15%,transparent)'};color:${c.confirmed ? 'var(--good)' : 'var(--accent)'}">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      ${c.confirmed ? '<path d="M20 6L9 17l-5-5"/>' : '<path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>'}
                    </svg>
                  </span>
                  <span class="tx">
                    <div class="t">${escapeHtml(c.item.name)}<span>${escapeHtml(c.item.nameTe || '')}</span></div>
                    <div class="s">${c.confirmed ? 'Count confirmed' : 'Corrected from ' + c.oldQty + ' ' + c.item.unit}</div>
                  </span>
                  <span class="v" style="font-weight:700;color:${c.confirmed ? 'var(--fg)' : 'var(--accent)'}">
                    ${c.newQty} ${escapeHtml(c.item.unit)}
                  </span>
                </div>
              `;
            }).join('')}
          </div>

          <button type="button" class="btn fill" id="btnDoneRecount" style="width:100%;height:54px;font-size:17px">
            Done · పూర్తి
          </button>
        </div>
      `;

      el.querySelector('#btnBackSum').addEventListener('click', function () {
        router.navigate('stock');
      });

      el.querySelector('#btnDoneRecount').addEventListener('click', function () {
        store.setWeeklyCheckDone(true);
        router.showToast('Weekly stock check marked done · లెక్క పూర్తయింది');
        router.navigate('stock');
      });
    }

    renderStep();
    return el;
  }

  function escapeHtml(str) {
    if (!str) return '';
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  window.LOG = window.LOG || {};
  window.LOG.screens = window.LOG.screens || {};
  window.LOG.screens.recount = { render: render };
})(window);
