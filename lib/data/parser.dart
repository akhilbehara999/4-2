// ignore_for_file: constant_identifier_names

import 'models.dart';

/// Keywords map at the top of the file for quick extension.
/// Maps transaction types to Romanized and Telugu script trigger keywords.
const Map<String, List<String>> TYPE_KEYWORDS = {
  'credit_sale': [
    'udhar',
    'udharchanu',
    'appu',
    'baaki',
    'baki',
    'అప్పు',
    'ఉధార్',
    'బాకీ',
  ],
  'cash_sale': [
    'ammanu',
    'ammina',
    'ammamu',
    'sale',
    'cash',
    'ammadam',
    'అమ్మాను',
    'అమ్మింది',
    'అమ్మకం',
    'నగదు',
  ],
  'payment_received': [
    'icchadu',
    'ichadu',
    'icharu',
    'vasool',
    'jama',
    'received',
    'ఇచ్చాడు',
    'ఇచ్చారు',
    'వసూలు',
    'జమ',
  ],
  'restock': [
    'techanu',
    'techamu',
    'konnanu',
    'stock',
    'restock',
    'తెచ్చాను',
    'తెచ్చాము',
    'కొన్నాను',
    'స్టాక్',
  ],
  'expense': [
    'kattanu',
    'kharchu',
    'karchu',
    'expense',
    'bill',
    'rent',
    'ఖర్చు',
    'కట్టాను',
    'బిల్లు',
    'కరెంట్',
  ],
};

/// Item synonym dictionary for Telugu script & Romanized words to standard items.
const Map<String, String> ITEM_SYNONYMS = {
  // Rice
  'biyyam': 'Rice',
  'బియ్యం': 'Rice',
  'rice': 'Rice',
  'వడ్లు': 'Rice',
  // Sugar
  'pancha': 'Sugar',
  'panchadara': 'Sugar',
  'పంచదార': 'Sugar',
  'sugar': 'Sugar',
  // Oil
  'nune': 'Oil',
  'నూనె': 'Oil',
  'oil': 'Oil',
  // Salt
  'uppu': 'Salt',
  'ఉప్పు': 'Salt',
  'salt': 'Salt',
  // Dal
  'pappu': 'Dal',
  'పప్పు': 'Dal',
  'dal': 'Dal',
  'kandipappu': 'Dal',
  'కందిపప్పు': 'Dal',
};

/// Supported unit variations mapped to canonical units.
const Map<String, List<String>> UNIT_SYNONYMS = {
  'kg': ['kilo', 'kilos', 'kg', 'kgs', 'కిలోల', 'కిలోలు', 'కిలో', 'కేజీ'],
  'litre': ['litre', 'litres', 'liter', 'liters', 'l', 'lt', 'ltr', 'లీటర్ల', 'లీటర్లు', 'లీటరు', 'లీటర్'],
  'packet': ['packet', 'packets', 'pkt', 'packetlu', 'పాకెట్లు', 'ప్యాకెట్లు', 'పాకెట్', 'ప్యాకెట్'],
  'gram': ['gram', 'grams', 'gm', 'gms', 'g', 'గ్రాములు', 'గ్రాము', 'గ్రాం'],
  'ml': ['ml', 'milli', 'millilitre', 'millilitres', 'మిల్లీ', 'మిల్లీలీటర్లు', 'మిల్లీలీటర్ల'],
};

/// Telugu and Romanized Telugu words for numbers and fractions.
const Map<String, double> TELUGU_NUMBER_WORDS = {
  // Compound fractions & special terms (sorted longest first)
  'ఒకటిన్నర': 1.5,
  'ఒకన్నర': 1.5,
  'ఒకటిన్నరకి': 1.5,
  'okatinnara': 1.5,
  'okannara': 1.5,
  'రెండిన్నర': 2.5,
  'రెండున్నర': 2.5,
  'rendinnara': 2.5,
  'rendunnara': 2.5,
  'మూడిన్నర': 3.5,
  'మూడున్నర': 3.5,
  'moodinnara': 3.5,
  'moodunnara': 3.5,
  'నాలుగిన్నర': 4.5,
  'నాలుగున్నర': 4.5,
  'naaluginnara': 4.5,
  'naalugunnara': 4.5,
  'ఐదిన్నర': 5.5,
  'ఐదున్నర': 5.5,
  'aidinnara': 5.5,
  'aidunnara': 5.5,
  'ముప్పావు': 0.75,
  'muppaavu': 0.75,
  'muppavu': 0.75,
  'అర': 0.5,
  'ara': 0.5,
  'పావు': 0.25,
  'paavu': 0.25,
  'pavu': 0.25,

  // Whole numbers
  'ఒకటి': 1.0,
  'ఒక': 1.0,
  'okati': 1.0,
  'oka': 1.0,
  'రెండు': 2.0,
  'rendu': 2.0,
  'మూడు': 3.0,
  'moodu': 3.0,
  'mudu': 3.0,
  'నాలుగు': 4.0,
  'naalugu': 4.0,
  'nalugu': 4.0,
  'ఐదు': 5.0,
  'aidu': 5.0,
  'aayidu': 5.0,
  'ఆరు': 6.0,
  'aaru': 6.0,
  'ఏడు': 7.0,
  'yedu': 7.0,
  'edu': 7.0,
  'ఎనిమిది': 8.0,
  'enimidi': 8.0,
  'తొమ్మిది': 9.0,
  'tommidi': 9.0,
  'పది': 10.0,
  'padi': 10.0,
  'పదకొండు': 11.0,
  'padakondu': 11.0,
  'పన్నెండు': 12.0,
  'pannendu': 12.0,
  'పదమూడు': 13.0,
  'padamoodu': 13.0,
  'పద్నాలుగు': 14.0,
  'padnaalugu': 14.0,
  'పదిహేను': 15.0,
  'padihenu': 15.0,
  'ఇరవై': 20.0,
  'iravai': 20.0,
  'ఇరవై ఐదు': 25.0,
  'ముప్పై': 30.0,
  'muppai': 30.0,
  'నలభై': 40.0,
  'nalabhai': 40.0,
  'యాభై': 50.0,
  'yabhai': 50.0,
  'yaabhai': 50.0,
  'వంద': 100.0,
  'vanda': 100.0,
};

/// Telugu words for monetary amounts.
const Map<String, double> TELUGU_AMOUNT_WORDS = {
  'వెయ్యి': 1000.0,
  'veyyi': 1000.0,
  'వేయి': 1000.0,
  'ఐదు వందలు': 500.0,
  'aidu vandalu': 500.0,
  'నాలుగు వందలు': 400.0,
  'మూడు వందలు': 300.0,
  'రెండు వందలు': 200.0,
  'rendu vandalu': 200.0,
  'వంద': 100.0,
  'vanda': 100.0,
  'యాభై': 50.0,
  'yabhai': 50.0,
  'నలభై': 40.0,
  'nalabhai': 40.0,
  'ముప్పై': 30.0,
  'muppai': 30.0,
  'ఇరవై': 20.0,
  'iravai': 20.0,
  'పది': 10.0,
  'padi': 10.0,
  'ఐదు': 5.0,
  'aidu': 5.0,
};

/// Checks if [word] occurs as a distinct whole word in [text].
/// Word characters include Latin alphanumeric ([a-zA-Z0-9]) and Telugu script (\u0C00-\u0C7F).
/// Word boundaries are defined by start/end of string or non-word characters.
bool containsWord(String text, String word) {
  final cleanWord = word.trim();
  if (cleanWord.isEmpty) return false;
  final pattern = '(?:^|[^a-zA-Z0-9\\u0C00-\\u0C7F])${RegExp.escape(cleanWord)}(?:[^a-zA-Z0-9\\u0C00-\\u0C7F]|\$)';
  return RegExp(pattern, caseSensitive: false).hasMatch(text);
}

/// Known bilingual equivalences and spelling variants for Kirana customer names.
const Map<String, List<String>> KNOWN_CUSTOMER_VARIANTS = {
  'ramesh': ['ramesh', 'రామేష్', 'రమేష్'],
  'suresh': ['suresh', 'సురేష్', 'సూరేష్'],
  'lakshmi': ['lakshmi', 'లక్ష్మి', 'లక్ష్మీ', 'laxmi'],
  'venkat': ['venkat', 'వెంకట్', 'వెంకటేష్', 'venkatesh'],
  'anitha': ['anitha', 'anita', 'అనిత', 'అనీత'],
  'mahesh': ['mahesh', 'మహేష్'],
  'rajesh': ['rajesh', 'రాజేష్', 'రజేష్'],
  'naresh': ['naresh', 'నరేష్'],
  'raju': ['raju', 'రాజు'],
  'ravi': ['ravi', 'రవి'],
  'prasad': ['prasad', 'ప్రసాద్'],
  'kumar': ['kumar', 'కుమార్'],
  'srinivas': ['srinivas', 'శ్రీనివాస్', 'శీను', 'srinu'],
  'satish': ['satish', 'సతీష్'],
  'krishna': ['krishna', 'కృష్ణ'],
  'nagaraju': ['nagaraju', 'నాగరాజు'],
  'siva': ['siva', 'shiva', 'శివ'],
  'sai': ['sai', 'సాయి'],
  'ramu': ['ramu', 'రాము'],
};

/// Determines whether two customer names represent the same person
/// (e.g. "Ramesh (రామేష్)" and "Ramesh", or "రమేష్" and "Ramesh").
bool areSameCustomer(String nameA, String nameB) {
  final cleanA = nameA.trim().toLowerCase();
  final cleanB = nameB.trim().toLowerCase();
  if (cleanA.isEmpty || cleanB.isEmpty) return false;
  if (cleanA == cleanB) return true;

  // Split tokens for nameA and nameB (e.g. "Ramesh (రామేష్)" -> ["ramesh", "రామేష్"])
  final tokensA = nameA
      .split(RegExp(r'[()/,]+'))
      .map((t) => t.trim().toLowerCase())
      .where((t) => t.length >= 2)
      .toSet();
  final tokensB = nameB
      .split(RegExp(r'[()/,]+'))
      .map((t) => t.trim().toLowerCase())
      .where((t) => t.length >= 2)
      .toSet();

  // If any direct token overlaps
  if (tokensA.intersection(tokensB).isNotEmpty) return true;

  // Expand with KNOWN_CUSTOMER_VARIANTS
  String? canonicalOf(String token) {
    for (final entry in KNOWN_CUSTOMER_VARIANTS.entries) {
      if (entry.key == token || entry.value.any((v) => v.toLowerCase() == token)) {
        return entry.key;
      }
    }
    return null;
  }

  for (final tA in tokensA) {
    final canonA = canonicalOf(tA);
    if (canonA != null) {
      for (final tB in tokensB) {
        if (canonicalOf(tB) == canonA) {
          return true;
        }
      }
    }
  }

  return false;
}

/// Matches customer name directly using exact name or unparenthesized tokens without variant expansion.
bool matchesCustomerDirect(String text, String customerName) {
  if (containsWord(text, customerName)) return true;
  final suffixes = ['ki', 'ku', 'gariki', 'కి', 'కు', 'గారికి'];
  final nameTokens = customerName
      .split(RegExp(r'[()/,]+'))
      .map((t) => t.trim())
      .where((t) => t.length >= 2);
  for (final token in nameTokens) {
    if (containsWord(text, token)) return true;
    for (final s in suffixes) {
      if (containsWord(text, '$token$s') || containsWord(text, '$token $s')) {
        return true;
      }
    }
  }
  return false;
}

/// Matches customer name against text using known spelling/language variants.
bool matchesCustomerVariant(String text, String customerName) {
  final suffixes = ['ki', 'ku', 'gariki', 'కి', 'కు', 'గారికి'];
  final nameTokens = customerName
      .split(RegExp(r'[()/,]+'))
      .map((t) => t.trim())
      .where((t) => t.length >= 2);

  final allVariants = <String>{};
  for (final token in nameTokens) {
    final lower = token.toLowerCase();
    for (final entry in KNOWN_CUSTOMER_VARIANTS.entries) {
      if (entry.key == lower || entry.value.any((v) => v.toLowerCase() == lower)) {
        allVariants.addAll(entry.value);
      }
    }
  }

  for (final token in allVariants) {
    if (containsWord(text, token)) return true;
    for (final s in suffixes) {
      if (containsWord(text, '$token$s') || containsWord(text, '$token $s')) {
        return true;
      }
    }
  }
  return false;
}

/// Matches customer name against text using whole-word boundaries.
/// Handles customer names with parentheses (e.g. "Ramesh (రామేష్)"),
/// bilingual variants (రమేష్ vs Ramesh), and common Telugu honorific/case suffixes.
bool matchesCustomer(String text, String customerName) {
  return matchesCustomerDirect(text, customerName) || matchesCustomerVariant(text, customerName);
}

class ParsedEntry {
  final String? type;
  final String? customerName;
  final int? itemId;
  final String? itemName;
  final double? qty;
  final String? unit;
  final double? amount;
  final String rawText;

  ParsedEntry({
    this.type,
    this.customerName,
    this.itemId,
    this.itemName,
    this.qty,
    this.unit,
    this.amount,
    required this.rawText,
  });

  bool get isEmpty =>
      type == null &&
      customerName == null &&
      itemId == null &&
      itemName == null &&
      qty == null &&
      amount == null;

  @override
  String toString() {
    return 'ParsedEntry(type: $type, customer: $customerName, item: $itemName, qty: $qty $unit, amount: $amount, raw: $rawText)';
  }
}

/// Parses voice or typed text into a structured Kirana transaction entry.
/// Pure Dart: No Flutter imports.
ParsedEntry parse(
  String text,
  List<Item> items,
  List<Customer> customers,
) {
  final cleanText = text.trim();
  if (cleanText.isEmpty) {
    return ParsedEntry(rawText: text);
  }

  // 1. Resolve Customer (match whole words only, direct matches first, then variants)
  String? customerName;
  final sortedCustomers = List<Customer>.from(customers)
    ..sort((a, b) => b.name.length.compareTo(a.name.length));
  for (final c in sortedCustomers) {
    if (matchesCustomerDirect(cleanText, c.name)) {
      customerName = c.name;
      break;
    }
  }
  if (customerName == null) {
    for (final c in sortedCustomers) {
      if (matchesCustomer(cleanText, c.name)) {
        customerName = c.name;
        break;
      }
    }
  }

  // If not found in customers list, extract word before 'ki' / 'కి'
  if (customerName == null) {
    // Matches "రామేష్కి", "రామేష్ కి", "Ramesh ki", "Rameshki"
    final kiRegex = RegExp(
      r'(?:^|[,\s])([a-zA-Z\u0C00-\u0C7F]+?)(?:\s*ki|\s*కి)(?:[^a-zA-Z\u0C00-\u0C7F]|$)',
      caseSensitive: false,
    );
    final match = kiRegex.firstMatch(cleanText);
    if (match != null) {
      final candidate = match.group(1)?.trim();
      final excluded = {'baaki', 'baki', 'బాకీ', 'appu', 'అప్పు', 'manaki', 'udhar', 'pappu', 'పప్పు'};
      if (candidate != null &&
          candidate.isNotEmpty &&
          !excluded.contains(candidate.toLowerCase())) {
        customerName = candidate;
      }
    }
  }

  // 2. Resolve Quantity & Unit
  double? qty;
  String? unit;

  final allUnitTerms = UNIT_SYNONYMS.values.expand((list) => list).toList();
  allUnitTerms.sort((a, b) => b.length.compareTo(a.length)); // Longest first
  final unitPattern = allUnitTerms.map(RegExp.escape).join('|');

  final qtyRegex = RegExp(
    '(\\d+(?:\\.\\d+)?)\\s*($unitPattern)(?:[^a-zA-Z\\u0C00-\\u0C7F]|\$)',
    caseSensitive: false,
  );
  final qtyMatch = qtyRegex.firstMatch(cleanText);
  if (qtyMatch != null) {
    qty = double.tryParse(qtyMatch.group(1)!);
    final matchedUnitStr = qtyMatch.group(2)!.toLowerCase();
    for (final entry in UNIT_SYNONYMS.entries) {
      if (entry.value.any((u) => u.toLowerCase() == matchedUnitStr)) {
        unit = entry.key;
        break;
      }
    }
  }

  // Check Telugu number words before unit (e.g. "ఒక లీటరు", "రెండు కిలోలు", "అర కిలో", "పావు కిలో")
  if (qty == null) {
    final numWordsList = TELUGU_NUMBER_WORDS.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final numWordPattern = numWordsList.map(RegExp.escape).join('|');

    final wordQtyRegex = RegExp(
      '(?:^|[^a-zA-Z0-9\\u0C00-\\u0C7F])($numWordPattern)\\s*($unitPattern)(?:[^a-zA-Z\\u0C00-\\u0C7F]|\$)',
      caseSensitive: false,
    );
    final wordQtyMatch = wordQtyRegex.firstMatch(cleanText);
    if (wordQtyMatch != null) {
      final matchedWord = wordQtyMatch.group(1)!.toLowerCase();
      qty = TELUGU_NUMBER_WORDS[matchedWord];
      final matchedUnitStr = wordQtyMatch.group(2)!.toLowerCase();
      for (final entry in UNIT_SYNONYMS.entries) {
        if (entry.value.any((u) => u.toLowerCase() == matchedUnitStr)) {
          unit = entry.key;
          break;
        }
      }
    }
  }

  // Fallback for standalone fractions or number words
  if (qty == null) {
    final fractions = {
      'ఒకటిన్నర': 1.5,
      'రెండున్నర': 2.5,
      'మూడున్నర': 3.5,
      'ముప్పావు': 0.75,
      'muppaavu': 0.75,
      'అర': 0.5,
      'ara': 0.5,
      'పావు': 0.25,
      'paavu': 0.25,
      'pavu': 0.25,
    };
    for (final f in fractions.entries) {
      if (containsWord(cleanText, f.key)) {
        qty = f.value;
        for (final entry in UNIT_SYNONYMS.entries) {
          if (entry.value.any((u) => containsWord(cleanText, u))) {
            unit = entry.key;
            break;
          }
        }
        break;
      }
    }
  }

  // Convert grams to kg and ml to litres
  if (unit == 'gram') {
    if (qty != null) {
      qty = qty / 1000.0;
    }
    unit = 'kg';
  } else if (unit == 'ml') {
    if (qty != null) {
      qty = qty / 1000.0;
    }
    unit = 'litre';
  }

  // 3. Resolve Amount
  double? amount;
  // Match prefix e.g. rs 300, ₹300, రూ. 300
  final prefixAmountRegex = RegExp(
    r'(?:rs\.?|₹|రూ\.?|రూ|inr)\s*(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );
  // Match suffix e.g. 300 rupayalu, 300 రూపాయలు, 300 rs, 300/-
  final suffixAmountRegex = RegExp(
    r'(\d+(?:\.\d+)?)\s*(?:rupayalu|roopayalu|rupai|రూపాయలు|రూపాయి|rs|₹|/-)(?:[^a-zA-Z\u0C00-\u0C7F]|$)',
    caseSensitive: false,
  );

  final suffixMatch = suffixAmountRegex.firstMatch(cleanText);
  if (suffixMatch != null) {
    amount = double.tryParse(suffixMatch.group(1)!);
  } else {
    final prefixMatch = prefixAmountRegex.firstMatch(cleanText);
    if (prefixMatch != null) {
      amount = double.tryParse(prefixMatch.group(1)!);
    }
  }

  // Check Telugu amount words before rupee terms
  if (amount == null) {
    final amountWordsList = TELUGU_AMOUNT_WORDS.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final amountWordPattern = amountWordsList.map(RegExp.escape).join('|');
    final wordAmountRegex = RegExp(
      '(?:^|[^a-zA-Z0-9\\u0C00-\\u0C7F])($amountWordPattern)\\s*(?:rupayalu|roopayalu|rupai|రూపాయలు|రూపాయి|రూ|rs|₹)(?:[^a-zA-Z\\u0C00-\\u0C7F]|\$)',
      caseSensitive: false,
    );
    final wordAmountMatch = wordAmountRegex.firstMatch(cleanText);
    if (wordAmountMatch != null) {
      amount = TELUGU_AMOUNT_WORDS[wordAmountMatch.group(1)!.toLowerCase()];
    }
  }

  // If amount was not explicitly tagged with rupees/rs, check for a number that wasn't used for qty
  if (amount == null) {
    final allNumbers = RegExp(r'\b(\d+(?:\.\d+)?)\b').allMatches(cleanText);
    for (final numMatch in allNumbers) {
      final val = double.tryParse(numMatch.group(1)!);
      if (val != null && (qty == null || val != qty)) {
        amount = val;
        break;
      }
    }
  }

  // 4. Resolve Item (match whole words only, avoid "Rice" matching "price")
  int? itemId;
  String? itemName;

  // Check database items first (Telugu or English name) - check whole word
  final sortedItems = List<Item>.from(items)
    ..sort((a, b) {
      final lenA = (a.nameEn?.length ?? 0) > a.nameTe.length ? (a.nameEn?.length ?? 0) : a.nameTe.length;
      final lenB = (b.nameEn?.length ?? 0) > b.nameTe.length ? (b.nameEn?.length ?? 0) : b.nameTe.length;
      return lenB.compareTo(lenA);
    });

  for (final item in sortedItems) {
    final enMatch = item.nameEn != null &&
        item.nameEn!.isNotEmpty &&
        containsWord(cleanText, item.nameEn!);
    final teMatch = containsWord(cleanText, item.nameTe);
    if (enMatch || teMatch) {
      itemId = item.id;
      itemName = item.nameEn ?? item.nameTe;
      unit ??= item.unit;
      break;
    }
  }

  // If no DB item matched, check synonym dictionary with whole-word matching
  if (itemName == null) {
    final synEntries = ITEM_SYNONYMS.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final syn in synEntries) {
      if (containsWord(cleanText, syn.key)) {
        final canonical = syn.value;
        // See if canonical exists in DB items
        final dbItem = items.firstWhere(
          (it) =>
              (it.nameEn != null && it.nameEn!.toLowerCase() == canonical.toLowerCase()) ||
              it.nameTe.toLowerCase() == syn.key.toLowerCase(),
          orElse: () => Item(nameTe: syn.key, nameEn: canonical, unit: unit ?? 'kg'),
        );
        itemId = dbItem.id;
        itemName = dbItem.nameEn ?? dbItem.nameTe;
        unit ??= dbItem.unit;
        break;
      }
    }
  }

  // 5. Amount Auto-fill (Quantity * Sell Price if amount was not spoken)
  if (amount == null && qty != null) {
    Item? matchedItem;
    if (itemId != null) {
      matchedItem = items.where((it) => it.id == itemId).firstOrNull;
    }
    if (matchedItem == null && itemName != null) {
      final targetName = itemName.toLowerCase();
      matchedItem = items.where((it) =>
        (it.nameEn != null && it.nameEn!.toLowerCase() == targetName) ||
        it.nameTe.toLowerCase() == targetName
      ).firstOrNull;
    }
    if (matchedItem != null && matchedItem.sellPrice > 0) {
      amount = qty * matchedItem.sellPrice;
    }
  }

  // 6. Resolve Type (match whole words only so "pappu" doesn't trigger "appu")
  String? type;
  bool matchesTypeKeyword(String typeKey) {
    final keywords = TYPE_KEYWORDS[typeKey] ?? [];
    return keywords.any((kw) => containsWord(cleanText, kw));
  }

  if (matchesTypeKeyword('credit_sale')) {
    type = 'credit_sale';
  } else if (matchesTypeKeyword('payment_received')) {
    type = 'payment_received';
  } else if (matchesTypeKeyword('restock')) {
    type = 'restock';
  } else if (matchesTypeKeyword('expense')) {
    type = 'expense';
  } else if (matchesTypeKeyword('cash_sale')) {
    type = 'cash_sale';
  }

  // Fallback heuristic based on extracted fields if no keyword explicitly specified
  if (type == null) {
    if (customerName != null && amount != null && itemName == null) {
      type = 'payment_received';
    } else if (itemName != null && (qty != null || amount != null)) {
      type = customerName != null ? 'credit_sale' : 'cash_sale';
    }
  }

  return ParsedEntry(
    type: type,
    customerName: customerName,
    itemId: itemId,
    itemName: itemName,
    qty: qty,
    unit: unit,
    amount: amount,
    rawText: text,
  );
}
