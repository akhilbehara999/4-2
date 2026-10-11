/**
 * LOG Prototype - Listening Screen (#/listen)
 * Full-screen voice capture with Web Speech API, live interim transcription,
 * silence detection, error states, and type-instead mode.
 */

(function (window) {
  'use strict';

  var activeRecognizer = null;
  var silenceTimer = null;
  var quietTimeoutTimer = null;
  var simulationTimer = null;

  function cleanupRecognizer() {
    if (activeRecognizer) {
      try {
        activeRecognizer.abort();
      } catch (e) {}
      activeRecognizer = null;
    }
    if (silenceTimer) clearTimeout(silenceTimer);
    if (quietTimeoutTimer) clearTimeout(quietTimeoutTimer);
    if (simulationTimer) clearTimeout(simulationTimer);
  }

  function render() {
    var store = window.LOG.store;
    var parser = window.LOG.parser;
    var router = window.LOG.router;
    var settings = store ? store.getState().settings : {};
    var voiceLang = settings.voiceLanguage === 'en_IN' ? 'en-IN' : 'te-IN';
    var voiceLabel = settings.voiceLanguage === 'en_IN' ? 'English · en_IN' : 'Telugu · te_IN';

    cleanupRecognizer();

    var el = document.createElement('div');
    el.className = 'screen listen-screen';
    el.style.cssText = 'background:var(--white);color:var(--fg);display:flex;flex-direction:column;min-height:100%;text-align:center;position:relative';

    el.innerHTML = [
      '<div class="top" style="padding:10px 8px 0;display:flex;align-items:center;justify-content:space-between">',
      '  <button class="ib" id="listen-close" aria-label="Close" type="button"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M18 6 6 18M6 6l12 12"/></svg></button>',
      '  <span class="lg" style="display:flex;align-items:center;gap:6px;height:32px;padding:0 14px;border-radius:16px;background:var(--container);font:500 13px var(--f);color:var(--muted);margin-right:8px"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a14 14 0 0 1 0 18M12 3a14 14 0 0 0 0 18"/></svg>' + voiceLabel + '</span>',
      '</div>',
      '<div style="flex:1;min-height:0;display:flex;flex-direction:column;align-items:center;padding:6px 20px 8px">',
      '  <div class="status" id="listen-status" aria-live="polite" style="margin-top:10px">',
      '    <h1 id="listen-h1" style="margin:0;font:500 26px/1.2 var(--f)">Listening…<span style="display:block;font:400 18px var(--te);color:var(--muted);margin-top:2px">వింటున్నాను…</span></h1>',
      '  </div>',
      '  <!-- Stage with ripple rings and central mic button -->',
      '  <div class="stage" style="position:relative;width:190px;height:190px;margin:20px 0 4px;display:grid;place-items:center;flex:none">',
      '    <span class="ring" id="ring1" style="position:absolute;inset:0;border-radius:50%;background:var(--red-tonal);opacity:0"></span>',
      '    <span class="ring" id="ring2" style="position:absolute;inset:0;border-radius:50%;background:var(--red-tonal);opacity:0"></span>',
      '    <span class="ring" id="ring3" style="position:absolute;inset:0;border-radius:50%;background:var(--red-tonal);opacity:0"></span>',
      '    <button class="mic" id="listen-mic" aria-label="Microphone" type="button" style="position:relative;z-index:1;width:112px;height:112px;border-radius:50%;border:0;background:var(--red);color:#fff;display:grid;place-items:center;cursor:pointer;transition:background .2s">',
      '      <svg id="mic-icon-listen" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v4"/></svg>',
      '      <svg id="mic-icon-ok" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" style="display:none"><path d="M20 6 9 17l-5-5"/></svg>',
      '      <svg id="mic-icon-off" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" style="display:none"><rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v4M3 3l18 18"/></svg>',
      '    </button>',
      '  </div>',
      '  <!-- Waveform -->',
      '  <div class="wave" id="listen-wave" aria-hidden="true" style="height:36px;display:flex;align-items:center;gap:5px;margin-bottom:6px">',
      '    <i style="width:5px;height:14px;border-radius:3px;background:var(--red);animation:barBounce .8s ease-in-out infinite"></i>',
      '    <i style="width:5px;height:24px;border-radius:3px;background:var(--red);animation:barBounce .8s ease-in-out infinite .1s"></i>',
      '    <i style="width:5px;height:32px;border-radius:3px;background:var(--red);animation:barBounce .8s ease-in-out infinite .2s"></i>',
      '    <i style="width:5px;height:20px;border-radius:3px;background:var(--red);animation:barBounce .8s ease-in-out infinite .3s"></i>',
      '    <i style="width:5px;height:10px;border-radius:3px;background:var(--red);animation:barBounce .8s ease-in-out infinite .4s"></i>',
      '  </div>',
      '  <!-- Text output -->',
      '  <div class="txt" id="listen-txt" aria-live="polite" style="flex:1;min-height:0;width:100%;overflow-y:auto;display:flex;flex-direction:column;justify-content:flex-start;align-items:center;gap:12px;padding-top:6px"></div>',
      '</div>',
      '<!-- Bottom Action Buttons -->',
      '<div class="foot" id="listen-foot" style="display:flex;gap:10px;padding:10px 20px calc(16px + env(safe-area-inset-bottom, 0px));flex:none"></div>'
    ].join('\n');

    var closeBtn = el.querySelector('#listen-close');
    var h1El = el.querySelector('#listen-h1');
    var micBtn = el.querySelector('#listen-mic');
    var micIconListen = el.querySelector('#mic-icon-listen');
    var micIconOk = el.querySelector('#mic-icon-ok');
    var micIconOff = el.querySelector('#mic-icon-off');
    var waveEl = el.querySelector('#listen-wave');
    var txtEl = el.querySelector('#listen-txt');
    var footEl = el.querySelector('#listen-foot');
    var ring1 = el.querySelector('#ring1');
    var ring2 = el.querySelector('#ring2');
    var ring3 = el.querySelector('#ring3');

    var state = 'listen'; // 'listen' | 'done' | 'quiet' | 'blocked'
    var recognizedWords = '';
    var finalResultText = '';
    var parsedData = null;

    closeBtn.addEventListener('click', function () {
      cleanupRecognizer();
      router.back();
    });

    function setState(newState) {
      cleanupRecognizer();
      state = newState;

      // Update mic icons
      micIconListen.style.display = (state === 'listen' || state === 'quiet') ? 'block' : 'none';
      micIconOk.style.display = state === 'done' ? 'block' : 'none';
      micIconOff.style.display = state === 'blocked' ? 'block' : 'none';

      // Update mic colors & rings
      if (state === 'listen') {
        micBtn.style.background = 'var(--red)';
        waveEl.style.display = 'flex';
        ring1.style.background = 'var(--red-tonal)';
        ring2.style.background = 'var(--red-tonal)';
        ring3.style.background = 'var(--red-tonal)';
        [ring1, ring2, ring3].forEach(function (r, i) {
          r.style.animation = 'rip 2.4s ease-out infinite ' + (i * 0.8) + 's';
        });
      } else if (state === 'done') {
        micBtn.style.background = 'var(--accent)';
        waveEl.style.display = 'none';
        [ring1, ring2, ring3].forEach(function (r) { r.style.animation = 'none'; r.style.opacity = '0'; });
      } else if (state === 'quiet') {
        micBtn.style.background = 'var(--amber)';
        waveEl.style.display = 'none';
        [ring1, ring2, ring3].forEach(function (r) { r.style.animation = 'none'; r.style.opacity = '0'; });
      } else if (state === 'blocked') {
        micBtn.style.background = 'var(--outline)';
        waveEl.style.display = 'none';
        [ring1, ring2, ring3].forEach(function (r) { r.style.animation = 'none'; r.style.opacity = '0'; });
      }

      txtEl.innerHTML = '';
      footEl.innerHTML = '';

      if (state === 'listen') {
        h1El.innerHTML = 'Listening…<span style="display:block;font:400 18px var(--te);color:var(--muted);margin-top:2px">వింటున్నాను…</span>';

        var saidEl = document.createElement('div');
        saidEl.id = 'live-said';
        saidEl.style.cssText = 'font:500 24px/1.5 var(--te);overflow-wrap:anywhere;min-height:36px;color:var(--fg)';

        var hintEl = document.createElement('div');
        hintEl.id = 'live-hint';
        hintEl.style.cssText = 'font:400 14px/1.5 var(--f);color:var(--muted);max-width:300px';
        hintEl.innerHTML = 'Say who, what, how much and the amount.<b style="display:block;font:500 16px/1.5 var(--te);color:var(--fg);margin-top:6px">“రామేష్‌కి 5 కిలోల బియ్యం అప్పు, 300 రూపాయలు”</b>';

        txtEl.appendChild(saidEl);
        txtEl.appendChild(hintEl);

        // Buttons
        var typeBtn = document.createElement('button');
        typeBtn.type = 'button';
        typeBtn.className = 'btn';
        typeBtn.style.cssText = 'flex:1;height:56px;border-radius:28px';
        typeBtn.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="2" y="6" width="20" height="12" rx="2"/><path d="M6 10h.01M10 10h.01M14 10h.01M18 10h.01M7 14h10"/></svg>Type instead';
        typeBtn.addEventListener('click', typeMode);

        var doneBtn = document.createElement('button');
        doneBtn.type = 'button';
        doneBtn.className = 'btn fill';
        doneBtn.style.cssText = 'flex:1.4;height:56px;border-radius:28px';
        doneBtn.textContent = 'Done · పూర్తి';
        doneBtn.addEventListener('click', function () {
          if (!finalResultText && !recognizedWords) {
            finalResultText = 'రామేష్‌కి 5 కిలోల బియ్యం అప్పు ఇచ్చాను, 300 రూపాయలు';
          }
          setState('done');
        });

        footEl.appendChild(typeBtn);
        footEl.appendChild(doneBtn);

        startListening();
      }

      if (state === 'done') {
        h1El.innerHTML = 'Got it<span style="display:block;font:400 18px var(--te);color:var(--muted);margin-top:2px">అర్థమైంది</span>';

        var textToShow = finalResultText || recognizedWords || 'రామేష్‌కి 5 కిలోల బియ్యం అప్పు ఇచ్చాను, 300 రూపాయలు';
        parsedData = parser.parseEntry(textToShow);

        var saidDone = document.createElement('div');
        saidDone.style.cssText = 'font:500 22px/1.4 var(--te);color:var(--fg)';
        saidDone.textContent = '“' + textToShow + '”';

        // Chips
        var chipsBox = document.createElement('div');
        chipsBox.style.cssText = 'display:flex;flex-wrap:wrap;gap:8px;justify-content:center;margin-top:4px';

        var TYPE_NAMES = { credit: 'Credit · ఉధార్', cash: 'Cash · నగదు', pay: 'Received · జమ', exp: 'Expense · ఖర్చు', stock: 'Restock · స్టాక్' };
        var chipsList = [
          { text: TYPE_NAMES[parsedData.type] || parsedData.type, isType: true },
          parsedData.customer ? { text: parsedData.customer } : null,
          parsedData.item ? { text: parsedData.item } : null,
          parsedData.qty ? { text: parsedData.qty + ' ' + (parsedData.unit || 'kg') } : null,
          parsedData.amount ? { text: engine.inr(parsedData.amount) } : null
        ].filter(Boolean);

        chipsList.forEach(function (c) {
          var chipSpan = document.createElement('span');
          chipSpan.className = 'chip' + (c.isType ? ' cr' : '');
          chipSpan.style.cssText = c.isType ?
            'background:var(--orange-tonal);color:var(--orange);padding:6px 14px;border-radius:10px;font:500 14px var(--f)' :
            'background:var(--accent-tonal);color:var(--accent);padding:6px 14px;border-radius:10px;font:500 14px var(--f)';
          chipSpan.textContent = c.text;
          chipsBox.appendChild(chipSpan);
        });

        var fixHint = document.createElement('div');
        fixHint.style.cssText = 'font:400 14px var(--f);color:var(--muted)';
        fixHint.textContent = 'You can fix anything on the next screen.';

        txtEl.appendChild(saidDone);
        txtEl.appendChild(chipsBox);
        txtEl.appendChild(fixHint);

        var speakAgainBtn = document.createElement('button');
        speakAgainBtn.type = 'button';
        speakAgainBtn.className = 'btn';
        speakAgainBtn.style.cssText = 'flex:1;height:56px;border-radius:28px';
        speakAgainBtn.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v4"/></svg>Speak again';
        speakAgainBtn.addEventListener('click', function () {
          setState('listen');
        });

        var checkBtn = document.createElement('button');
        checkBtn.type = 'button';
        checkBtn.className = 'btn fill';
        checkBtn.style.cssText = 'flex:1.4;height:56px;border-radius:28px';
        checkBtn.textContent = 'Check entry · సరిచూడండి';
        checkBtn.addEventListener('click', function () {
          router.navigate('confirm', {
            parsed: parsedData,
            rawText: textToShow
          });
        });

        footEl.appendChild(speakAgainBtn);
        footEl.appendChild(checkBtn);
      }

      if (state === 'quiet') {
        h1El.innerHTML = 'I did not hear you<span style="display:block;font:400 18px var(--te);color:var(--muted);margin-top:2px">వినపడలేదు</span>';

        var warnBox = document.createElement('div');
        warnBox.style.cssText = 'display:flex;gap:10px;align-items:flex-start;text-align:left;border-radius:16px;padding:12px 14px;background:var(--amber-tonal);color:var(--amber);font:400 14px/1.45 var(--f);max-width:320px';
        warnBox.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:1px"><path d="M12 3 2 20h20zM12 10v4M12 17h.01"/></svg><span>Nothing came through. Move closer to the phone and speak after the mic turns red.</span>';
        txtEl.appendChild(warnBox);

        var typeInsteadBtn = document.createElement('button');
        typeInsteadBtn.type = 'button';
        typeInsteadBtn.className = 'btn';
        typeInsteadBtn.style.cssText = 'flex:1;height:56px;border-radius:28px';
        typeInsteadBtn.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="2" y="6" width="20" height="12" rx="2"/><path d="M6 10h.01M10 10h.01M14 10h.01M18 10h.01M7 14h10"/></svg>Type instead';
        typeInsteadBtn.addEventListener('click', typeMode);

        var tryAgainBtn = document.createElement('button');
        tryAgainBtn.type = 'button';
        tryAgainBtn.className = 'btn fill';
        tryAgainBtn.style.cssText = 'flex:1.4;height:56px;border-radius:28px';
        tryAgainBtn.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v4"/></svg>Try again';
        tryAgainBtn.addEventListener('click', function () {
          setState('listen');
        });

        footEl.appendChild(typeInsteadBtn);
        footEl.appendChild(tryAgainBtn);
      }

      if (state === 'blocked') {
        h1El.innerHTML = 'Microphone is off<span style="display:block;font:400 18px var(--te);color:var(--muted);margin-top:2px">మైక్ ఆఫ్‌లో ఉంది</span>';

        var badBox = document.createElement('div');
        badBox.style.cssText = 'display:flex;gap:10px;align-items:flex-start;text-align:left;border-radius:16px;padding:12px 14px;background:var(--red-tonal);color:var(--red);font:400 14px/1.45 var(--f);max-width:320px';
        badBox.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex:none;margin-top:1px"><path d="M12 3 2 20h20zM12 10v4M12 17h.01"/></svg><span>LOG cannot use the microphone. Turn it on in your phone settings, or type your entry.</span>';
        txtEl.appendChild(badBox);

        var typeBtn2 = document.createElement('button');
        typeBtn2.type = 'button';
        typeBtn2.className = 'btn';
        typeBtn2.style.cssText = 'flex:1;height:56px;border-radius:28px';
        typeBtn2.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="2" y="6" width="20" height="12" rx="2"/><path d="M6 10h.01M10 10h.01M14 10h.01M18 10h.01M7 14h10"/></svg>Type instead';
        typeBtn2.addEventListener('click', typeMode);

        var settingsBtn = document.createElement('button');
        settingsBtn.type = 'button';
        settingsBtn.className = 'btn fill';
        settingsBtn.style.cssText = 'flex:1.4;height:56px;border-radius:28px';
        settingsBtn.textContent = 'Open settings';
        settingsBtn.addEventListener('click', function () {
          router.navigate('settings');
        });

        footEl.appendChild(typeBtn2);
        footEl.appendChild(settingsBtn);
      }
    }

    function typeMode() {
      cleanupRecognizer();
      state = 'type';
      micBtn.style.background = 'var(--outline)';
      waveEl.style.display = 'none';
      [ring1, ring2, ring3].forEach(function (r) { r.style.animation = 'none'; r.style.opacity = '0'; });

      h1El.innerHTML = 'Type your entry<span style="display:block;font:400 18px var(--te);color:var(--muted);margin-top:2px">టైప్ చేయండి</span>';
      txtEl.innerHTML = '';
      footEl.innerHTML = '';

      var form = document.createElement('form');
      form.style.cssText = 'width:100%;max-width:340px;display:flex;flex-direction:column;gap:12px;margin-top:8px';

      var input = document.createElement('input');
      input.className = 'in';
      input.id = 'listen-typed-input';
      input.placeholder = 'Ramesh ki 5 kg biyyam udhar 300 rs';
      input.setAttribute('aria-label', 'Type your entry');
      input.autocomplete = 'off';
      input.style.cssText = 'border-radius:28px;padding:0 20px;height:56px;font:400 16px var(--te)';

      var hintText = document.createElement('div');
      hintText.style.cssText = 'font:400 14px var(--f);color:var(--muted)';
      hintText.textContent = 'Telugu letters or English letters both work.';

      form.appendChild(input);
      form.appendChild(hintText);
      txtEl.appendChild(form);

      function submitTyped() {
        var val = input.value.trim();
        if (!val) {
          input.focus();
          return;
        }
        var p = parser.parseEntry(val);
        router.navigate('confirm', {
          parsed: p,
          rawText: val
        });
      }

      form.addEventListener('submit', function (e) {
        e.preventDefault();
        submitTyped();
      });

      var speakInsteadBtn = document.createElement('button');
      speakInsteadBtn.type = 'button';
      speakInsteadBtn.className = 'btn';
      speakInsteadBtn.style.cssText = 'flex:1;height:56px;border-radius:28px';
      speakInsteadBtn.innerHTML = '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v4"/></svg>Speak instead';
      speakInsteadBtn.addEventListener('click', function () {
        setState('listen');
      });

      var checkEntryBtn = document.createElement('button');
      checkEntryBtn.type = 'button';
      checkEntryBtn.className = 'btn fill';
      checkEntryBtn.style.cssText = 'flex:1.4;height:56px;border-radius:28px';
      checkEntryBtn.textContent = 'Check entry · సరిచూడండి';
      checkEntryBtn.addEventListener('click', submitTyped);

      footEl.appendChild(speakInsteadBtn);
      footEl.appendChild(checkEntryBtn);

      setTimeout(function () { input.focus(); }, 100);
    }

    function startListening() {
      recognizedWords = '';
      finalResultText = '';
      var saidContainer = el.querySelector('#live-said');
      var liveHint = el.querySelector('#live-hint');

      var Speech = window.SpeechRecognition || window.webkitSpeechRecognition;
      if (!Speech) {
        console.warn('[LOG speech] Web Speech API not supported in this browser.');
        // Fallback simulation for offline desktop browsers
        simulateSpeechRecognition(saidContainer, liveHint);
        return;
      }

      try {
        var rec = new Speech();
        rec.lang = voiceLang;
        rec.continuous = true;
        rec.interimResults = true;

        // Auto quiet timer: if nothing heard within 7 seconds
        quietTimeoutTimer = setTimeout(function () {
          if (!recognizedWords && state === 'listen') {
            setState('quiet');
          }
        }, 7000);

        rec.onresult = function (event) {
          if (quietTimeoutTimer) clearTimeout(quietTimeoutTimer);
          var interim = '';
          var finalStr = '';

          for (var i = event.resultIndex; i < event.results.length; ++i) {
            var res = event.results[i];
            if (res.isFinal) {
              finalStr += res[0].transcript;
            } else {
              interim += res[0].transcript;
            }
          }

          if (liveHint) liveHint.style.display = 'none';

          if (saidContainer) {
            saidContainer.innerHTML = '';
            if (finalStr) {
              saidContainer.appendChild(document.createTextNode(finalStr + ' '));
              recognizedWords = finalStr;
            }
            if (interim) {
              var intSpan = document.createElement('span');
              intSpan.className = 'int';
              intSpan.style.color = 'var(--muted)';
              intSpan.textContent = interim;
              saidContainer.appendChild(intSpan);
              recognizedWords = (finalStr + ' ' + interim).trim();
            }
          }

          // Auto-stop after 1.5s of silence
          if (silenceTimer) clearTimeout(silenceTimer);
          silenceTimer = setTimeout(function () {
            if (recognizedWords && state === 'listen') {
              finalResultText = recognizedWords;
              setState('done');
            }
          }, 1500);
        };

        rec.onerror = function (event) {
          console.warn('[LOG speech] error:', event.error);
          if (event.error === 'not-allowed' || event.error === 'service-not-allowed') {
            setState('blocked');
          } else if (event.error === 'no-speech') {
            setState('quiet');
          }
        };

        rec.onend = function () {
          if (state === 'listen' && recognizedWords) {
            finalResultText = recognizedWords;
            setState('done');
          }
        };

        rec.start();
        activeRecognizer = rec;
      } catch (err) {
        console.warn('[LOG speech] start error:', err);
        simulateSpeechRecognition(saidContainer, liveHint);
      }
    }

    function simulateSpeechRecognition(saidContainer, liveHint) {
      // Simulation demo if browser doesn't have an active microphone
      var demoTokens = ['రామేష్‌కి', '5', 'కిలోల', 'బియ్యం', 'అప్పు', 'ఇచ్చాను,', '300', 'రూపాయలు'];
      var idx = 0;

      quietTimeoutTimer = setTimeout(function () {
        if (!recognizedWords && state === 'listen') {
          // If no click happened, run the demo utterance
          function nextWord() {
            if (state !== 'listen') return;
            if (idx < demoTokens.length) {
              if (liveHint) liveHint.style.display = 'none';
              saidContainer.innerHTML = '';
              var doneText = demoTokens.slice(0, idx).join(' ') + (idx ? ' ' : '');
              saidContainer.appendChild(document.createTextNode(doneText));
              var intSpan = document.createElement('span');
              intSpan.className = 'int';
              intSpan.style.color = 'var(--muted)';
              intSpan.textContent = demoTokens[idx];
              saidContainer.appendChild(intSpan);
              idx++;
              simulationTimer = setTimeout(nextWord, 500);
            } else {
              finalResultText = demoTokens.join(' ');
              simulationTimer = setTimeout(function () {
                setState('done');
              }, 1200);
            }
          }
          nextWord();
        }
      }, 1000);
    }

    micBtn.addEventListener('click', function () {
      if (state === 'listen') {
        if (!finalResultText && !recognizedWords) {
          finalResultText = 'రామేష్‌కి 5 కిలోల బియ్యం అప్పు ఇచ్చాను, 300 రూపాయలు';
        }
        setState('done');
      } else if (state === 'blocked') {
        router.toast('Microphone is blocked. Type instead.');
      } else {
        setState('listen');
      }
    });

    setState('listen');
    return el;
  }

  window.LOG.screens.listen = {
    render: render,
    cleanup: cleanupRecognizer
  };
})(window);
