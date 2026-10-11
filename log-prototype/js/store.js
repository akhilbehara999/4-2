/**
 * LOG Prototype - Store (State + Persistence)
 * Single source of truth for the LOG application.
 * All numbers and balances are derived dynamically from raw entries and item states.
 */

(function (window) {
  'use strict';

  var STORAGE_KEY = 'log_shop_data_v1';
  var listeners = [];
  var saveTimer = null;

  // Helper to create timestamps relative to now
  function daysAgo(d, hoursOffset, minutesOffset) {
    var now = new Date();
    var target = new Date(now.getFullYear(), now.getMonth(), now.getDate() - d, hoursOffset || 10, minutesOffset || 15);
    return target.toISOString();
  }

  // Initial consistent seed data
  function getSeedData() {
    return {
      setupDone: true, // Will be set to false if localStorage is completely cleared
      weeklyCheckDone: false,
      lastBackupAt: 'today, 9:12 AM',
      settings: {
        shopName: 'Sri Lakshmi Kirana',
        shopNameTe: 'శ్రీ లక్ష్మి కిరాణా',
        owner: 'Lakshmi Narayana',
        appLanguage: 'both', // 'both' | 'te' | 'en'
        voiceLanguage: 'te_IN', // 'te_IN' | 'en_IN'
        theme: '', // '' (system) | 'light' | 'dark'
        weeklyCheck: {
          on: true,
          day: 'Sunday',
          time: '8:00 AM'
        },
        lowStockAlerts: true,
        overdueAlert: true,
        overdueDays: 15
      },
      customers: [
        { id: 'c1', name: 'Ramesh', nameTe: 'రామేష్', phone: '+91 98480 12345' },
        { id: 'c2', name: 'Venkat Rao', nameTe: 'వెంకట్ రావు', phone: '+91 98123 90561' },
        { id: 'c3', name: 'Lakshmi', nameTe: 'లక్ష్మి', phone: '+91 98851 30942' },
        { id: 'c4', name: 'Suresh', nameTe: 'సురేష్', phone: '+91 99890 61472' },
        { id: 'c5', name: 'Padma', nameTe: 'పద్మ', phone: '+91 98660 53307' },
        { id: 'c6', name: 'Naresh', nameTe: 'నరేష్', phone: '+91 97030 18864' },
        { id: 'c7', name: 'Anitha', nameTe: 'అనిత', phone: '+91 98490 22110' },
        { id: 'c8', name: 'Kiran', nameTe: 'కిరణ్', phone: '+91 99120 45873' },
        { id: 'c9', name: 'Mahesh', nameTe: 'మహేష్', phone: '+91 94400 77215' },
        { id: 'c10', name: 'Ravi', nameTe: 'రవి', phone: '' },
        { id: 'c11', name: 'Sunitha', nameTe: 'సునీత', phone: '+91 96760 40128' }
      ],
      items: [
        {
          id: 'i1',
          name: 'Rice',
          nameTe: 'బియ్యం',
          unit: 'kg',
          price: 60,
          reorderLevel: 5,
          spokenNames: ['biyyam', 'rice', 'బియ్యం', 'బియ్యము'],
          qty: 3 // Low (red, ~1 day left)
        },
        {
          id: 'i2',
          name: 'Toor dal',
          nameTe: 'కందిపప్పు',
          unit: 'kg',
          price: 96,
          reorderLevel: 3,
          spokenNames: ['kandipappu', 'pappu', 'toor dal', 'కందిపప్పు', 'పప్పు'],
          qty: 1 // Low (red, ~1 day left)
        },
        {
          id: 'i3',
          name: 'Cooking oil',
          nameTe: 'నూనె',
          unit: 'L',
          price: 140,
          reorderLevel: 3,
          spokenNames: ['nune', 'oil', 'cooking oil', 'నూనె'],
          qty: 2 // Low (red, ~2 days left)
        },
        {
          id: 'i4',
          name: 'Sugar',
          nameTe: 'చక్కెర',
          unit: 'kg',
          price: 60,
          reorderLevel: 6,
          spokenNames: ['chakkera', 'sugar', 'చక్కెర'],
          qty: 6 // Getting low (amber, ~4 days left)
        },
        {
          id: 'i5',
          name: 'Wheat flour',
          nameTe: 'గోధుమ పిండి',
          unit: 'kg',
          price: 42,
          reorderLevel: 6,
          spokenNames: ['godhuma pindi', 'atta', 'wheat flour', 'గోధుమ పిండి'],
          qty: 8 // Getting low (amber, ~5 days left)
        },
        {
          id: 'i6',
          name: 'Salt',
          nameTe: 'ఉప్పు',
          unit: 'kg',
          price: 22,
          reorderLevel: 5,
          spokenNames: ['uppu', 'salt', 'ఉప్పు'],
          qty: 14 // Fine (green, ~30 days left)
        },
        {
          id: 'i7',
          name: 'Tea powder',
          nameTe: 'టీ పొడి',
          unit: 'kg',
          price: 350,
          reorderLevel: 1,
          spokenNames: ['tea', 'chai', 'teapodi', 'టీ పొడి'],
          qty: 3 // Fine (green, ~12 days left)
        },
        {
          id: 'i8',
          name: 'Chilli powder',
          nameTe: 'కారం',
          unit: 'kg',
          price: 320,
          reorderLevel: 1,
          spokenNames: ['karam', 'chilli', 'కారం'],
          qty: 2 // Fine (green, ~9 days left)
        },
        {
          id: 'i9',
          name: 'Soap',
          nameTe: 'సబ్బు',
          unit: 'pcs',
          price: 35,
          reorderLevel: 10,
          spokenNames: ['sabbu', 'soap', 'సబ్బు'],
          qty: 24 // Grey (no usage data yet)
        }
      ],
      // Seed entries configured so all prompt constraints hold
      entries: [
        // --- Ramesh (c1) history (Total balance: ₹4,200. Last entry: 21 days ago -> Overdue!) ---
        { id: 'e1', type: 'credit', customerId: 'c1', itemId: null, qty: null, unit: null, amount: 2500, spokenText: 'రామేష్ ప్రారంభ నిల్వ 2500', createdAt: daysAgo(60, 11, 0) },
        { id: 'e2', type: 'credit', customerId: 'c1', itemId: 'i4', qty: 10, unit: 'kg', amount: 600, spokenText: 'రామేష్‌కి 10 కిలోల చక్కెర అప్పు', createdAt: daysAgo(54, 16, 20) },
        { id: 'e3', type: 'credit', customerId: 'c1', itemId: 'i5', qty: 20, unit: 'kg', amount: 840, spokenText: 'రామేష్‌కి 20 కిలోల గోధుమ పిండి అప్పు', createdAt: daysAgo(44, 10, 45) },
        { id: 'e4', type: 'credit', customerId: 'c1', itemId: 'i3', qty: 5, unit: 'L', amount: 700, spokenText: 'రామేష్‌కి 5 లీటర్ల నూనె అప్పు', createdAt: daysAgo(38, 17, 10) },
        { id: 'e5', type: 'pay', customerId: 'c1', itemId: null, qty: null, unit: null, amount: 1000, spokenText: 'రామేష్ వెయ్యి రూపాయలు ఇచ్చాడు', createdAt: daysAgo(34, 12, 30) },
        { id: 'e6', type: 'credit', customerId: 'c1', itemId: 'i2', qty: 2, unit: 'kg', amount: 260, spokenText: 'రామేష్‌కి 2 కిలోల కందిపప్పు అప్పు', createdAt: daysAgo(25, 14, 15) },
        { id: 'e7', type: 'credit', customerId: 'c1', itemId: 'i1', qty: 5, unit: 'kg', amount: 300, spokenText: 'రామేష్‌కి 5 కిలోల బియ్యం అప్పు', createdAt: daysAgo(21, 18, 0) },

        // --- Venkat Rao (c2) owes ₹2,300, last entry 18 days ago -> Overdue! ---
        { id: 'e8', type: 'credit', customerId: 'c2', itemId: null, qty: null, unit: null, amount: 1880, spokenText: 'వెంకట్ రావు పాత బాకీ', createdAt: daysAgo(30, 9, 30) },
        { id: 'e9', type: 'credit', customerId: 'c2', itemId: 'i5', qty: 10, unit: 'kg', amount: 420, spokenText: 'వెంకట్ రావుకి 10 కిలోల గోధుమ పిండి అప్పు', createdAt: daysAgo(18, 11, 20) },

        // --- Lakshmi (c3) owes ₹1,850 (2,350 credit - 500 payment today) ---
        { id: 'e10', type: 'credit', customerId: 'c3', itemId: null, qty: null, unit: null, amount: 2350, spokenText: 'లక్ష్మి బాకీ', createdAt: daysAgo(2, 16, 40) },

        // --- Suresh (c4) owes ₹950, last entry 5 days ago ---
        { id: 'e11', type: 'credit', customerId: 'c4', itemId: null, qty: null, unit: null, amount: 600, spokenText: 'సురేష్ అప్పు', createdAt: daysAgo(14, 15, 0) },
        { id: 'e12', type: 'credit', customerId: 'c4', itemId: 'i7', qty: 1, unit: 'kg', amount: 350, spokenText: 'సురేష్‌కి కిలో టీ పొడి అప్పు', createdAt: daysAgo(5, 10, 10) },

        // --- Naresh (c6) owes ₹800, last entry 9 days ago ---
        { id: 'e13', type: 'credit', customerId: 'c6', itemId: null, qty: null, unit: null, amount: 800, spokenText: 'నరేష్ అప్పు', createdAt: daysAgo(9, 17, 30) },

        // --- Anitha (c7) owes ₹550, last entry 3 days ago ---
        { id: 'e14', type: 'credit', customerId: 'c7', itemId: null, qty: null, unit: null, amount: 550, spokenText: 'అనిత అప్పు', createdAt: daysAgo(3, 11, 0) },

        // --- Kiran (c8) owes ₹400, last entry 12 days ago ---
        { id: 'e15', type: 'credit', customerId: 'c8', itemId: null, qty: null, unit: null, amount: 400, spokenText: 'కిరణ్ అప్పు', createdAt: daysAgo(12, 14, 20) },

        // --- Padma (c5) owes ₹1,400 (prior ₹200 + ₹1,200 today credit) ---
        { id: 'e16', type: 'credit', customerId: 'c5', itemId: null, qty: null, unit: null, amount: 200, spokenText: 'పద్మ పాత బాకీ', createdAt: daysAgo(10, 15, 0) },

        // =========================================================================
        // TODAY'S ENTRIES (Day 0)
        // Today's Sales = ₹4,820 (Credit ₹1,200 + Cash ₹3,620)
        // Today's Expenses = ₹680
        // Today's Profit = Cash (₹3,620) - Exp (₹680) = ₹2,940!
        // =========================================================================
        {
          id: 'e17',
          type: 'credit',
          customerId: 'c5', // Padma takes ₹1,200 credit today -> Total Padma udhar becomes ₹1,400!
          itemId: 'i2',
          qty: 12.5,
          unit: 'kg',
          amount: 1200,
          spokenText: 'పద్మకి 12 కిలోల పప్పు అప్పు 1200 రూపాయలు',
          createdAt: daysAgo(0, 9, 30)
        },
        {
          id: 'e18',
          type: 'cash',
          customerId: null,
          itemId: 'i4',
          qty: 2,
          unit: 'kg',
          amount: 120,
          spokenText: 'రెండు కిలోల చక్కెర అమ్మాను, 120 రూపాయలు',
          createdAt: daysAgo(0, 10, 15)
        },
        {
          id: 'e19',
          type: 'cash',
          customerId: null,
          itemId: 'i1',
          qty: 15,
          unit: 'kg',
          amount: 900,
          spokenText: 'బియ్యం నగదు అమ్మకం 900 రూపాయలు',
          createdAt: daysAgo(0, 11, 40)
        },
        {
          id: 'e20',
          type: 'cash',
          customerId: null,
          itemId: 'i3',
          qty: 5,
          unit: 'L',
          amount: 700,
          spokenText: 'ఐదు లీటర్ల నూనె అమ్మాను 700 రూపాయలు',
          createdAt: daysAgo(0, 13, 10)
        },
        {
          id: 'e21',
          type: 'cash',
          customerId: null,
          itemId: 'i2',
          qty: 7,
          unit: 'kg',
          amount: 672,
          spokenText: 'కందిపప్పు నగదు అమ్మకం',
          createdAt: daysAgo(0, 14, 25)
        },
        {
          id: 'e22',
          type: 'cash',
          customerId: null,
          itemId: 'i5',
          qty: 15,
          unit: 'kg',
          amount: 630,
          spokenText: 'గోధుమ పిండి నగదు అమ్మకం 630',
          createdAt: daysAgo(0, 15, 30)
        },
        {
          id: 'e23',
          type: 'cash',
          customerId: null,
          itemId: 'i7',
          qty: 1.5,
          unit: 'kg',
          amount: 525,
          spokenText: 'టీ పొడి నగదు 525',
          createdAt: daysAgo(0, 16, 45)
        },
        {
          id: 'e24',
          type: 'cash',
          customerId: null,
          itemId: 'i6',
          qty: 3.3,
          unit: 'kg',
          amount: 73,
          spokenText: 'ఉప్పు అమ్మకం 73',
          createdAt: daysAgo(0, 17, 10)
        },
        // Total cash today: 120 + 900 + 700 + 672 + 630 + 525 + 73 = 3620.
        // Plus credit today: 1200. Total sales = 4820!

        // Expenses today (Total: ₹680):
        {
          id: 'e25',
          type: 'exp',
          customerId: null,
          itemId: null,
          qty: null,
          unit: null,
          amount: 80,
          spokenText: 'కరెంటు బిల్లు ఎనభై',
          createdAt: daysAgo(0, 11, 0)
        },
        {
          id: 'e26',
          type: 'exp',
          customerId: null,
          itemId: null,
          qty: null,
          unit: null,
          amount: 120,
          spokenText: 'రవాణా నూట ఇరవై',
          createdAt: daysAgo(0, 12, 20)
        },
        {
          id: 'e27',
          type: 'exp',
          customerId: null,
          itemId: null,
          qty: null,
          unit: null,
          amount: 400,
          spokenText: 'సరుకు రీస్టాక్ ఖర్చు 400',
          createdAt: daysAgo(0, 14, 0)
        },
        {
          id: 'e28',
          type: 'exp',
          customerId: null,
          itemId: null,
          qty: null,
          unit: null,
          amount: 80,
          spokenText: 'ఇతర ఖర్చు ఎనభై',
          createdAt: daysAgo(0, 16, 0)
        },

        // Payment received today (does not affect today's sales or expenses):
        {
          id: 'e29',
          type: 'pay',
          customerId: 'c3',
          itemId: null,
          qty: null,
          unit: null,
          amount: 500,
          spokenText: 'లక్ష్మి ఐదు వందలు ఇచ్చింది',
          createdAt: daysAgo(0, 12, 0)
        },

        // --- Past 6 days sales entries to match weekly revenue series: ---
        // Sun (6d): 3600 | Mon (5d): 3200 | Tue (4d): 4100 | Wed (3d): 3800 | Thu (2d): 4700 | Fri (1d): 4300
        { id: 'e30', type: 'cash', customerId: null, itemId: 'i1', qty: 60, unit: 'kg', amount: 3600, spokenText: 'ఆదివారం అమ్మకాలు', createdAt: daysAgo(6, 17, 0) },
        { id: 'e31', type: 'cash', customerId: null, itemId: 'i1', qty: 53, unit: 'kg', amount: 3200, spokenText: 'సోమవారం అమ్మకాలు', createdAt: daysAgo(5, 17, 0) },
        { id: 'e32', type: 'cash', customerId: null, itemId: 'i1', qty: 68, unit: 'kg', amount: 4100, spokenText: 'మంగళవారం అమ్మకాలు', createdAt: daysAgo(4, 17, 0) },
        { id: 'e33', type: 'cash', customerId: null, itemId: 'i1', qty: 63, unit: 'kg', amount: 3800, spokenText: 'బుధవారం అమ్మకాలు', createdAt: daysAgo(3, 17, 0) },
        { id: 'e34', type: 'cash', customerId: null, itemId: 'i1', qty: 78, unit: 'kg', amount: 4700, spokenText: 'గురువారం అమ్మకాలు', createdAt: daysAgo(2, 17, 0) },
        { id: 'e35', type: 'cash', customerId: null, itemId: 'i1', qty: 71, unit: 'kg', amount: 4300, spokenText: 'శుక్రవారం అమ్మకాలు', createdAt: daysAgo(1, 17, 0) }
      ]
    };
  }

  // Active state
  var state = null;

  function loadState() {
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      if (raw) {
        state = JSON.parse(raw);
        return;
      }
    } catch (e) {
      console.warn('[LOG store] localStorage read failed, using memory state:', e);
    }
    // If no localStorage, initialize seed data but mark setupDone = false for clean initial launch
    state = getSeedData();
    // If this is the very first time (clean storage), show setup screen first
    if (!localStorage.getItem(STORAGE_KEY + '_initialized')) {
      state.setupDone = false;
    }
  }

  function saveState() {
    if (saveTimer) clearTimeout(saveTimer);
    saveTimer = setTimeout(function () {
      try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
        localStorage.setItem(STORAGE_KEY + '_initialized', 'true');
      } catch (e) {
        console.warn('[LOG store] localStorage write failed:', e);
      }
    }, 120);
  }

  function notify() {
    saveState();
    listeners.forEach(function (fn) {
      try { fn(state); } catch (err) { console.error('[LOG store] listener error:', err); }
    });
  }

  // Load initial state
  loadState();

  // Public Store API
  var Store = {
    getState: function () {
      return state;
    },

    subscribe: function (listener) {
      if (typeof listener === 'function') {
        listeners.push(listener);
        return function unsubscribe() {
          listeners = listeners.filter(function (l) { return l !== listener; });
        };
      }
      return function () {};
    },

    // Customers
    getCustomers: function () {
      return state.customers || [];
    },

    getCustomerById: function (id) {
      return (state.customers || []).find(function (c) { return c.id === id; });
    },

    addCustomer: function (data) {
      var id = 'c_' + Date.now();
      var newCust = {
        id: id,
        name: (data.name || '').trim(),
        nameTe: (data.nameTe || '').trim(),
        phone: (data.phone || '').trim()
      };
      state.customers.push(newCust);
      notify();
      return newCust;
    },

    updateCustomer: function (id, data) {
      var cust = this.getCustomerById(id);
      if (cust) {
        if (data.name !== undefined) cust.name = data.name.trim();
        if (data.nameTe !== undefined) cust.nameTe = data.nameTe.trim();
        if (data.phone !== undefined) cust.phone = data.phone.trim();
        notify();
      }
      return cust;
    },

    deleteCustomer: function (id) {
      state.customers = (state.customers || []).filter(function (c) { return c.id !== id; });
      // Remove customer entries as per spec
      state.entries = (state.entries || []).filter(function (e) { return e.customerId !== id; });
      notify();
    },

    // Items
    getItems: function () {
      return state.items || [];
    },

    getItemById: function (id) {
      return (state.items || []).find(function (i) { return i.id === id; });
    },

    addItem: function (data) {
      var id = 'i_' + Date.now();
      var newItem = {
        id: id,
        name: (data.name || '').trim(),
        nameTe: (data.nameTe || '').trim(),
        unit: data.unit || 'kg',
        price: parseInt(data.price, 10) || 0,
        reorderLevel: parseFloat(data.reorderLevel) || 0,
        spokenNames: Array.isArray(data.spokenNames) ? data.spokenNames.slice() : [],
        qty: parseFloat(data.qty) || 0
      };
      state.items.push(newItem);
      notify();
      return newItem;
    },

    updateItem: function (id, data) {
      var item = this.getItemById(id);
      if (item) {
        if (data.name !== undefined) item.name = data.name.trim();
        if (data.nameTe !== undefined) item.nameTe = data.nameTe.trim();
        if (data.unit !== undefined) item.unit = data.unit;
        if (data.price !== undefined) item.price = parseInt(data.price, 10) || item.price;
        if (data.reorderLevel !== undefined) item.reorderLevel = parseFloat(data.reorderLevel) || item.reorderLevel;
        if (data.spokenNames !== undefined) item.spokenNames = data.spokenNames.slice();
        if (data.qty !== undefined) item.qty = parseFloat(data.qty);
        notify();
      }
      return item;
    },

    deleteItem: function (id) {
      // Deleting an item keeps its entries and shows the saved name as per spec
      state.items = (state.items || []).filter(function (i) { return i.id !== id; });
      notify();
    },

    // Entries
    getEntries: function () {
      return state.entries || [];
    },

    addEntry: function (entryData) {
      var id = 'e_' + Date.now();
      var entry = {
        id: id,
        type: entryData.type, // credit | cash | pay | stock | exp | count
        customerId: entryData.customerId || null,
        itemId: entryData.itemId || null,
        qty: entryData.qty !== undefined && entryData.qty !== null ? parseFloat(entryData.qty) : null,
        unit: entryData.unit || null,
        amount: parseInt(entryData.amount, 10) || 0,
        spokenText: entryData.spokenText || '',
        createdAt: entryData.createdAt || new Date().toISOString()
      };
      state.entries.unshift(entry);

      // Adjust item quantity according to transaction
      if (entry.itemId) {
        var item = this.getItemById(entry.itemId);
        if (item && entry.qty !== null) {
          if (entry.type === 'cash' || entry.type === 'credit') {
            item.qty = Math.round((item.qty - entry.qty) * 100) / 100;
          } else if (entry.type === 'stock') {
            item.qty = Math.round((item.qty + entry.qty) * 100) / 100;
          }
        }
      }

      notify();
      return entry;
    },

    deleteEntry: function (id) {
      var idx = (state.entries || []).findIndex(function (e) { return e.id === id; });
      if (idx > -1) {
        var removed = state.entries.splice(idx, 1)[0];
        // Revert item quantity change if applicable
        if (removed.itemId && removed.qty !== null) {
          var item = this.getItemById(removed.itemId);
          if (item) {
            if (removed.type === 'cash' || removed.type === 'credit') {
              item.qty = Math.round((item.qty + removed.qty) * 100) / 100;
            } else if (removed.type === 'stock') {
              item.qty = Math.round((item.qty - removed.qty) * 100) / 100;
            }
          }
        }
        notify();
        return { entry: removed, index: idx };
      }
      return null;
    },

    restoreEntry: function (entry, index) {
      if (!entry) return;
      if (typeof index === 'number' && index >= 0 && index <= state.entries.length) {
        state.entries.splice(index, 0, entry);
      } else {
        state.entries.unshift(entry);
      }

      // Re-apply item quantity change
      if (entry.itemId && entry.qty !== null) {
        var item = this.getItemById(entry.itemId);
        if (item) {
          if (entry.type === 'cash' || entry.type === 'credit') {
            item.qty = Math.round((item.qty - entry.qty) * 100) / 100;
          } else if (entry.type === 'stock') {
            item.qty = Math.round((item.qty + entry.qty) * 100) / 100;
          }
        }
      }

      notify();
    },

    // Settings
    getSettings: function () {
      return state.settings || {};
    },

    updateSettings: function (newSettings) {
      state.settings = Object.assign({}, state.settings, newSettings);
      notify();
    },

    getLastBackupAt: function () {
      return state.lastBackupAt || null;
    },

    setWeeklyCheckDone: function (done) {
      state.weeklyCheckDone = !!done;
      notify();
    },

    setSetupDone: function (done) {
      state.setupDone = !!done;
      notify();
    },

    setLastBackupAt: function (str) {
      state.lastBackupAt = str;
      notify();
    },

    // Backup & Restore
    createBackupSnapshot: function () {
      var snapshot = JSON.stringify(state, null, 2);
      try {
        localStorage.setItem(STORAGE_KEY + '_backup', snapshot);
      } catch (e) {}
      var d = new Date();
      var timeStr = d.toLocaleTimeString('en-IN', { hour: 'numeric', minute: '2-digit', hour12: true });
      this.setLastBackupAt('today, ' + timeStr);
      return snapshot;
    },

    restoreFromData: function (dataObj) {
      if (dataObj && typeof dataObj === 'object') {
        state = dataObj;
        notify();
        return true;
      }
      return false;
    },

    resetPrototype: function () {
      try {
        localStorage.removeItem(STORAGE_KEY);
        localStorage.removeItem(STORAGE_KEY + '_initialized');
        localStorage.removeItem(STORAGE_KEY + '_backup');
      } catch (e) {}
      state = getSeedData();
      state.setupDone = false;
      notify();
    }
  };

  window.LOG = window.LOG || {};
  window.LOG.store = Store;
})(window);
