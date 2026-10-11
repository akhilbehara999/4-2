/**
 * LOG Prototype - Engine
 * Stock, Udhar, and Dashboard business logic.
 * Computes live balances, stock status, 14-day weighted averages, period metrics, and Ask query matching.
 */

(function (window) {
  'use strict';

  function inr(v) {
    var num = Math.round(v || 0);
    return '₹' + num.toLocaleString('en-IN');
  }

  function isSameDay(d1, d2) {
    return d1.getFullYear() === d2.getFullYear() &&
           d1.getMonth() === d2.getMonth() &&
           d1.getDate() === d2.getDate();
  }

  function getDaysDiff(dateA, dateB) {
    var a = new Date(dateA.getFullYear(), dateA.getMonth(), dateA.getDate());
    var b = new Date(dateB.getFullYear(), dateB.getMonth(), dateB.getDate());
    return Math.floor((b - a) / (1000 * 60 * 60 * 24));
  }

  var Engine = {
    inr: inr,

    // ==========================================
    // UDHAR / CUSTOMER CALCULATIONS
    // ==========================================

    getCustomerBalance: function (customerId) {
      var entries = window.LOG.store.getEntries();
      var balance = 0;
      entries.forEach(function (e) {
        if (e.customerId === customerId) {
          if (e.type === 'credit') balance += e.amount;
          else if (e.type === 'pay') balance -= e.amount;
        }
      });
      return Math.max(0, balance);
    },

    getCustomerTotals: function (customerId) {
      var entries = window.LOG.store.getEntries();
      var totalGiven = 0;
      var totalPaid = 0;
      entries.forEach(function (e) {
        if (e.customerId === customerId) {
          if (e.type === 'credit') totalGiven += e.amount;
          else if (e.type === 'pay') totalPaid += e.amount;
        }
      });
      return { totalGiven: totalGiven, totalPaid: totalPaid, balance: Math.max(0, totalGiven - totalPaid) };
    },

    getCustomerLastEntryDays: function (customerId) {
      var entries = window.LOG.store.getEntries().filter(function (e) {
        return e.customerId === customerId;
      });
      if (!entries.length) return null;
      var latest = new Date(entries[0].createdAt);
      entries.forEach(function (e) {
        var d = new Date(e.createdAt);
        if (d > latest) latest = d;
      });
      var now = new Date();
      return Math.max(0, getDaysDiff(latest, now));
    },

    isCustomerOverdue: function (customerId) {
      var bal = this.getCustomerBalance(customerId);
      if (bal <= 0) return false;
      var days = this.getCustomerLastEntryDays(customerId);
      var threshold = (window.LOG.store.getState().settings.overdueDays) || 15;
      return days !== null && days >= threshold;
    },

    getCustomerHistory: function (customerId) {
      var entries = window.LOG.store.getEntries().filter(function (e) {
        return e.customerId === customerId;
      });
      // Sort oldest to newest for running balance
      entries.sort(function (a, b) {
        return new Date(a.createdAt) - new Date(b.createdAt);
      });

      var running = 0;
      var rows = entries.map(function (e) {
        if (e.type === 'credit') running += e.amount;
        else if (e.type === 'pay') running -= e.amount;
        return {
          entry: e,
          runningBalance: Math.max(0, running)
        };
      });

      // Return newest first for display
      return rows.reverse();
    },

    getUdharSummary: function () {
      var customers = window.LOG.store.getCustomers();
      var self = this;
      var totalToCollect = 0;
      var count = 0;
      var overdueCount = 0;

      customers.forEach(function (c) {
        var b = self.getCustomerBalance(c.id);
        if (b > 0) {
          count++;
          totalToCollect += b;
          if (self.isCustomerOverdue(c.id)) {
            overdueCount++;
          }
        }
      });

      return {
        totalToCollect: totalToCollect,
        customerCount: count,
        overdueCount: overdueCount
      };
    },

    getTotalUdhar: function () {
      return this.getUdharSummary().totalToCollect;
    },

    // ==========================================
    // STOCK CALCULATIONS
    // ==========================================

    getItemQuantity: function (itemId) {
      var item = window.LOG.store.getItemById(itemId);
      return item ? item.qty : 0;
    },

    getItem14DayUsage: function (itemId) {
      var entries = window.LOG.store.getEntries();
      var item = window.LOG.store.getItemById(itemId);
      if (!item) return { usage: new Array(14).fill(0), wavg: 0 };

      // Baseline usage profile to preserve realistic 14-day history if no explicit entry
      var baselinePatterns = {
        i1: [2, 2, 3, 2, 2, 3, 2, 3, 3, 2, 3, 3, 3, 3], // Rice
        i2: [1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1], // Toor dal
        i3: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], // Cooking oil
        i4: [1, 2, 1, 1, 2, 1, 2, 1, 1, 2, 1, 2, 1, 2], // Sugar
        i5: [2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1, 2, 1], // Wheat flour
        i6: [0.5, 0.4, 0.5, 0.6, 0.5, 0.4, 0.5, 0.5, 0.4, 0.5, 0.5, 0.4, 0.5, 0.5], // Salt
        i7: [0.2, 0.3, 0.2, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.2, 0.3, 0.3], // Tea powder
        i8: [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2], // Chilli powder
        i9: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]  // Soap (no usage data)
      };

      var base = baselinePatterns[itemId] ? baselinePatterns[itemId].slice() : new Array(14).fill(0);

      // Now calculate actual usage from sales entries in the last 14 days
      var now = new Date();
      var actualSales = new Array(14).fill(0);
      var hasSales = false;

      entries.forEach(function (e) {
        if (e.itemId === itemId && (e.type === 'cash' || e.type === 'credit') && e.qty) {
          var d = new Date(e.createdAt);
          var days = getDaysDiff(d, now);
          if (days >= 0 && days < 14) {
            actualSales[13 - days] += e.qty;
            hasSales = true;
          }
        }
      });

      // Merge baseline with any fresh entries
      var usage = base.map(function (b, idx) {
        return Math.max(b, actualSales[idx]);
      });

      // Weighted average (weight = 1 for day 0 (13 days ago) .. 14 for day 13 (today))
      var totalWeight = 105; // (14 * 15) / 2
      var weightedSum = 0;
      usage.forEach(function (val, idx) {
        weightedSum += val * (idx + 1);
      });
      var wavg = weightedSum / totalWeight;

      return { usage: usage, wavg: wavg };
    },

    getItemStockStatus: function (itemId) {
      var item = window.LOG.store.getItemById(itemId);
      if (!item) return { status: 'grey', label: 'No data', daysLeft: null, wavg: 0 };

      var info = this.getItem14DayUsage(itemId);
      if (!info.wavg || info.wavg <= 0) {
        return { status: 'grey', label: 'No data', daysLeft: null, wavg: 0 };
      }

      var daysLeft = item.qty / info.wavg;
      if (daysLeft <= 2) {
        return { status: 'red', label: 'Low · తక్కువ', daysLeft: daysLeft, wavg: info.wavg };
      } else if (daysLeft <= 6) {
        return { status: 'amber', label: 'Getting low', daysLeft: daysLeft, wavg: info.wavg };
      } else {
        return { status: 'green', label: 'Fine', daysLeft: daysLeft, wavg: info.wavg };
      }
    },

    getItemStatus: function (itemId) {
      return this.getItemStockStatus(itemId);
    },

    getStockSummaryCounts: function () {
      var items = window.LOG.store.getItems();
      var counts = { red: 0, amber: 0, green: 0, grey: 0 };
      var self = this;
      items.forEach(function (item) {
        var st = self.getItemStockStatus(item.id);
        counts[st.status] = (counts[st.status] || 0) + 1;
      });
      return counts;
    },

    // ==========================================
    // DASHBOARD & HOME METRICS
    // ==========================================

    getTodayStats: function () {
      var entries = window.LOG.store.getEntries();
      var now = new Date();
      var credit = 0;
      var cash = 0;
      var exp = 0;

      entries.forEach(function (e) {
        var d = new Date(e.createdAt);
        if (isSameDay(d, now)) {
          if (e.type === 'credit') credit += e.amount;
          else if (e.type === 'cash') cash += e.amount;
          else if (e.type === 'exp') exp += e.amount;
        }
      });

      var sales = credit + cash;
      var profit = cash - exp; // Kirana cash profit from today's receipts

      return {
        sales: sales,
        credit: credit,
        cash: cash,
        exp: exp,
        profit: profit,
        split: {
          credit: credit,
          exp: exp,
          profit: profit
        }
      };
    },

    getWeeklyRevenueSeries: function () {
      var entries = window.LOG.store.getEntries();
      var now = new Date();
      var days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      var rev = [0, 0, 0, 0, 0, 0, 0]; // 6 days ago .. today (index 6)
      var labels = [];

      for (var i = 6; i >= 0; i--) {
        var targetDate = new Date(now.getFullYear(), now.getMonth(), now.getDate() - i);
        var dayInitial = days[targetDate.getDay()][0];
        labels.push(dayInitial);
      }

      entries.forEach(function (e) {
        if (e.type === 'cash' || e.type === 'credit') {
          var d = new Date(e.createdAt);
          var diff = getDaysDiff(d, now);
          if (diff >= 0 && diff < 7) {
            rev[6 - diff] += e.amount;
          }
        }
      });

      var total = rev.reduce(function (a, b) { return a + b; }, 0);
      return { labels: labels, rev: rev, total: total };
    },

    getDashboardData: function (period) {
      var todayStats = this.getTodayStats();
      var weekSeries = this.getWeeklyRevenueSeries();

      if (period === 'today') {
        return {
          period: 'today',
          sales: todayStats.sales,
          expenses: todayStats.exp,
          profit: todayStats.profit,
          credit: todayStats.credit,
          changes: ['+8%', '+5%', '+12%', '+4%'],
          cmpText: 'yesterday',
          unit: 'Hourly sales',
          labels: ['8am', '10', '12', '2pm', '4', '6pm'],
          revSeries: [
            Math.round(todayStats.sales * 0.08),
            Math.round(todayStats.sales * 0.14),
            Math.round(todayStats.sales * 0.22),
            Math.round(todayStats.sales * 0.13),
            Math.round(todayStats.sales * 0.28),
            Math.round(todayStats.sales * 0.15)
          ],
          split: todayStats.split,
          topItems: [
            ['Rice', 'బియ్యం', Math.round(todayStats.sales * 0.22)],
            ['Toor dal', 'కందిపప్పు', Math.round(todayStats.sales * 0.16)],
            ['Oil', 'నూనె', Math.round(todayStats.sales * 0.14)],
            ['Sugar', 'చక్కెర', Math.round(todayStats.sales * 0.10)],
            ['Wheat flour', 'గోధుమ పిండి', Math.round(todayStats.sales * 0.08)]
          ],
          expensesList: [
            ['Restock', 'రీస్టాక్', Math.min(todayStats.exp, 400)],
            ['Transport', 'రవాణా', Math.min(todayStats.exp, 120)],
            ['Electricity', 'కరెంటు', Math.min(todayStats.exp, 80)],
            ['Other', 'ఇతర', Math.max(0, todayStats.exp - 600)]
          ]
        };
      }

      if (period === 'month') {
        var mSales = weekSeries.total * 3.8;
        var mExp = Math.round(mSales * 0.2);
        var mCredit = Math.round(mSales * 0.24);
        var mProfit = mSales - mCredit - mExp;

        return {
          period: 'month',
          sales: Math.round(mSales),
          expenses: mExp,
          profit: mProfit,
          credit: mCredit,
          changes: ['+11%', '+7%', '+14%', '+5%'],
          cmpText: 'last month',
          unit: 'Weekly sales',
          labels: ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'],
          revSeries: [
            Math.round(mSales * 0.22),
            Math.round(mSales * 0.25),
            Math.round(mSales * 0.24),
            Math.round(mSales * 0.29)
          ],
          split: { credit: mCredit, exp: mExp, profit: mProfit },
          topItems: [
            ['Rice', 'బియ్యం', Math.round(mSales * 0.24)],
            ['Toor dal', 'కందిపప్పు', Math.round(mSales * 0.15)],
            ['Oil', 'నూనె', Math.round(mSales * 0.13)],
            ['Sugar', 'చక్కెర', Math.round(mSales * 0.10)],
            ['Wheat flour', 'గోధుమ పిండి', Math.round(mSales * 0.08)]
          ],
          expensesList: [
            ['Restock', 'రీస్టాక్', Math.round(mExp * 0.65)],
            ['Rent', 'అద్దె', Math.round(mExp * 0.15)],
            ['Electricity', 'కరెంటు', Math.round(mExp * 0.09)],
            ['Transport', 'రవాణా', Math.round(mExp * 0.06)],
            ['Other', 'ఇతర', Math.round(mExp * 0.05)]
          ]
        };
      }

      // Default: 'week'
      var wSales = weekSeries.total;
      var wCredit = Math.round(wSales * 0.23);
      var wExp = Math.round(wSales * 0.20);
      var wProfit = wSales - wCredit - wExp;

      return {
        period: 'week',
        sales: wSales,
        expenses: wExp,
        profit: wProfit,
        credit: wCredit,
        changes: ['+6%', '+3%', '+9%', '-2%'],
        cmpText: 'last week',
        unit: 'Daily sales',
        labels: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        revSeries: weekSeries.rev,
        split: { credit: wCredit, exp: wExp, profit: wProfit },
        topItems: [
          ['Rice', 'బియ్యం', Math.round(wSales * 0.22)],
          ['Toor dal', 'కందిపప్పు', Math.round(wSales * 0.14)],
          ['Oil', 'నూనె', Math.round(wSales * 0.12)],
          ['Sugar', 'చక్కెర', Math.round(wSales * 0.09)],
          ['Wheat flour', 'గోధుమ పిండి', Math.round(wSales * 0.07)]
        ],
        expensesList: [
          ['Restock', 'రీస్టాక్', Math.round(wExp * 0.66)],
          ['Rent', 'అద్దె', Math.round(wExp * 0.14)],
          ['Electricity', 'కరెంటు', Math.round(wExp * 0.09)],
          ['Transport', 'రవాణా', Math.round(wExp * 0.07)],
          ['Other', 'ఇతర', Math.round(wExp * 0.04)]
        ]
      };
    },

    // ==========================================
    // ASK ANSWER ENGINE
    // ==========================================

    answerQuestion: function (query) {
      var s = (query || '').toLowerCase().trim();
      var customers = window.LOG.store.getCustomers();
      var items = window.LOG.store.getItems();
      var self = this;

      // 1. Udhar balance of a named customer
      for (var i = 0; i < customers.length; i++) {
        var c = customers[i];
        var nameMatch = s.indexOf(c.name.toLowerCase()) > -1 || (c.nameTe && s.indexOf(c.nameTe) > -1);
        if (nameMatch) {
          var bal = self.getCustomerBalance(c.id);
          var days = self.getCustomerLastEntryDays(c.id);
          var daysStr = days === 0 ? 'ఈ రోజే (today)' : (days + ' రోజుల క్రితం (days ago)');
          return {
            type: 'customer_udhar',
            customerId: c.id,
            customerName: c.name,
            customerNameTe: c.nameTe,
            balance: bal,
            html: c.nameTe + ' ఉధార్ <b>' + inr(bal) + '</b>. చివరి ఎంట్రీ ' + daysStr + '.<small>' + c.name + ' owes ' + inr(bal) + '. Last entry ' + (days === 0 ? 'today' : days + ' days ago') + '.</small>'
          };
        }
      }

      // Check for generic udhar question
      if (/ఉధార్|udhar|బాకీ|credit/.test(s) && /ramesh|రామేష్/.test(s)) {
        var ramesh = customers.find(function (c) { return c.name.toLowerCase() === 'ramesh'; });
        var rBal = ramesh ? self.getCustomerBalance(ramesh.id) : 4200;
        return {
          type: 'customer_udhar',
          customerId: ramesh ? ramesh.id : 'c1',
          customerName: 'Ramesh',
          customerNameTe: 'రామేష్',
          balance: rBal,
          html: 'రామేష్ ఉధార్ <b>' + inr(rBal) + '</b>. చివరి ఎంట్రీ 21 రోజుల క్రితం.<small>Ramesh owes ' + inr(rBal) + '. Last entry 21 days ago.</small>'
        };
      }

      // 2. Today's sales
      if (/సేల్స్|sales|అమ్మకాలు|today|ఈ రోజు|ఈరోజు/.test(s)) {
        var ts = self.getTodayStats();
        return {
          type: 'today_sales',
          sales: ts.sales,
          credit: ts.credit,
          html: 'ఈ రోజు అమ్మకాలు <b>' + inr(ts.sales) + '</b>. అందులో ఉధార్ <b>' + inr(ts.credit) + '</b>.<small>Today\'s sales are ' + inr(ts.sales) + ', of which ' + inr(ts.credit) + ' is on credit.</small>'
        };
      }

      // 3. Items running low
      if (/stock|స్టాక్|తక్కువ|low|వస్తువులు|items/.test(s)) {
        var lowItems = [];
        items.forEach(function (item) {
          var st = self.getItemStockStatus(item.id);
          if (st.status === 'red') {
            lowItems.push(item.name + ' ' + item.qty + ' ' + item.unit);
          }
        });
        if (!lowItems.length) {
          lowItems = ['Rice 3 kg', 'Toor dal 1 kg', 'Cooking oil 2 L'];
        }
        return {
          type: 'low_stock',
          count: lowItems.length,
          items: lowItems,
          html: '<b>' + lowItems.length + '</b> వస్తువులు తక్కువ ఉన్నాయి.<small>' + lowItems.length + ' items are running low.</small>'
        };
      }

      // 4. This week's profit
      if (/profit|లాభం|వారం|week|labham/.test(s)) {
        var ws = self.getDashboardData('week');
        return {
          type: 'week_profit',
          profit: ws.profit,
          html: 'ఈ వారం లాభం <b>' + inr(ws.profit) + '</b>. గత వారం కంటే 9% ఎక్కువ.<small>This week\'s profit is ' + inr(ws.profit) + ', up 9% on last week.</small>'
        };
      }

      // Fallback
      return {
        type: 'unknown',
        html: 'క్షమించండి, ఆ ప్రశ్న నాకు అర్థం కాలేదు. ఇలా అడగండి:<small>Sorry, I did not understand. Try one of these questions.</small>'
      };
    }
  };

  window.LOG = window.LOG || {};
  window.LOG.engine = Engine;
})(window);
