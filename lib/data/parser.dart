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

/// Checks if [word] occurs as a distinct whole word in [text].
/// Word characters include Latin alphanumeric ([a-zA-Z0-9]) and Telugu script (\u0C00-\u0C7F).
/// Word boundaries are defined by start/end of string or non-word characters.
bool containsWord(String text, String word) {
  final cleanWord = word.trim();
  if (cleanWord.isEmpty) return false;
  final pattern = '(?:^|[^a-zA-Z0-9\\u0C00-\\u0C7F])${RegExp.escape(cleanWord)}(?:[^a-zA-Z0-9\\u0C00-\\u0C7F]|\$)';
  return RegExp(pattern, caseSensitive: false).hasMatch(text);
}

/// Matches customer name against text using whole-word boundaries.
/// Handles customer names with parentheses (e.g. "Ramesh (రామేష్)"),
/// and common Telugu honorific/case suffixes (ki, ku, gariki, కి, కు, గారికి).
bool matchesCustomer(String text, String customerName) {
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

  // 1. Resolve Customer (match whole words only, longest customer name first)
  String? customerName;
  final sortedCustomers = List<Customer>.from(customers)
    ..sort((a, b) => b.name.length.compareTo(a.name.length));
  for (final c in sortedCustomers) {
    if (matchesCustomer(cleanText, c.name)) {
      customerName = c.name;
      break;
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

  // 5. Resolve Type (match whole words only so "pappu" doesn't trigger "appu")
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
