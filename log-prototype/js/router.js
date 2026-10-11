/**
 * LOG Prototype - Router & Screen Registry
 * Screen navigation, history tracking, bottom nav control, bottom sheet manager,
 * and the complete 16-screen registry with links in / links out.
 */

(function (window) {
  'use strict';

  // The 16 screens registry matching Section 2 specification
  var REGISTRY = {
    'setup': {
      route: '#/setup',
      type: 'hidden',
      title: 'First-time Setup · ప్రారంభ సెటప్',
      showNav: false,
      navHighlight: null,
      parent: null,
      linksOut: ['home'],
      linksIn: ['settings'] // via Reset prototype
    },
    'home': {
      route: '#/home',
      type: 'main',
      title: 'LOG · Home',
      showNav: true,
      navHighlight: 'home',
      parent: null,
      linksOut: ['settings', 'transactions', 'dashboard', 'confirm', 'listen', 'recount'],
      linksIn: ['setup', 'confirm', 'transactions', 'settings', 'more']
    },
    'more': {
      route: '#/more',
      type: 'main',
      title: 'More · మరిన్ని',
      showNav: true,
      navHighlight: 'more',
      parent: 'home',
      linksOut: ['udhar', 'stock', 'dashboard', 'ask'],
      linksIn: ['home', 'bottom-nav']
    },
    'udhar': {
      route: '#/udhar',
      type: 'main',
      title: 'Udhar · ఉధార్',
      showNav: true,
      navHighlight: 'more',
      parent: 'more',
      linksOut: ['udhar-detail'],
      linksIn: ['more']
    },
    'stock': {
      route: '#/stock',
      type: 'main',
      title: 'Stock · స్టాక్',
      showNav: true,
      navHighlight: 'more',
      parent: 'more',
      linksOut: ['stock-detail', 'recount'],
      linksIn: ['more', 'ask', 'recount']
    },
    'dashboard': {
      route: '#/dashboard',
      type: 'main',
      title: 'Dashboard · డాష్‌బోర్డ్',
      showNav: true,
      navHighlight: 'more',
      parent: 'more',
      linksOut: [],
      linksIn: ['more', 'home']
    },
    'ask': {
      route: '#/ask',
      type: 'main',
      title: 'Ask · అడగండి',
      showNav: true,
      navHighlight: 'more',
      parent: 'more',
      linksOut: ['udhar-detail', 'stock'],
      linksIn: ['more']
    },
    'transactions': {
      route: '#/transactions',
      type: 'supporting',
      title: 'All transactions · లావాదేవీలు',
      showNav: true,
      navHighlight: 'home',
      parent: 'home',
      linksOut: ['confirm'],
      linksIn: ['home']
    },
    'udhar-detail': {
      route: '#/udhar/:customerId',
      type: 'supporting',
      title: 'Customer detail · ఉధార్',
      showNav: true,
      navHighlight: 'more',
      parent: 'udhar',
      linksOut: ['confirm'],
      linksIn: ['udhar', 'customers', 'ask']
    },
    'stock-detail': {
      route: '#/stock/:itemId',
      type: 'supporting',
      title: 'Stock detail · స్టాక్',
      showNav: true,
      navHighlight: 'more',
      parent: 'stock',
      linksOut: ['confirm'],
      linksIn: ['stock', 'items']
    },
    'customers': {
      route: '#/customers',
      type: 'supporting',
      title: 'Customers · కస్టమర్లు',
      showNav: true,
      navHighlight: 'more',
      parent: 'settings',
      linksOut: ['udhar-detail'],
      linksIn: ['settings']
    },
    'items': {
      route: '#/items',
      type: 'supporting',
      title: 'Items · వస్తువులు',
      showNav: true,
      navHighlight: 'more',
      parent: 'settings',
      linksOut: ['stock-detail'],
      linksIn: ['settings']
    },
    'settings': {
      route: '#/settings',
      type: 'supporting',
      title: 'Settings · సెట్టింగ్‌లు',
      showNav: true,
      navHighlight: 'home',
      parent: 'home',
      linksOut: ['customers', 'items', 'setup'],
      linksIn: ['home']
    },
    'listen': {
      route: '#/listen',
      type: 'hidden',
      title: 'Listening · వింటున్నాను',
      showNav: false,
      navHighlight: null,
      parent: 'home',
      linksOut: ['confirm'],
      linksIn: ['home', 'bottom-nav', 'confirm', 'ask']
    },
    'confirm': {
      route: '#/confirm',
      type: 'hidden',
      title: 'Confirm entry · నిర్ధారించండి',
      showNav: false,
      navHighlight: null,
      parent: 'home',
      linksOut: ['home'],
      linksIn: ['listen', 'home', 'transactions', 'udhar-detail', 'stock-detail']
    },
    'recount': {
      route: '#/recount',
      type: 'hidden',
      title: 'Weekly recount · వారం వారీ లెక్క',
      showNav: false,
      navHighlight: null,
      parent: 'stock',
      linksOut: ['stock'],
      linksIn: ['stock', 'home']
    }
  };

  var historyStack = [];
  var currentRouteName = null;
  var currentParams = {};
  var activeSheet = null;
  var previousActiveElement = null;
  var toastTimer = null;
  var snackTimer = null;

  var Router = {
    registry: REGISTRY,

    init: function () {
      var self = this;

      // Handle browser back and forward
      window.addEventListener('hashchange', function () {
        self.handleHashChange();
      });

      // Handle keyboard Escape for bottom sheets
      window.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && activeSheet) {
          self.closeSheet();
        }
      });

      // Handle scrim click to close bottom sheets
      var scrim = document.getElementById('global-scrim');
      if (scrim) {
        scrim.addEventListener('click', function () {
          self.closeSheet();
        });
      }

      // Setup bottom nav listeners
      var navHome = document.getElementById('nav-home');
      var navSpeak = document.getElementById('nav-speak');
      var navMore = document.getElementById('nav-more');

      if (navHome) {
        navHome.addEventListener('click', function () {
          self.navigate('home');
        });
      }
      if (navSpeak) {
        navSpeak.addEventListener('click', function () {
          self.navigate('listen');
        });
      }
      if (navMore) {
        navMore.addEventListener('click', function () {
          self.navigate('more');
        });
      }

      // Handle initial route
      var store = window.LOG.store;
      var state = store ? store.getState() : null;

      if (!state || !state.setupDone) {
        self.navigate('setup', {}, true);
      } else {
        self.handleHashChange();
      }
    },

    matchRoute: function (hash) {
      if (!hash || hash === '#' || hash === '#/') {
        return { name: 'home', params: {} };
      }

      var cleanHash = hash.split('?')[0];

      // Exact matches
      for (var name in REGISTRY) {
        var conf = REGISTRY[name];
        if (conf.route === cleanHash) {
          return { name: name, params: {} };
        }
      }

      // Parameterized matches
      // #/udhar/:customerId
      var udharMatch = cleanHash.match(/^#\/udhar\/([^\/]+)$/);
      if (udharMatch) {
        return { name: 'udhar-detail', params: { customerId: udharMatch[1] } };
      }

      // #/stock/:itemId
      var stockMatch = cleanHash.match(/^#\/stock\/([^\/]+)$/);
      if (stockMatch) {
        return { name: 'stock-detail', params: { itemId: stockMatch[1] } };
      }

      return null;
    },

    handleHashChange: function () {
      var hash = window.location.hash;
      var match = this.matchRoute(hash);

      if (!match) {
        console.warn('[LOG router] Unregistered route rejected:', hash);
        this.navigate('home', {}, true);
        return;
      }

      // Check if setup is needed
      var store = window.LOG.store;
      if (store && !store.getState().setupDone && match.name !== 'setup') {
        this.navigate('setup', {}, true);
        return;
      }

      this.loadScreen(match.name, match.params);
    },

    navigate: function (name, params, replace) {
      var conf = REGISTRY[name];
      if (!conf) {
        console.error('[LOG router] Refusing to open unregistered screen:', name);
        return;
      }

      params = params || {};
      var targetHash = conf.route;
      if (name === 'udhar-detail') {
        targetHash = '#/udhar/' + (params.customerId || 'c1');
      } else if (name === 'stock-detail') {
        targetHash = '#/stock/' + (params.itemId || 'i1');
      }

      // Track history
      if (currentRouteName && currentRouteName !== name) {
        historyStack.push({ name: currentRouteName, params: currentParams });
      }

      if (replace) {
        window.location.replace(targetHash);
      } else {
        window.location.hash = targetHash;
      }
    },

    back: function () {
      // Close any open bottom sheet first
      if (activeSheet) {
        this.closeSheet();
        return;
      }

      if (historyStack.length > 0) {
        var prev = historyStack.pop();
        this.navigate(prev.name, prev.params, true);
      } else {
        var conf = REGISTRY[currentRouteName];
        if (conf && conf.parent) {
          this.navigate(conf.parent, {}, true);
        } else {
          this.navigate('home', {}, true);
        }
      }
    },

    loadScreen: function (name, params) {
      var conf = REGISTRY[name];
      if (!conf) return;

      currentRouteName = name;
      currentParams = params || {};

      // Close sheets and stop any voice recognizer
      this.closeSheet();
      if (window.LOG.screens && window.LOG.screens.listen && typeof window.LOG.screens.listen.cleanup === 'function') {
        window.LOG.screens.listen.cleanup();
      }

      // Update document title
      document.title = conf.title || 'LOG Kirana';

      // Update phone frame styling (Listening screen is full white)
      var appFrame = document.querySelector('.app');
      if (appFrame) {
        appFrame.classList.toggle('is-white-screen', name === 'listen');
      }

      // Update Bottom Nav visibility and highlight
      var navBar = document.getElementById('bottom-nav');
      if (navBar) {
        navBar.style.display = conf.showNav ? 'grid' : 'none';
        var navHome = document.getElementById('nav-home');
        var navMore = document.getElementById('nav-more');

        if (navHome) {
          if (conf.navHighlight === 'home') {
            navHome.setAttribute('aria-current', 'page');
          } else {
            navHome.removeAttribute('aria-current');
          }
        }
        if (navMore) {
          if (conf.navHighlight === 'more') {
            navMore.setAttribute('aria-current', 'page');
          } else {
            navMore.removeAttribute('aria-current');
          }
        }
      }

      // Render the active screen
      var container = document.getElementById('screen-viewport');
      if (!container) return;

      var screenModule = window.LOG.screens[name];
      if (screenModule && typeof screenModule.render === 'function') {
        container.innerHTML = '';
        var screenEl = screenModule.render(params);
        if (screenEl) {
          container.appendChild(screenEl);
        }
      } else {
        container.innerHTML = '<div style="padding:20px;text-align:center"><h2>' + conf.title + '</h2><p>Screen under construction.</p></div>';
      }
    },

    // ==========================================
    // BOTTOM SHEET & OVERLAY MANAGER
    // ==========================================

    openSheet: function (sheetEl, triggerEl) {
      if (!sheetEl) return;
      this.closeSheet();

      activeSheet = sheetEl;
      previousActiveElement = triggerEl || document.activeElement;

      var scrim = document.getElementById('global-scrim');
      if (scrim) {
        scrim.classList.add('show');
      }

      if (!sheetEl.parentElement) {
        sheetEl.classList.add('sheet');
        sheetEl._isDynamic = true;
        var app = document.querySelector('.app');
        if (app) app.appendChild(sheetEl);
      }

      sheetEl.classList.add('show');
      sheetEl.setAttribute('role', 'dialog');
      sheetEl.setAttribute('aria-modal', 'true');

      // Focus first actionable input or button inside sheet
      var focusable = sheetEl.querySelector('input:not([disabled]), button:not([disabled]), [tabindex="0"]');
      if (focusable) {
        setTimeout(function () { focusable.focus(); }, 60);
      }
    },

    closeSheet: function () {
      if (!activeSheet) return;

      var scrim = document.getElementById('global-scrim');
      if (scrim) {
        scrim.classList.remove('show');
      }

      activeSheet.classList.remove('show');
      var sheetToClose = activeSheet;
      activeSheet = null;

      if (previousActiveElement && typeof previousActiveElement.focus === 'function') {
        try { previousActiveElement.focus(); } catch (e) {}
      }
      previousActiveElement = null;

      // Custom onclose hook if present
      if (typeof sheetToClose.onSheetClosed === 'function') {
        sheetToClose.onSheetClosed();
      }

      if (sheetToClose._isDynamic) {
        setTimeout(function () {
          if (sheetToClose.parentElement) sheetToClose.parentElement.removeChild(sheetToClose);
        }, 280);
      }
    },

    // ==========================================
    // TOAST & SNACKBAR
    // ==========================================

    toast: function (message) {
      var t = document.getElementById('global-toast');
      if (!t) return;
      t.textContent = message;
      t.classList.add('on');
      clearTimeout(toastTimer);
      toastTimer = setTimeout(function () {
        t.classList.remove('on');
      }, 2400);
    },

    showToast: function (message) {
      this.toast(message);
    },

    snack: function (message, onUndo) {
      var s = document.getElementById('global-snack');
      var sm = document.getElementById('snack-msg');
      var undoBtn = document.getElementById('snack-undo');
      if (!s || !sm || !undoBtn) return;

      sm.textContent = message;
      undoBtn.hidden = !onUndo;

      // Remove existing listener
      var newBtn = undoBtn.cloneNode(true);
      undoBtn.parentNode.replaceChild(newBtn, undoBtn);

      if (onUndo) {
        newBtn.addEventListener('click', function () {
          s.classList.remove('on');
          onUndo();
        });
      }

      s.classList.add('on');
      clearTimeout(snackTimer);
      snackTimer = setTimeout(function () {
        s.classList.remove('on');
      }, 3800);
    },

    // ==========================================
    // SCREEN MAP PRINTER HELPER
    // ==========================================

    printScreenMap: function () {
      var rows = [];
      for (var key in REGISTRY) {
        var s = REGISTRY[key];
        rows.push({
          Route: s.route,
          Type: s.type,
          Nav: s.showNav ? (s.navHighlight || 'Yes') : 'Hidden',
          Parent: s.parent || 'None',
          'Links In': s.linksIn.join(', '),
          'Links Out': s.linksOut.join(', ')
        });
      }
      console.log('=== LOG APP SCREEN MAP (16 SCREENS) ===');
      console.table(rows);
      return rows;
    }
  };

  window.LOG = window.LOG || {};
  window.LOG.router = Router;
  window.LOG.screens = window.LOG.screens || {};
})(window);
