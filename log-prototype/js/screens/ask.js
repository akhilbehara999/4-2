/**
 * LOG Prototype - Ask Screen (#/ask)
 * Voice and text Kirana assistant answering questions about live udhar, stock, sales, and profit.
 */

(function (window) {
  'use strict';

  var SUGGESTIONS = [
    'రామేష్ కి ఎంత ఉధార్ ఉంది?',
    'ఈ రోజు ఎంత సేల్స్?',
    'ఏ వస్తువులు తక్కువ ఉన్నాయి?',
    'ఈ వారం లాభం ఎంత?'
  ];

  function render() {
    var engine = window.LOG.engine;
    var router = window.LOG.router;
    var store = window.LOG.store;
    var settings = store ? store.getState().settings : {};
    var voiceLang = settings.voiceLanguage === 'en_IN' ? 'en-IN' : 'te-IN';

    var el = document.createElement('div');
    el.className = 'screen ask-screen';
    el.style.cssText = 'display:flex;flex-direction:column;min-height:100%';

    el.innerHTML = [
      '<div class="top">',
      '  <button class="ib" id="ask-back" aria-label="Back" type="button"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg></button>',
      '  <h1>Ask<span>అడగండి</span></h1>',
      '</div>',
      '<div class="chat" id="ask-chat" aria-live="polite" style="flex:1;min-height:0;overflow-y:auto;padding:8px 16px;display:flex;flex-direction:column;gap:12px">',
      '  <div style="text-align:center;color:var(--muted);font:400 14px var(--te);padding:4px 0 2px">మీ దుకాణం గురించి అడగండి · Ask about your shop</div>',
      '  <div class="m a" style="align-self:flex-start;background:var(--container);border-radius:20px;border-bottom-left-radius:6px;padding:12px 16px;font:400 16px/1.5 var(--te);max-width:86%">నమస్కారం! ఉధార్, అమ్మకాలు, స్టాక్ లేదా లాభం గురించి అడగండి.<small style="display:block;color:var(--muted);font:400 13px var(--f);margin-top:2px">Ask about udhar, sales, stock or profit.</small></div>',
      '</div>',
      '<!-- Suggestions Chips -->',
      '<div class="chips" id="ask-sug" style="padding:4px 16px 8px;flex:none;overflow-x:auto"></div>',
      '<!-- Input Form with Mic and Send -->',
      '<form id="ask-form" style="display:flex;gap:8px;padding:4px 16px 8px;align-items:center;flex:none">',
      '  <div style="flex:1;min-width:0;position:relative">',
      '    <input id="ask-input" placeholder="Type or speak · అడగండి" aria-label="Your question" autocomplete="off" style="width:100%;height:56px;border-radius:28px;border:0;background:var(--container);color:var(--fg);padding:0 56px 0 20px;font:400 16px var(--te)">',
      '    <button type="button" class="ib" id="ask-mic" aria-label="Speak your question" style="position:absolute;right:6px;top:6px;width:44px;height:44px;border-radius:50%;border:0;background:var(--accent-tonal);color:var(--accent);display:grid;place-items:center"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="2" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v4"/></svg></button>',
      '  </div>',
      '  <button class="ib" id="ask-send" type="submit" aria-label="Send" style="width:56px;height:56px;border-radius:50%;border:0;background:var(--accent);color:var(--on-accent);display:grid;place-items:center;flex:none"><svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><path d="M3 20.5 21 12 3 3.5l.01 6.6L15 12 3.01 13.9z"/></svg></button>',
      '</form>'
    ].join('\n');

    el.querySelector('#ask-back').addEventListener('click', function () {
      router.back();
    });

    var chatBox = el.querySelector('#ask-chat');
    var inputEl = el.querySelector('#ask-input');
    var micBtn = el.querySelector('#ask-mic');
    var formEl = el.querySelector('#ask-form');
    var sugBox = el.querySelector('#ask-sug');

    function appendMessage(isUser, contentHtml, resultObj) {
      var msg = document.createElement('div');
      msg.className = 'm ' + (isUser ? 'u' : 'a');

      if (isUser) {
        msg.style.cssText = 'align-self:flex-end;background:var(--accent);color:var(--on-accent);border-radius:20px;border-bottom-right-radius:6px;padding:12px 16px;font:400 16px/1.5 var(--te);max-width:86%;overflow-wrap:anywhere';
        msg.textContent = contentHtml;
      } else {
        msg.style.cssText = 'align-self:flex-start;background:var(--container);border-radius:20px;border-bottom-left-radius:6px;padding:12px 16px;font:400 16px/1.5 var(--te);max-width:86%;overflow-wrap:anywhere';
        msg.innerHTML = contentHtml;

        // If response includes an actionable result card
        if (resultObj) {
          if (resultObj.type === 'customer_udhar') {
            var card = document.createElement('div');
            card.style.cssText = 'margin-top:10px;background:var(--card);border:1px solid var(--line);border-radius:16px;padding:12px;display:flex;flex-direction:column;gap:10px';
            card.innerHTML = [
              '<div style="display:flex;justify-content:space-between;align-items:baseline;gap:8px;font:500 15px var(--f)">',
              '  <span>' + resultObj.customerName + (resultObj.customerNameTe ? ' · ' + resultObj.customerNameTe : '') + '</span>',
              '  <strong style="font:700 20px var(--f);font-variant-numeric:tabular-nums">' + engine.inr(resultObj.balance) + '</strong>',
              '</div>',
              '<button class="btn fill" type="button" style="height:44px;font-size:15px">జమ · Payment received</button>'
            ].join('\n');

            card.querySelector('button').addEventListener('click', function () {
              router.navigate('udhar-detail', { customerId: resultObj.customerId });
            });
            msg.appendChild(card);
          } else if (resultObj.type === 'low_stock') {
            var card2 = document.createElement('div');
            card2.style.cssText = 'margin-top:10px;background:var(--card);border:1px solid var(--line);border-radius:16px;padding:12px;display:flex;flex-direction:column;gap:8px;cursor:pointer';
            var tagsHtml = (resultObj.items || []).map(function (it) {
              return '<span style="background:var(--red-tonal);color:var(--red);border-radius:8px;padding:3px 10px;font:500 13px var(--f)">' + it + '</span>';
            }).join(' ');
            card2.innerHTML = '<div style="display:flex;flex-wrap:wrap;gap:6px">' + tagsHtml + '</div><div style="font:500 13px var(--f);color:var(--accent);margin-top:4px">View stock list →</div>';
            card2.addEventListener('click', function () {
              router.navigate('stock');
            });
            msg.appendChild(card2);
          }
        }
      }

      chatBox.appendChild(msg);
      chatBox.scrollTop = chatBox.scrollHeight;
    }

    function handleAsk(queryText) {
      var q = (queryText || '').trim();
      if (!q) return;

      appendMessage(true, q);

      // Typing animation
      var typingEl = document.createElement('div');
      typingEl.style.cssText = 'align-self:flex-start;background:var(--container);border-radius:20px;border-bottom-left-radius:6px;padding:14px 16px;display:flex;gap:5px';
      typingEl.innerHTML = '<i style="width:7px;height:7px;border-radius:50%;background:var(--muted);animation:barBounce 1s infinite"></i><i style="width:7px;height:7px;border-radius:50%;background:var(--muted);animation:barBounce 1s infinite .15s"></i><i style="width:7px;height:7px;border-radius:50%;background:var(--muted);animation:barBounce 1s infinite .3s"></i>';
      chatBox.appendChild(typingEl);
      chatBox.scrollTop = chatBox.scrollHeight;

      setTimeout(function () {
        typingEl.remove();
        var ans = engine.answerQuestion(q);
        appendMessage(false, ans.html, ans);
      }, 500);
    }

    // Populate suggestions chips
    SUGGESTIONS.forEach(function (s) {
      var chip = document.createElement('button');
      chip.type = 'button';
      chip.className = 'chip';
      chip.textContent = s;
      chip.style.cssText = 'flex:none;min-height:40px;padding:0 16px;border-radius:12px;border:1px solid var(--line);background:none;color:var(--fg);font:400 14px var(--te);cursor:pointer;white-space:nowrap';
      chip.addEventListener('click', function () {
        handleAsk(s);
      });
      sugBox.appendChild(chip);
    });

    formEl.addEventListener('submit', function (e) {
      e.preventDefault();
      var txt = inputEl.value;
      inputEl.value = '';
      handleAsk(txt);
    });

    // Mic button inside Ask
    var micActive = false;
    var micTimer = null;
    micBtn.addEventListener('click', function () {
      micActive = !micActive;
      if (micActive) {
        micBtn.style.background = 'var(--red)';
        micBtn.style.color = '#fff';
        inputEl.placeholder = 'Listening… · వింటున్నాను…';

        var Speech = window.SpeechRecognition || window.webkitSpeechRecognition;
        if (Speech) {
          try {
            var r = new Speech();
            r.lang = voiceLang;
            r.onresult = function (ev) {
              var heard = ev.results[0][0].transcript;
              micActive = false;
              micBtn.style.background = 'var(--accent-tonal)';
              micBtn.style.color = 'var(--accent)';
              inputEl.placeholder = 'Type or speak · అడగండి';
              handleAsk(heard);
            };
            r.onerror = function () {
              micActive = false;
              micBtn.style.background = 'var(--accent-tonal)';
              micBtn.style.color = 'var(--accent)';
              inputEl.placeholder = 'Type or speak · అడగండి';
              handleAsk('ఈ రోజు ఎంత సేల్స్?');
            };
            r.start();
          } catch (e) {
            fallbackSimulate();
          }
        } else {
          fallbackSimulate();
        }
      } else {
        micBtn.style.background = 'var(--accent-tonal)';
        micBtn.style.color = 'var(--accent)';
        inputEl.placeholder = 'Type or speak · అడగండి';
        clearTimeout(micTimer);
      }

      function fallbackSimulate() {
        clearTimeout(micTimer);
        micTimer = setTimeout(function () {
          micActive = false;
          micBtn.style.background = 'var(--accent-tonal)';
          micBtn.style.color = 'var(--accent)';
          inputEl.placeholder = 'Type or speak · అడగండి';
          handleAsk('ఈ రోజు ఎంత సేల్స్?');
        }, 1600);
      }
    });

    // Opening sample exchange
    appendMessage(true, 'రామేష్ కి ఎంత ఉధార్ ఉంది?');
    var initAns = engine.answerQuestion('ramesh');
    appendMessage(false, initAns.html, initAns);

    return el;
  }

  window.LOG.screens.ask = {
    render: render
  };
})(window);
