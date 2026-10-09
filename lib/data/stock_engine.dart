import 'models.dart';

enum StockColorStatus {
  red,
  amber,
  green,
  grey,
}

class StockEngineResult {
  final double? daysLeft;
  final double avgDailySales;
  final StockColorStatus status;
  final String? message;

  StockEngineResult({
    required this.daysLeft,
    required this.avgDailySales,
    required this.status,
    this.message,
  });

  bool get isRed => status == StockColorStatus.red;
  bool get isAmber => status == StockColorStatus.amber;
  bool get isGreen => status == StockColorStatus.green;
  bool get isGrey => status == StockColorStatus.grey;

  @override
  String toString() =>
      'StockEngineResult(daysLeft: $daysLeft, avgDailySales: $avgDailySales, status: $status, message: $message)';
}

/// Pure Dart Stock Engine for Kirana items.
/// Calculates weighted average daily sales (last 7 days count double)
/// and predicts days of stock remaining.
class StockEngine {
  /// Evaluates the stock status of an [item] using daily sales.
  /// [dailySales]: Map of local dates (normalized to YYYY-MM-DD or midnight) to quantity sold.
  /// [now]: Optional reference date (defaults to DateTime.now()).
  static StockEngineResult calculateStatus({
    required Item item,
    required Map<DateTime, double> dailySales,
    DateTime? now,
  }) {
    final todayRef = now ?? DateTime.now();
    final today = DateTime(todayRef.year, todayRef.month, todayRef.day);

    // Normalize input sales map to midnight DateTimes
    final normalizedSales = <DateTime, double>{};
    for (final entry in dailySales.entries) {
      final dateKey = DateTime(entry.key.year, entry.key.month, entry.key.day);
      normalizedSales[dateKey] = (normalizedSales[dateKey] ?? 0.0) + entry.value;
    }

    // Edge case: stock is already 0 or negative
    if (item.currentStock <= 0) {
      return StockEngineResult(
        daysLeft: 0.0,
        avgDailySales: 0.0,
        status: StockColorStatus.red,
        message: 'Out of stock',
      );
    }

    // Find the date of the first sale with positive quantity
    DateTime? firstSaleDate;
    for (final entry in normalizedSales.entries) {
      if (entry.value > 0) {
        if (firstSaleDate == null || entry.key.isBefore(firstSaleDate)) {
          firstSaleDate = entry.key;
        }
      }
    }

    // If no sales at all with quantity > 0
    if (firstSaleDate == null) {
      return StockEngineResult(
        daysLeft: null,
        avgDailySales: 0.0,
        status: StockColorStatus.grey,
        message: 'no recent sales',
      );
    }

    // Window = min(14, days since first sale)
    final diffDays = today.difference(firstSaleDate).inDays + 1;
    final daysSinceFirstSale = diffDays < 1 ? 1 : diffDays;

    if (daysSinceFirstSale < 3) {
      return StockEngineResult(
        daysLeft: null,
        avgDailySales: 0.0,
        status: StockColorStatus.grey,
        message: 'not enough data',
      );
    }

    final windowDays = daysSinceFirstSale < 14 ? daysSinceFirstSale : 14;

    // Last 7 days vs older days in window
    final daysLast7 = windowDays <= 7 ? windowDays : 7;
    final daysOlder = windowDays > 7 ? windowDays - 7 : 0;

    double sumLast7 = 0.0;
    double sumOlder = 0.0;

    for (int i = 0; i < windowDays; i++) {
      final dayDate = today.subtract(Duration(days: i));
      final qty = normalizedSales[dayDate] ?? 0.0;

      if (i < 7) {
        sumLast7 += qty;
      } else {
        sumOlder += qty;
      }
    }

    final weightedDenominator = (2 * daysLast7) + daysOlder;
    if (weightedDenominator == 0) {
      return StockEngineResult(
        daysLeft: null,
        avgDailySales: 0.0,
        status: StockColorStatus.grey,
        message: 'no recent sales',
      );
    }

    final avg = ((2 * sumLast7) + sumOlder) / weightedDenominator;

    if (avg <= 0) {
      return StockEngineResult(
        daysLeft: null,
        avgDailySales: 0.0,
        status: StockColorStatus.grey,
        message: 'no recent sales',
      );
    }

    final daysLeft = item.currentStock / avg;
    final alertDays = item.alertDays > 0 ? item.alertDays : 2;

    StockColorStatus status;
    if (daysLeft <= alertDays) {
      status = StockColorStatus.red;
    } else if (daysLeft <= alertDays + 2) {
      status = StockColorStatus.amber;
    } else {
      status = StockColorStatus.green;
    }

    return StockEngineResult(
      daysLeft: daysLeft,
      avgDailySales: avg,
      status: status,
    );
  }
}
