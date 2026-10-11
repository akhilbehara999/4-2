/**
 * LOG Prototype - Parser
 * Voice and typed input parser supporting Telugu script, Romanized Telugu, and English.
 */

(function (window) {
  'use strict';

  // Number dictionary mapping Telugu and English number words to numbers
  var NUMBER_WORDS = {
    // Telugu units & teens
    'ఒకటి': 1, 'ఒక': 1, 'ఒకటిన్నర': 1.5,
    'రెండు': 2, 'రెండున్నర': 2.5,
    'మూడు': 3, 'మూడున్నర': 3.5,
    'నాలుగు': 4, 'నాలుగున్నర': 4.5,
    'ఐదు': 5, 'ఆరు': 6, 'ఏడు': 7, 'ఎనిమిది': 8, 'తొమ్మిది': 9, 'పది': 10,
    'పదకొండు': 11, 'పన్నెండు': 12, 'పదమూడు': 13, 'పద్నాలుగు': 14,
    'పదిహేను': 15, 'పదహారు': 16, 'పదిహేడు': 17, 'పద్దెనిమిది': 18, 'పంతొమ్మిది': 19,
    'ఇరవై': 20, 'ఇరవై ఐదు': 25, 'ఇరవైఐదు': 25, 'ముప్పై': 30, 'నలభై': 40, 'యాభై': 50,
    'అరవై': 60, 'డెబ్బై': 70, 'ఎనభై': 80, 'తొంభై': 90,
    // Telugu hundreds
    'వంద': 100, 'వందలు': 100,
    'రెండు వందలు': 200, 'రెండువందలు': 200,
    'మూడు వందలు': 300, 'మూడువందలు': 300,
    'నాలుగు వందలు': 400, 'నాలుగువందలు': 400,
    'ఐదు వందలు': 500, 'ఐదువందలు': 500,
    'ఆరు వందలు': 600, 'ఆరువందలు': 600,
    'ఏడు వందలు': 700, 'ఏడువందలు': 700,
    'ఎనిమిది వందలు': 800, 'ఎనిమిదివందలు': 800,
    'తొమ్మిది వందలు': 900, 'తొమ్మిదివందలు': 900,
    'వెయ్యి': 1000, 'వేలు': 1000,

    // English
    'half': 0.5, 'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
    'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
    'eleven': 11, 'twelve': 12, 'thirteen': 13, 'fourteen': 14, 'fifteen': 15,
    'sixteen': 16, 'seventeen': 17, 'eighteen': 18, 'nineteen': 19,
    'twenty': 20, 'thirty': 30, 'forty': 40, 'fifty': 50,
    'sixty': 60, 'seventy': 70, 'eighty': 80, 'ninety': 90,
    'hundred': 100, 'thousand': 1000
  };

  // Unit regexes (no ASCII \b on Telugu script)
  var UNIT_MAP = [
    { unit: 'kg', re: /(కిలోల|కిలోలు|కిలో|కేజీ|\bkg\b|\bkgs\b|\bkilo\b|\bkilos\b)/i },
    { unit: 'L', re: /(లీటర్ల|లీటర్లు|లీటరు|\bl\b|\blt\b|\bltr\b|\bltrs\b|\bliter\b|\bliters\b|\blitre\b|\blitres\b)/i },
    { unit: 'pcs', re: /(పీసులు|పీస్|నెంబర్లు|\bpcs\b|\bpc\b|\bpiece\b|\bpieces\b|\bpackets\b|\bpacket\b|\bpac\b)/i }
  ];

  // Expense categories mapping
  var EXP_ITEMS = [
    { name: 'Electricity', nameTe: 'కరెంటు', re: /(కరెంటు|కరెంట్|\belectricity\b|\bcurrent\b|\bpower\b)/i },
    { name: 'Transport', nameTe: 'రవాణా', re: /(రవాణా|\btransport\b|\bauto\b|\btempo\b|వ్యాన్)/i },
    { name: 'Rent', nameTe: 'అద్దె', re: /(అద్దె|\brent\b)/i },
    { name: 'Restock', nameTe: 'రీస్టాక్', re: /(రీస్టాక్|సరుకు ఖర్చు|\brestock\b)/i }
  ];

  /**
   * Helper to extract numbers (words, compound words, digits) from text.
   */
  function extractNumber(token) {
    if (!token) return null;
    var trimmed = token.trim();
    if (/^\d+(\.\d+)?$/.test(trimmed)) {
      return parseFloat(trimmed);
    }
    if (NUMBER_WORDS[trimmed] !== undefined) {
      return NUMBER_WORDS[trimmed];
    }
    return null;
  }

  /**
   * Parse speech or text into an entry object.
   */
  function parseEntry(rawText) {
    var text = (rawText || '').trim();
    if (!text) {
      return {
        type: 'credit',
        customer: null,
        item: null,
        qty: null,
        unit: 'kg',
        amount: null,
        spokenText: ''
      };
    }

    var lower = text.toLowerCase();
    var store = window.LOG.store;
    var customers = store ? store.getCustomers() : [];
    var items = store ? store.getItems() : [];

    var result = {
      type: 'credit',
      customer: null,
      isNewCustomer: false,
      item: null,
      qty: null,
      unit: 'kg',
      amount: null,
      spokenText: text
    };

    // 1. Detect Entry Type (no \b on Telugu script)
    if (/(అప్పు|udhar|బాకీ|\bcredit\b|\bappu\b|అప్పు\s*ఇచ్చాను)/i.test(text)) {
      result.type = 'credit';
    } else if (/(అమ్మాను|\bsold\b|\bsale\b|నగదు|\bcash\b|అమ్మకం|\bamm\b)/i.test(text)) {
      result.type = 'cash';
    } else if (/(ఇచ్చింది|ఇచ్చాడు|\bpaid\b|\bpay\b|జమ|\breceived\b|కట్టింది|కట్టాడు|చెల్లించింది)/i.test(text)) {
      result.type = 'pay';
    } else if (/(వచ్చింది|\brestock\b|\bstock\b|స్టాక్|చేరింది|దిగింది)/i.test(text)) {
      result.type = 'stock';
    } else if (/(బిల్లు|ఖర్చు|\bexpense\b|\bexp\b|\bbill\b)/i.test(text)) {
      result.type = 'exp';
    }

    // 2. Detect Unit
    for (var u = 0; u < UNIT_MAP.length; u++) {
      if (UNIT_MAP[u].re.test(text)) {
        result.unit = UNIT_MAP[u].unit;
        break;
      }
    }

    // 3. Match Customer (for Credit & Pay)
    if (result.type === 'credit' || result.type === 'pay') {
      var foundCust = null;
      for (var c = 0; c < customers.length; c++) {
        var cust = customers[c];
        var cName = cust.name.toLowerCase();
        var cTe = cust.nameTe;

        // Check exact or with Telugu suffix -ki/-ku or English 'ki'
        var reCust = new RegExp('(' + cName + '|' + cTe + ')(కి|కు|‌కి|\\s+ki|\\s+ku)?', 'i');
        if (reCust.test(text)) {
          foundCust = cust;
          break;
        }
      }

      if (foundCust) {
        result.customer = foundCust.name;
        result.isNewCustomer = false;
      } else {
        // Try extracting unknown customer name before 'ki' / 'అప్పు'
        var mCust = text.match(/([a-zA-Z\u0C00-\u0C7F]+)(\s*కి|\s*‌కి|\s+ki|\s+ku)/i);
        if (mCust && mCust[1]) {
          var extractedName = mCust[1].trim();
          // Filter out stop words
          if (!/^(ఈ|నా|మన|షాప్|shop|today)$/i.test(extractedName)) {
            result.customer = extractedName;
            result.isNewCustomer = true;
          }
        }
      }
    }

    // 4. Match Item (for Credit, Cash, Stock, Exp)
    if (result.type === 'exp') {
      // Check expense categories
      for (var expI = 0; expI < EXP_ITEMS.length; expI++) {
        if (EXP_ITEMS[expI].re.test(text)) {
          result.item = EXP_ITEMS[expI].name;
          break;
        }
      }
      if (!result.item) {
        // Match generic what-for
        var mExp = text.match(/([a-zA-Z\u0C00-\u0C7F]+)\s*(బిల్లు|ఖర్చు|bill)/i);
        if (mExp && mExp[1]) {
          result.item = mExp[1].trim();
        }
      }
    } else if (result.type !== 'pay') {
      // Match kirana stock items
      for (var it = 0; it < items.length; it++) {
        var itemObj = items[it];
        var itemMatch = false;

        // Check English name
        if (new RegExp('\\b' + itemObj.name + '\\b', 'i').test(text)) itemMatch = true;
        // Check Telugu name
        if (itemObj.nameTe && text.indexOf(itemObj.nameTe) > -1) itemMatch = true;
        // Check spoken names
        if (itemObj.spokenNames && itemObj.spokenNames.length) {
          for (var s = 0; s < itemObj.spokenNames.length; s++) {
            var sn = itemObj.spokenNames[s];
            if (new RegExp('\\b' + sn + '\\b', 'i').test(text) || text.indexOf(sn) > -1) {
              itemMatch = true;
              break;
            }
          }
        }

        if (itemMatch) {
          result.item = itemObj.name;
          result.unit = itemObj.unit;
          break;
        }
      }
    }

    // 5. Extract Quantity & Amount
    // Telugu compound words (e.g. "ఇరవై ఐదు" -> 25, "ఐదు వందలు" -> 500)
    var normalized = text
      .replace(/ఇరవై\s*ఐదు/g, ' 25 ')
      .replace(/ఐదు\s*వందలు/g, ' 500 ')
      .replace(/రెండు\s*వందలు/g, ' 200 ')
      .replace(/మూడు\s*వందలు/g, ' 300 ')
      .replace(/నాలుగు\s*వందలు/g, ' 400 ')
      .replace(/ఆరు\s*వందలు/g, ' 600 ')
      .replace(/వెయ్యి/g, ' 1000 ')
      .replace(/రెండు\s*వేలు/g, ' 2000 ');

    // Replace single Telugu number words with digits for easy tokenization (descending length)
    var sortedWords = Object.keys(NUMBER_WORDS).sort(function (a, b) { return b.length - a.length; });
    sortedWords.forEach(function (w) {
      var isTe = /[\u0C00-\u0C7F]/.test(w);
      var reW = isTe ? new RegExp('(^|[\\s,.;:!?])' + w + '(?=$|[\\s,.;:!?])', 'g') : new RegExp('\\b' + w + '\\b', 'gi');
      normalized = normalized.replace(reW, '$1' + NUMBER_WORDS[w]);
    });

    // Check for quantity (number immediately before unit)
    var mQty = normalized.match(/(\d+(\.\d+)?)\s*(కిలోల|కిలోలు|కిలో|కేజీ|kg|kgs|kilo|లీటర్ల|లీటర్లు|లీటరు|l|lt|పీసులు|pcs)/i);
    if (mQty && mQty[1]) {
      result.qty = parseFloat(mQty[1]);
    }

    // Check for amount (number with rs / రూపాయలు / rupees or at the end)
    var mAmt = normalized.match(/(\d+)\s*(రూపాయలు|రూ|rs|rupees|inr)/i);
    if (mAmt && mAmt[1]) {
      result.amount = parseInt(mAmt[1], 10);
    } else {
      // Find all standalone numbers
      var allNums = normalized.match(/\b\d+(\.\d+)?\b/g);
      if (allNums && allNums.length) {
        var nums = allNums.map(function (n) { return parseFloat(n); });
        // If we already have qty, take another number as amount
        if (result.qty !== null) {
          var remaining = nums.filter(function (n) { return n !== result.qty; });
          if (remaining.length) {
            result.amount = Math.round(remaining[remaining.length - 1]);
          }
        } else if (nums.length === 1) {
          // If only 1 number in pay/exp, it's amount. If in restock, it might be qty
          if (result.type === 'pay' || result.type === 'exp') {
            result.amount = Math.round(nums[0]);
          } else if (result.type === 'stock') {
            result.qty = nums[0];
          } else {
            result.amount = Math.round(nums[0]);
          }
        } else if (nums.length >= 2) {
          result.qty = nums[0];
          result.amount = Math.round(nums[1]);
        }
      }
    }

    // Auto-calculate amount if missing and item known
    if (result.amount === null && result.item && result.qty && store) {
      var itObj = store.getItems().find(function (i) { return i.name === result.item; });
      if (itObj && itObj.price) {
        result.amount = Math.round(result.qty * itObj.price);
      }
    }

    return result;
  }

  window.LOG = window.LOG || {};
  window.LOG.parser = {
    parseEntry: parseEntry,
    parse: parseEntry
  };
})(window);
