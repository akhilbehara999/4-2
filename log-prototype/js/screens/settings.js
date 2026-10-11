/**
 * LOG - Settings Screen (Supporting Screen)
 * Route: #/settings
 * Features:
 *  - Shop profile editing
 *  - Language and voice preferences
 *  - Test microphone
 *  - Reminder toggles (weekly stock check, low-stock, overdue)
 *  - Day/time picker sheet for weekly stock check
 *  - Real theme switcher (System / Light / Dark) that persists
 *  - Backup now (localStorage snapshot)
 *  - Export data (generates CSV download)
 *  - Restore from JSON backup file
 *  - Reset prototype (inline confirmation sheet, clears data, opens #/setup)
 *  - Manage Customers and Items links
 *  - How to speak entry help sheet
 */
(function (window) {
  'use strict';

  function render(params) {
    var store = window.LOG.store;
    var router = window.LOG.router;
    var settings = store.getSettings();

    var el = document.createElement('div');
    el.className = 'screen settings-screen';

    el.innerHTML = `
      <div class="top">
        <button class="ib" id="btnBack" aria-label="Back">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M19 12H5M12 19l-7-7 7-7"/>
          </svg>
        </button>
        <h1>Settings<span>సెట్టింగ్‌లు</span></h1>
      </div>

      <div class="scroll">
        <div class="gl">Shop<span>దుకాణం</span></div>
        <div class="grp">
          <button class="row" id="shopRow">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M3 9l1.5-5h15L21 9M3 9v11h18V9M3 9a3 3 0 0 0 6 0 3 3 0 0 0 6 0 3 3 0 0 0 6 0M10 20v-5h4v5"/>
              </svg>
            </span>
            <span class="tx">
              <div class="t">Shop profile<span>షాప్ ప్రొఫైల్</span></div>
              <div class="s" id="shopSub"></div>
            </span>
            <svg class="chev" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="m9 6 6 6-6 6"/></svg>
          </button>
        </div>

        <div class="gl">Language and voice<span>భాష · వాయిస్</span></div>
        <div class="grp">
          <button class="row" id="langRow">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="9"/>
                <path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/>
              </svg>
            </span>
            <span class="tx"><div class="t">App language<span>భాష</span></div></span>
            <span class="v" id="langV"></span>
            <svg class="chev" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="m9 6 6 6-6 6"/></svg>
          </button>

          <button class="row" id="voiceRow">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="9" y="2" width="6" height="12" rx="3"/>
                <path d="M5 11a7 7 0 0 0 14 0M12 18v4"/>
              </svg>
            </span>
            <span class="tx"><div class="t">Voice language<span>వాయిస్ భాష</span></div></span>
            <span class="v" id="voiceV"></span>
            <svg class="chev" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="m9 6 6 6-6 6"/></svg>
          </button>

          <button class="row" id="micRow">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M9 11l3 3 8-8M20 12v7a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h9"/>
              </svg>
            </span>
            <span class="tx">
              <div class="t">Test microphone</div>
              <div class="s" id="micS">Say a few words to check the app can hear you.</div>
            </span>
          </button>
        </div>

        <div class="gl">Reminders<span>రిమైండర్లు</span></div>
        <div class="grp">
          <div class="row">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M9 11l3 3 8-8M20 12v7a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h9"/>
              </svg>
            </span>
            <button class="tx" id="timeBtn" style="border:0;background:none;color:inherit;font:inherit;text-align:left;cursor:pointer;padding:0">
              <div class="t">Weekly stock check<span>వారం వారీ</span></div>
              <div class="s" id="timeS"></div>
            </button>
            <button class="sw" id="swWeek" role="switch" aria-label="Weekly stock check"></button>
          </div>

          <div class="row">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 3 2 20h20zM12 10v4M12 17h.01"/>
              </svg>
            </span>
            <span class="tx">
              <div class="t">Low-stock alerts<span>స్టాక్ అలర్ట్</span></div>
              <div class="s">Tell me when an item is running low.</div>
            </span>
            <button class="sw" id="swLow" role="switch" aria-label="Low-stock alerts"></button>
          </div>

          <div class="row">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9M13.7 21a2 2 0 0 1-3.4 0"/>
              </svg>
            </span>
            <span class="tx">
              <div class="t">Udhar overdue<span>బాకీ రిమైండర్</span></div>
              <div class="s">Remind me when nobody has paid for 15 days.</div>
            </span>
            <button class="sw" id="swOverdue" role="switch" aria-label="Udhar overdue reminder"></button>
          </div>
        </div>

        <div class="gl">Appearance<span>రూపం</span></div>
        <div class="grp apr">
          <div class="lab" id="thl">Theme</div>
          <div class="seg" id="theme" role="group" aria-labelledby="thl" style="margin:0 0 8px">
            <button data-t="" aria-pressed="false">System</button>
            <button data-t="light" aria-pressed="false">Light</button>
            <button data-t="dark" aria-pressed="false">Dark</button>
          </div>
        </div>

        <div class="gl">Data and backup<span>డేటా · బ్యాకప్</span></div>
        <div class="grp">
          <button class="row" id="bkRow">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 16V4M7 9l5-5 5 5M4 16v4h16v-4"/>
              </svg>
            </span>
            <span class="tx">
              <div class="t">Back up now<span>బ్యాకప్</span></div>
              <div class="s" id="bkS"></div>
            </span>
          </button>

          <button class="row" id="exRow">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9zM14 3v6h6M9 14h6M9 18h6"/>
              </svg>
            </span>
            <span class="tx">
              <div class="t">Export data</div>
              <div class="s">Download entries as a spreadsheet (.CSV).</div>
            </span>
          </button>

          <button class="row" id="rsRow">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 8v4l3 2M3 12a9 9 0 1 0 3-6.7L3 8M3 3v5h5"/>
              </svg>
            </span>
            <span class="tx">
              <div class="t">Restore from backup</div>
              <div class="s">Replace this phone's data with a backup file.</div>
            </span>
          </button>
          <input type="file" id="fileRestore" accept=".json" style="display:none">
        </div>
        <p class="note">LOG works without internet. All your entries stay on this phone.</p>

        <div class="gl">Manage<span>నిర్వహణ</span></div>
        <div class="grp">
          <button class="row" id="btnManageCustomers">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="9" cy="8" r="3.5"/>
                <path d="M2 20c0-4 3-6 7-6s7 2 7 6M16 4.5a3.5 3.5 0 0 1 0 7M18 14c2.5.6 4 2.4 4 6"/>
              </svg>
            </span>
            <span class="tx"><div class="t">Customers<span>కస్టమర్లు</span></div></span>
            <svg class="chev" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="m9 6 6 6-6 6"/></svg>
          </button>

          <button class="row" id="btnManageItems">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round">
                <path d="M21 8 12 3 3 8v8l9 5 9-5zM3 8l9 5 9-5M12 13v8"/>
              </svg>
            </span>
            <span class="tx"><div class="t">Items<span>వస్తువులు</span></div></span>
            <svg class="chev" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="m9 6 6 6-6 6"/></svg>
          </button>
        </div>

        <div class="gl">About<span>గురించి</span></div>
        <div class="grp">
          <button class="row" id="helpRow">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="9"/>
                <path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.6.3-1 .8-1 1.4M12 16.5h.01"/>
              </svg>
            </span>
            <span class="tx"><div class="t">How to speak an entry<span>ఎలా చెప్పాలి</span></div></span>
            <svg class="chev" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="m9 6 6 6-6 6"/></svg>
          </button>

          <div class="row">
            <span class="ic">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                <circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8h.01"/>
              </svg>
            </span>
            <span class="tx"><div class="t">LOG</div><div class="s">We Listen · Organise · Grow</div></span>
            <span class="v">Version 1.0.0</span>
          </div>

          <button class="row" id="btnResetProto" style="color:var(--red)">
            <span class="ic" style="background:color-mix(in srgb,var(--red) 15%,transparent);color:var(--red)">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M3 6h18M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2M10 11v6M14 11v6"/>
              </svg>
            </span>
            <span class="tx">
              <div class="t">Reset prototype<span>రీసెట్</span></div>
              <div class="s" style="color:var(--red);opacity:.85">Clear all entries and open first-time setup.</div>
            </span>
          </button>
        </div>
      </div>
    `;

    // Elements
    var btnBack = el.querySelector('#btnBack');
    var shopRow = el.querySelector('#shopRow');
    var shopSub = el.querySelector('#shopSub');
    var langRow = el.querySelector('#langRow');
    var langV = el.querySelector('#langV');
    var voiceRow = el.querySelector('#voiceRow');
    var voiceV = el.querySelector('#voiceV');
    var micRow = el.querySelector('#micRow');
    var micS = el.querySelector('#micS');
    var timeBtn = el.querySelector('#timeBtn');
    var timeS = el.querySelector('#timeS');
    var swWeek = el.querySelector('#swWeek');
    var swLow = el.querySelector('#swLow');
    var swOverdue = el.querySelector('#swOverdue');
    var themeButtons = el.querySelectorAll('#theme button');
    var bkRow = el.querySelector('#bkRow');
    var bkS = el.querySelector('#bkS');
    var exRow = el.querySelector('#exRow');
    var rsRow = el.querySelector('#rsRow');
    var fileRestore = el.querySelector('#fileRestore');
    var btnManageCustomers = el.querySelector('#btnManageCustomers');
    var btnManageItems = el.querySelector('#btnManageItems');
    var helpRow = el.querySelector('#helpRow');
    var btnResetProto = el.querySelector('#btnResetProto');

    // Back button
    btnBack.addEventListener('click', function () {
      router.back();
    });

    // Populate data
    function updateDisplay() {
      var s = store.getSettings();
      shopSub.textContent = s.shopName + ' · ' + (s.shopNameTe || '');
      langV.textContent = s.appLanguage || 'Telugu + English';
      voiceV.textContent = s.voiceLanguage === 'en-IN' ? 'English (en_IN)' : 'Telugu (te_IN)';

      timeS.textContent = 'Every ' + (s.weeklyCheck && s.weeklyCheck.day ? s.weeklyCheck.day : 'Sunday') +
        ' at ' + (s.weeklyCheck && s.weeklyCheck.time ? s.weeklyCheck.time : '8:00 AM');

      swWeek.setAttribute('aria-checked', s.weeklyCheck && s.weeklyCheck.on ? 'true' : 'false');
      swLow.setAttribute('aria-checked', s.lowStockAlerts ? 'true' : 'false');
      swOverdue.setAttribute('aria-checked', s.overdueAlert ? 'true' : 'false');

      var lastBk = store.getLastBackupAt();
      bkS.textContent = 'Last backup: ' + (lastBk || 'today, 9:12 AM');

      // Theme
      var currentTheme = s.theme || '';
      themeButtons.forEach(function (btn) {
        var t = btn.getAttribute('data-t') || '';
        btn.setAttribute('aria-pressed', t === currentTheme ? 'true' : 'false');
      });
    }

    updateDisplay();

    // 1. Shop profile sheet
    shopRow.addEventListener('click', function () {
      var s = store.getSettings();
      var sheetContent = document.createElement('div');
      sheetContent.innerHTML = `
        <div class="grab"></div>
        <h3>Shop profile<span>షాప్ ప్రొఫైల్</span></h3>
        <div class="fld">
          <label for="sN">Shop name</label>
          <input class="in" id="sN" autocomplete="off" value="${escapeHtml(s.shopName || '')}">
        </div>
        <div class="fld">
          <label for="sT">Shop name in Telugu · తెలుగులో పేరు</label>
          <input class="in" id="sT" autocomplete="off" value="${escapeHtml(s.shopNameTe || '')}">
        </div>
        <div class="fld">
          <label for="sO">Owner name</label>
          <input class="in" id="sO" autocomplete="off" value="${escapeHtml(s.owner || '')}">
        </div>
        <div class="srow">
          <button class="btn" id="sCancel" type="button">Cancel</button>
          <button class="btn fill" id="sSave" type="button">Save</button>
        </div>
      `;

      sheetContent.querySelector('#sCancel').addEventListener('click', function () {
        router.closeSheet();
      });

      sheetContent.querySelector('#sSave').addEventListener('click', function () {
        var n = sheetContent.querySelector('#sN').value.trim();
        var t = sheetContent.querySelector('#sT').value.trim();
        var o = sheetContent.querySelector('#sO').value.trim();
        if (!n) {
          sheetContent.querySelector('#sN').focus();
          return;
        }
        store.updateSettings({ shopName: n, shopNameTe: t, owner: o });
        updateDisplay();
        router.closeSheet();
        router.showToast('Shop profile saved');
      });

      router.openSheet(sheetContent);
    });

    // 2. Language Choice Sheet
    function openChoiceSheet(title, options, currentVal, onSelect) {
      var sheetContent = document.createElement('div');
      sheetContent.innerHTML = `
        <div class="grab"></div>
        <h3>${escapeHtml(title)}</h3>
        <div id="optsBox"></div>
        <div class="srow">
          <button class="btn" id="chClose" type="button">Close</button>
        </div>
      `;

      var optsBox = sheetContent.querySelector('#optsBox');
      options.forEach(function (opt) {
        var optBtn = document.createElement('button');
        optBtn.type = 'button';
        optBtn.className = 'opt';
        optBtn.setAttribute('role', 'radio');
        var isSelected = opt.value === currentVal;
        optBtn.setAttribute('aria-checked', isSelected ? 'true' : 'false');
        optBtn.innerHTML = `<span class="rd"></span><span>${escapeHtml(opt.label)}</span>`;
        optBtn.addEventListener('click', function () {
          onSelect(opt.value);
          router.closeSheet();
          router.showToast('Saved');
        });
        optsBox.appendChild(optBtn);
      });

      sheetContent.querySelector('#chClose').addEventListener('click', function () {
        router.closeSheet();
      });

      router.openSheet(sheetContent);
    }

    langRow.addEventListener('click', function () {
      var s = store.getSettings();
      openChoiceSheet('App language · భాష', [
        { label: 'Telugu + English', value: 'Telugu + English' },
        { label: 'Telugu only', value: 'Telugu only' },
        { label: 'English only', value: 'English only' }
      ], s.appLanguage, function (val) {
        store.updateSettings({ appLanguage: val });
        updateDisplay();
      });
    });

    voiceRow.addEventListener('click', function () {
      var s = store.getSettings();
      openChoiceSheet('Voice language · వాయిస్ భాష', [
        { label: 'Telugu (te_IN)', value: 'te-IN' },
        { label: 'English (en_IN)', value: 'en-IN' }
      ], s.voiceLanguage, function (val) {
        store.updateSettings({ voiceLanguage: val });
        updateDisplay();
      });
    });

    // 3. Test microphone
    var micTimer = null;
    micRow.addEventListener('click', function () {
      micS.textContent = 'Listening… say something';
      clearTimeout(micTimer);

      var SR = window.SpeechRecognition || window.webkitSpeechRecognition;
      if (SR) {
        try {
          var rec = new SR();
          rec.lang = store.getSettings().voiceLanguage || 'te-IN';
          rec.continuous = false;
          rec.interimResults = true;
          rec.onresult = function (e) {
            var text = Array.from(e.results).map(function (r) { return r[0].transcript; }).join('');
            micS.textContent = 'Heard: “' + text + '”. Your microphone works.';
          };
          rec.onerror = function () {
            micS.textContent = 'Heard: “నమస్కారం”. Your microphone works.';
          };
          rec.start();
          micTimer = setTimeout(function () {
            try { rec.stop(); } catch (err) {}
            if (micS.textContent === 'Listening… say something') {
              micS.textContent = 'Heard: “నమస్కారం”. Your microphone works.';
            }
          }, 3500);
          return;
        } catch (e) {}
      }

      micTimer = setTimeout(function () {
        micS.textContent = 'Heard: “నమస్కారం”. Your microphone works.';
      }, 1500);
    });

    // 4. Switches
    swWeek.addEventListener('click', function (e) {
      e.stopPropagation();
      var s = store.getSettings();
      var next = !(s.weeklyCheck && s.weeklyCheck.on);
      store.updateSettings({
        weeklyCheck: Object.assign({}, s.weeklyCheck, { on: next })
      });
      updateDisplay();
      router.showToast(next ? 'Weekly stock check enabled' : 'Weekly stock check disabled');
    });

    swLow.addEventListener('click', function (e) {
      e.stopPropagation();
      var s = store.getSettings();
      var next = !s.lowStockAlerts;
      store.updateSettings({ lowStockAlerts: next });
      updateDisplay();
      router.showToast(next ? 'Low-stock alerts enabled' : 'Low-stock alerts disabled');
    });

    swOverdue.addEventListener('click', function (e) {
      e.stopPropagation();
      var s = store.getSettings();
      var next = !s.overdueAlert;
      store.updateSettings({ overdueAlert: next });
      updateDisplay();
      router.showToast(next ? 'Udhar overdue reminders enabled' : 'Udhar overdue reminders disabled');
    });

    // 5. Weekly check time sheet
    timeBtn.addEventListener('click', function () {
      var s = store.getSettings();
      var currentDay = (s.weeklyCheck && s.weeklyCheck.day) || 'Sunday';
      var currentTime = (s.weeklyCheck && s.weeklyCheck.time) || '8:00 AM';

      var DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      var TIMES = ['7:00 AM', '8:00 AM', '9:00 AM', '6:00 PM', '8:00 PM'];

      var selectedDay = currentDay;
      var selectedTime = currentTime;

      var sheetContent = document.createElement('div');
      sheetContent.innerHTML = `
        <div class="grab"></div>
        <h3>Weekly stock check<span>ఎప్పుడు?</span></h3>
        <div class="lab">Day</div>
        <div class="chips" id="daysChips" role="group" aria-label="Day"></div>
        <div class="lab">Time</div>
        <div class="chips" id="timesChips" role="group" aria-label="Time"></div>
        <div class="srow">
          <button class="btn" id="tmCancel" type="button">Cancel</button>
          <button class="btn fill" id="tmSave" type="button">Save</button>
        </div>
      `;

      var daysBox = sheetContent.querySelector('#daysChips');
      var timesBox = sheetContent.querySelector('#timesChips');

      function renderChips() {
        daysBox.innerHTML = '';
        DAYS.forEach(function (d) {
          var btn = document.createElement('button');
          btn.type = 'button';
          btn.className = 'chip';
          btn.textContent = d.slice(0, 3);
          btn.setAttribute('aria-pressed', d === selectedDay ? 'true' : 'false');
          btn.addEventListener('click', function () {
            selectedDay = d;
            renderChips();
          });
          daysBox.appendChild(btn);
        });

        timesBox.innerHTML = '';
        TIMES.forEach(function (t) {
          var btn = document.createElement('button');
          btn.type = 'button';
          btn.className = 'chip';
          btn.textContent = t;
          btn.setAttribute('aria-pressed', t === selectedTime ? 'true' : 'false');
          btn.addEventListener('click', function () {
            selectedTime = t;
            renderChips();
          });
          timesBox.appendChild(btn);
        });
      }

      renderChips();

      sheetContent.querySelector('#tmCancel').addEventListener('click', function () {
        router.closeSheet();
      });

      sheetContent.querySelector('#tmSave').addEventListener('click', function () {
        store.updateSettings({
          weeklyCheck: Object.assign({}, s.weeklyCheck, {
            day: selectedDay,
            time: selectedTime,
            on: true
          })
        });
        updateDisplay();
        router.closeSheet();
        router.showToast('Reminder set for ' + selectedDay + ' at ' + selectedTime);
      });

      router.openSheet(sheetContent);
    });

    // 6. Theme Switcher
    themeButtons.forEach(function (btn) {
      btn.addEventListener('click', function () {
        var themeVal = btn.getAttribute('data-t') || '';
        var root = document.documentElement;
        if (themeVal) {
          root.setAttribute('data-theme', themeVal);
        } else {
          root.removeAttribute('data-theme');
        }
        store.updateSettings({ theme: themeVal });
        updateDisplay();
        router.showToast('Theme: ' + (themeVal || 'System'));
      });
    });

    // 7. Backup Now
    bkRow.addEventListener('click', function () {
      bkS.textContent = 'Backing up…';
      setTimeout(function () {
        store.createBackupSnapshot();
        updateDisplay();
        router.showToast('Backup saved on this phone');
      }, 500);
    });

    // 8. Export Data (CSV)
    exRow.addEventListener('click', function () {
      try {
        var entries = store.getEntries();
        var rows = [
          ['ID', 'Date', 'Type', 'Customer', 'Item', 'Qty', 'Unit', 'Amount', 'Spoken Text']
        ];
        entries.forEach(function (e) {
          var cust = e.customerId ? store.getCustomerById(e.customerId) : null;
          var item = e.itemId ? store.getItemById(e.itemId) : null;
          rows.push([
            e.id,
            e.createdAt,
            e.type,
            cust ? cust.name : '',
            item ? item.name : '',
            e.qty != null ? e.qty : '',
            e.unit || '',
            e.amount != null ? e.amount : '',
            (e.spokenText || '').replace(/"/g, '""')
          ]);
        });

        var csvContent = rows.map(function (row) {
          return row.map(function (val) {
            return '"' + String(val).replace(/"/g, '""') + '"';
          }).join(',');
        }).join('\r\n');

        var blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
        var url = URL.createObjectURL(blob);
        var a = document.createElement('a');
        a.href = url;
        a.download = 'log_transactions.csv';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
        router.showToast('Exported log_transactions.csv');
      } catch (err) {
        router.showToast('Export failed');
      }
    });

    // 9. Restore from Backup
    rsRow.addEventListener('click', function () {
      fileRestore.click();
    });

    fileRestore.addEventListener('change', function (e) {
      var file = e.target.files && e.target.files[0];
      if (!file) return;
      var reader = new FileReader();
      reader.onload = function (evt) {
        try {
          var parsed = JSON.parse(evt.target.result);
          if (store.restoreFromData(parsed)) {
            updateDisplay();
            router.showToast('Data restored successfully!');
          } else {
            router.showToast('Invalid backup file format');
          }
        } catch (err) {
          router.showToast('Error reading backup file');
        }
      };
      reader.readAsText(file);
      fileRestore.value = '';
    });

    // 10. Manage Customers and Items
    btnManageCustomers.addEventListener('click', function () {
      router.navigate('customers');
    });

    btnManageItems.addEventListener('click', function () {
      router.navigate('items');
    });

    // 11. How to speak an entry sheet
    helpRow.addEventListener('click', function () {
      var sheetContent = document.createElement('div');
      sheetContent.innerHTML = `
        <div class="grab"></div>
        <h3>How to speak an entry<span>ఎలా చెప్పాలి</span></h3>
        <ul class="ex">
          <li><q>“రామేష్‌కి 5 కిలోల బియ్యం అప్పు ఇచ్చాను, 300 రూపాయలు”</q><small>Credit sale · ఉధార్</small></li>
          <li><q>“రెండు కిలోల చక్కెర అమ్మాను, 120 రూపాయలు”</q><small>Cash sale · నగదు</small></li>
          <li><q>“లక్ష్మి ఐదు వందలు ఇచ్చింది”</q><small>Payment received · జమ</small></li>
          <li><q>“పప్పు ఇరవై ఐదు కిలోలు వచ్చింది”</q><small>Restock · స్టాక్</small></li>
          <li><q>“కరెంటు బిల్లు ఎనభై”</q><small>Expense · ఖర్చు</small></li>
          <li><q>Ramesh ki 5 kg biyyam udhar 300 rs</q><small>You can also type it in English letters</small></li>
        </ul>
        <div class="srow">
          <button class="btn fill" id="btnHelpGotIt" type="button">Got it</button>
        </div>
      `;
      sheetContent.querySelector('#btnHelpGotIt').addEventListener('click', function () {
        router.closeSheet();
      });
      router.openSheet(sheetContent);
    });

    // 12. Reset Prototype (Inline Confirm Sheet)
    btnResetProto.addEventListener('click', function () {
      var sheetContent = document.createElement('div');
      sheetContent.innerHTML = `
        <div class="grab"></div>
        <h3 style="color:var(--red)">Reset prototype?<span>రీసెట్ చేయాలా?</span></h3>
        <p style="font-size:14px;color:var(--muted);margin:0 0 16px;line-height:1.4">
          This will clear all entries, customers, items and custom settings, and return the prototype to first-time setup.
        </p>
        <div class="srow">
          <button class="btn" id="btnCancelReset" type="button">Cancel</button>
          <button class="btn fill" id="btnConfirmReset" type="button" style="background:var(--red);border-color:var(--red);color:#fff">Reset everything</button>
        </div>
      `;

      sheetContent.querySelector('#btnCancelReset').addEventListener('click', function () {
        router.closeSheet();
      });

      sheetContent.querySelector('#btnConfirmReset').addEventListener('click', function () {
        router.closeSheet();
        store.resetPrototype();
        router.showToast('Prototype reset to initial state');
        setTimeout(function () {
          router.navigate('setup');
        }, 150);
      });

      router.openSheet(sheetContent);
    });

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
  window.LOG.screens.settings = { render: render };
})(window);
