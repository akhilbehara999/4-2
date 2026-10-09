import 'package:flutter_test/flutter_test.dart';
import 'package:log_app/data/models.dart';
import 'package:log_app/data/stock_engine.dart';

void main() {
  final now = DateTime(2026, 10, 9);

  group('StockEngine unit tests', () {
    test('1. Steady sales: 14 days of 5 units/day', () {
      final item = Item(
        id: 1,
        nameTe: 'బియ్యం',
        nameEn: 'Rice',
        unit: 'kg',
        currentStock: 25.0,
        alertDays: 2,
      );

      final sales = <DateTime, double>{};
      for (int i = 0; i < 14; i++) {
        sales[now.subtract(Duration(days: i))] = 5.0;
      }

      final result = StockEngine.calculateStatus(
        item: item,
        dailySales: sales,
        now: now,
      );

      expect(result.avgDailySales, closeTo(5.0, 0.001));
      expect(result.daysLeft, closeTo(5.0, 0.001)); // 25 / 5 = 5 days
      expect(result.status, StockColorStatus.green); // 5 > (2 + 2)
    });

    test('2. Recent spike: older days 2 units/day, last 7 days 10 units/day', () {
      final item = Item(
        id: 2,
        nameTe: 'నూనె',
        nameEn: 'Oil',
        unit: 'litre',
        currentStock: 14.0,
        alertDays: 2,
      );

      final sales = <DateTime, double>{};
      // Last 7 days: 10 units/day
      for (int i = 0; i < 7; i++) {
        sales[now.subtract(Duration(days: i))] = 10.0;
      }
      // Older 7 days: 2 units/day
      for (int i = 7; i < 14; i++) {
        sales[now.subtract(Duration(days: i))] = 2.0;
      }

      final result = StockEngine.calculateStatus(
        item: item,
        dailySales: sales,
        now: now,
      );

      // (2 * (7 * 10) + (7 * 2)) / (2 * 7 + 7) = (140 + 14) / 21 = 154 / 21 = 7.333
      expect(result.avgDailySales, closeTo(7.333, 0.01));
      // daysLeft = 14 / 7.333 = 1.909 <= alertDays(2) -> RED
      expect(result.daysLeft!, lessThanOrEqualTo(2.0));
      expect(result.status, StockColorStatus.red);
    });

    test('3. New item with 2 days of data: window < 3 returns "not enough data"', () {
      final item = Item(
        id: 3,
        nameTe: 'పంచదార',
        nameEn: 'Sugar',
        unit: 'kg',
        currentStock: 50.0,
        alertDays: 2,
      );

      final sales = <DateTime, double>{
        now: 4.0,
        now.subtract(const Duration(days: 1)): 5.0,
      };

      final result = StockEngine.calculateStatus(
        item: item,
        dailySales: sales,
        now: now,
      );

      expect(result.daysLeft, isNull);
      expect(result.status, StockColorStatus.grey);
      expect(result.message, 'not enough data');
    });

    test('4. Zero sales: avg == 0 returns "no recent sales"', () {
      final item = Item(
        id: 4,
        nameTe: 'ఉప్పు',
        nameEn: 'Salt',
        unit: 'packet',
        currentStock: 50.0,
        alertDays: 2,
      );

      final result = StockEngine.calculateStatus(
        item: item,
        dailySales: {},
        now: now,
      );

      expect(result.daysLeft, isNull);
      expect(result.status, StockColorStatus.grey);
      expect(result.message, 'no recent sales');
    });

    test('5. Stock already 0: days_left is 0, status is red', () {
      final item = Item(
        id: 5,
        nameTe: 'పప్పు',
        nameEn: 'Dal',
        unit: 'kg',
        currentStock: 0.0,
        alertDays: 2,
      );

      final sales = <DateTime, double>{
        now: 3.0,
        now.subtract(const Duration(days: 1)): 3.0,
        now.subtract(const Duration(days: 2)): 3.0,
      };

      final result = StockEngine.calculateStatus(
        item: item,
        dailySales: sales,
        now: now,
      );

      expect(result.daysLeft, 0.0);
      expect(result.status, StockColorStatus.red);
    });
  });
}
