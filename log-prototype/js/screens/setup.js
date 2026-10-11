/**
 * LOG Prototype - Setup Screen (#/setup)
 * 4-step onboarding flow for shopkeeper setup.
 */

(function (window) {
  'use strict';

  var LANGS = [
    ['both', 'తెలుగు + English', 'Telugu and English together'],
    ['te', 'తెలుగు', 'Telugu only'],
    ['en', 'English', 'English only']
  ];

  function render(params) {
    var store = window.LOG.store;
    var router = window.LOG.router;
    var settings = store ? store.getState().settings : {};

    var el = document.createElement('div');
    el.className = 'screen setup-screen';
    el.innerHTML = [
      '<div class="prog" id="setup-prog" aria-hidden="true" style="display:flex;gap:6px;padding:14px 20px 0">',
      '  <i class="on" style="flex:1;height:4px;border-radius:2px;background:var(--accent)"></i>',
      '  <i style="flex:1;height:4px;border-radius:2px;background:var(--line)"></i>',
      '  <i style="flex:1;height:4px;border-radius:2px;background:var(--line)"></i>',
      '  <i style="flex:1;height:4px;border-radius:2px;background:var(--line)"></i>',
      '</div>',
      '<div class="stp" id="setup-stp" style="padding:8px 20px 0;font:500 13px var(--f);color:var(--muted)">Step 1 of 4</div>',
      '<div class="scroll" style="padding:10px 20px 16px">',
      '  <!-- Step 0: Language -->',
      '  <section class="step on" data-s="0" style="display:flex;flex-direction:column;gap:16px;padding-top:4px">',
      '    <div><div style="font:700 40px/1 var(--f);letter-spacing:.08em;color:var(--accent)">LOG</div><div style="font:400 14px var(--f);color:var(--muted);margin-top:4px">We Listen · Organise · Grow</div></div>',
      '    <h1 style="margin:0;font:500 26px/1.25 var(--f)">Welcome<span style="display:block;font:500 20px/1.4 var(--te);color:var(--muted);margin-top:2px">స్వాగతం</span></h1>',
      '    <p style="margin:0;font:400 15px/1.5 var(--f);color:var(--muted)">Speak your shop\'s sales, udhar and stock. LOG writes it down for you, even without internet.<span style="display:block;font-family:var(--te);margin-top:4px">మీ అమ్మకాలు, ఉధార్, స్టాక్ చెప్పండి. LOG రాసిపెడుతుంది.</span></p>',
      '    <div role="radiogroup" aria-label="App language" id="setup-langs" style="display:flex;flex-direction:column;gap:10px"></div>',
      '  </section>',
      '  <!-- Step 1: Shop details -->',
      '  <section class="step" data-s="1" style="display:none;flex-direction:column;gap:16px;padding-top:4px">',
      '    <h1 style="margin:0;font:500 26px/1.25 var(--f)">Your shop<span style="display:block;font:500 20px/1.4 var(--te);color:var(--muted);margin-top:2px">మీ దుకాణం</span></h1>',
      '    <p style="margin:0;font:400 15px/1.5 var(--f);color:var(--muted)">This name appears at the top of your Home screen.</p>',
      '    <div class="fld"><label for="su-sn">Shop name</label><input class="in" id="su-sn" placeholder="e.g. Sri Lakshmi Kirana" autocomplete="off"></div>',
      '    <div class="fld"><label for="su-st">Shop name in Telugu · తెలుగులో పేరు (optional)</label><input class="in" id="su-st" placeholder="శ్రీ లక్ష్మి కిరాణా" autocomplete="off"></div>',
      '    <div class="fld"><label for="su-so">Your name (optional)</label><input class="in" id="su-so" placeholder="e.g. Lakshmi Narayana" autocomplete="off"></div>',
      '  </section>',
      '  <!-- Step 2: Microphone -->',
      '  <section class="step" data-s="2" style="display:none;flex-direction:column;gap:16px;padding-top:4px">',
      '    <h1 style="margin:0;font:500 26px/1.25 var(--f)">Let LOG hear you<span style="display:block;font:500 20px/1.4 var(--te);color:var(--muted);margin-top:2px">మైక్ అనుమతి</span></h1>',
      '    <p style="margin:0;font:400 15px/1.5 var(--f);color:var(--muted)">LOG needs your microphone to turn what you say into entries. Your voice is not saved or sent anywhere.</p>',
      '    <div class="grp" style="padding:22px 18px;text-align:center;display:flex;flex-direction:column;align-items:center;gap:14px">',
      '      <div id="su-perm" style="display:flex;align-items:center;gap:10px;font:500 14px var(--f);color:var(--fg)"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="9"/><path d="M12 8v4M12 16h.01"/></svg><span>Microphone is off</span></div>',
      '      <button class="btn fill" id="su-allow" type="button">Allow microphone</button>',
      '      <div id="su-try" style="display:none;flex-direction:column;align-items:center;gap:12px;width:100%">',
      '        <div style="font:400 14px var(--f);color:var(--muted)">Tap the mic and say:<br><b style="font-family:var(--te);font-weight:500;color:var(--fg)">“రామేష్‌కి 5 కిలోల బియ్యం అప్పు, 300 రూపాయలు”</b></div>',
      '        <button class="speak" id="su-micc" type="button" aria-label="Try speaking" style="margin-top:0"><span class="mic" style="width:72px;height:72px"><svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v4"/></svg><span class="bars"><i></i><i></i><i></i><i></i></span></span></button>',
      '        <div id="su-heard" style="font:500 18px/1.5 var(--te);min-height:30px;color:var(--fg)" aria-live="polite"></div>',
      '      </div>',
      '    </div>',
      '  </section>',
      '  <!-- Step 3: Ready tips -->',
      '  <section class="step" data-s="3" style="display:none;flex-direction:column;gap:16px;padding-top:4px">',
      '    <h1 style="margin:0;font:500 26px/1.25 var(--f)">You are ready<span style="display:block;font:500 20px/1.4 var(--te);color:var(--muted);margin-top:2px">సిద్ధం</span></h1>',
      '    <div style="display:flex;flex-direction:column;gap:12px">',
      '      <div style="display:flex;gap:14px;align-items:flex-start"><span style="width:32px;height:32px;border-radius:50%;background:var(--accent-tonal);color:var(--accent);display:grid;place-items:center;font:700 15px var(--f);flex:none">1</span><div><b style="font:500 16px var(--f)">Tap Speak and say an entry</b><span style="display:block;font:400 14px var(--te);color:var(--muted)">స్పీక్ నొక్కి చెప్పండి</span></div></div>',
      '      <div style="display:flex;gap:14px;align-items:flex-start"><span style="width:32px;height:32px;border-radius:50%;background:var(--accent-tonal);color:var(--accent);display:grid;place-items:center;font:700 15px var(--f);flex:none">2</span><div><b style="font:500 16px var(--f)">Check it on the Confirm screen</b><span style="display:block;font:400 14px var(--te);color:var(--muted)">సరిచూసి సేవ్ చేయండి</span></div></div>',
      '      <div style="display:flex;gap:14px;align-items:flex-start"><span style="width:32px;height:32px;border-radius:50%;background:var(--accent-tonal);color:var(--accent);display:grid;place-items:center;font:700 15px var(--f);flex:none">3</span><div><b style="font:500 16px var(--f)">See udhar, stock and profit any time</b><span style="display:block;font:400 14px var(--te);color:var(--muted)">ఉధార్, స్టాక్, లాభం చూడండి</span></div></div>',
      '    </div>',
      '    <div class="row" style="background:var(--container);border-radius:20px;padding:14px 16px;margin-top:6px">',
      '      <span class="tx"><div class="t">Weekly stock check<span>వారం వారీ</span></div><div class="s">A reminder every Sunday at 8:00 AM to confirm your stock.</div></span>',
      '      <button class="sw" id="su-sw" role="switch" aria-checked="true" aria-label="Weekly stock check reminder"></button>',
      '    </div>',
      '  </section>',
      '</div>',
      '<div class="srow" style="padding:12px 20px calc(14px + env(safe-area-inset-bottom, 0px));background:var(--surface);margin-top:auto">',
      '  <button class="btn" id="su-back" type="button" style="visibility:hidden">Back</button>',
      '  <button class="btn fill" id="su-next" type="button">Next · తరువాత</button>',
      '</div>'
    ].join('\n');

    var step = 0;
    var totalSteps = 4;
    var selectedLang = settings.appLanguage || 'both';
    var micAllowed = false;
    var micTryTimer = null;

    // Build language options
    var langsContainer = el.querySelector('#setup-langs');
    LANGS.forEach(function (l, i) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'opt';
      btn.setAttribute('role', 'radio');
      btn.setAttribute('aria-checked', l[0] === selectedLang ? 'true' : 'false');
      btn.style.cssText = 'display:flex;align-items:center;gap:14px;width:100%;min-height:64px;padding:12px 16px;border:1.5px solid var(--line);border-radius:18px;background:none;color:inherit;text-align:left;cursor:pointer;';
      if (l[0] === selectedLang) {
        btn.style.borderColor = 'var(--accent)';
        btn.style.background = 'var(--accent-tonal)';
      }
      btn.innerHTML = '<span class="rd"></span><span><b style="display:block;font:500 17px var(--te)">' + l[1] + '</b><small style="font:400 13px var(--f);color:var(--muted)">' + l[2] + '</small></span>' +
        (i === 0 ? '<span style="margin-left:auto;font:500 12px var(--f);color:var(--accent);flex:none">Recommended</span>' : '');

      btn.addEventListener('click', function () {
        selectedLang = l[0];
        langsContainer.querySelectorAll('.opt').forEach(function (x) {
          var isCur = x === btn;
          x.setAttribute('aria-checked', isCur ? 'true' : 'false');
          x.style.borderColor = isCur ? 'var(--accent)' : 'var(--line)';
          x.style.background = isCur ? 'var(--accent-tonal)' : 'none';
        });
      });
      langsContainer.appendChild(btn);
    });

    var snInput = el.querySelector('#su-sn');
    var stInput = el.querySelector('#su-st');
    var soInput = el.querySelector('#su-so');
    snInput.value = settings.shopName || 'Sri Lakshmi Kirana';
    stInput.value = settings.shopNameTe || 'శ్రీ లక్ష్మి కిరాణా';
    soInput.value = settings.owner || 'Lakshmi Narayana';

    var backBtn = el.querySelector('#su-back');
    var nextBtn = el.querySelector('#su-next');
    var prog = el.querySelector('#setup-prog');
    var stp = el.querySelector('#setup-stp');

    function updateStep() {
      el.querySelectorAll('.step').forEach(function (s) {
        var isCur = +s.dataset.s === step;
        s.style.display = isCur ? 'flex' : 'none';
      });

      prog.querySelectorAll('i').forEach(function (p, i) {
        p.style.background = i <= step ? 'var(--accent)' : 'var(--line)';
      });

      stp.textContent = 'Step ' + (step + 1) + ' of ' + totalSteps;
      backBtn.style.visibility = step === 0 ? 'hidden' : 'visible';
      nextBtn.textContent = step === totalSteps - 1 ? 'Start using LOG · ప్రారంభించండి' : 'Next · తరువాత';
      validateGate();
    }

    function validateGate() {
      var ok = true;
      if (step === 1) {
        ok = !!snInput.value.trim();
      } else if (step === 2) {
        ok = micAllowed;
      }
      nextBtn.disabled = !ok;
    }

    snInput.addEventListener('input', validateGate);

    backBtn.addEventListener('click', function () {
      if (step > 0) {
        step--;
        updateStep();
      }
    });

    nextBtn.addEventListener('click', function () {
      if (step < totalSteps - 1) {
        step++;
        updateStep();
      } else {
        // Complete setup flow
        var weeklySw = el.querySelector('#su-sw');
        var weeklyOn = weeklySw.getAttribute('aria-checked') === 'true';

        store.updateSettings({
          shopName: snInput.value.trim() || 'Sri Lakshmi Kirana',
          shopNameTe: stInput.value.trim() || 'శ్రీ లక్ష్మి కిరాణా',
          owner: soInput.value.trim() || 'Lakshmi Narayana',
          appLanguage: selectedLang,
          weeklyCheck: Object.assign({}, settings.weeklyCheck, { on: weeklyOn })
        });
        store.setSetupDone(true);
        router.toast('Setup complete · సిద్ధం!');
        router.navigate('home', {}, true);
      }
    });

    // Mic permissions button
    var permEl = el.querySelector('#su-perm');
    var allowBtn = el.querySelector('#su-allow');
    var tryBox = el.querySelector('#su-try');
    var miccBtn = el.querySelector('#su-micc');
    var heardEl = el.querySelector('#su-heard');

    allowBtn.addEventListener('click', function () {
      micAllowed = true;
      permEl.style.color = 'var(--good)';
      permEl.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg><span>Microphone is on</span>';
      allowBtn.style.display = 'none';
      tryBox.style.display = 'flex';
      validateGate();

      // Trigger Web Speech API permission check if supported
      var Speech = window.SpeechRecognition || window.webkitSpeechRecognition;
      if (Speech) {
        try {
          var rec = new Speech();
          rec.lang = 'te-IN';
          rec.onstart = function () { rec.stop(); };
          rec.onerror = function () {};
          rec.start();
        } catch (e) {}
      }
    });

    miccBtn.addEventListener('click', function () {
      var on = !miccBtn.classList.contains('on');
      miccBtn.classList.toggle('on', on);
      clearTimeout(micTryTimer);
      if (on) {
        heardEl.textContent = '…';
        micTryTimer = setTimeout(function () {
          miccBtn.classList.remove('on');
          heardEl.textContent = 'రామేష్‌కి 5 కిలోల బియ్యం అప్పు, 300 రూపాయలు';
        }, 1600);
      } else {
        heardEl.textContent = '';
      }
    });

    // Switch toggle
    var sw = el.querySelector('#su-sw');
    sw.addEventListener('click', function () {
      var isChecked = sw.getAttribute('aria-checked') === 'true';
      sw.setAttribute('aria-checked', !isChecked ? 'true' : 'false');
    });

    updateStep();
    return el;
  }

  window.LOG.screens.setup = {
    render: render
  };
})(window);
