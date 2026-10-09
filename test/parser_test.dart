import 'package:flutter_test/flutter_test.dart';
import 'package:log_app/data/models.dart';
import 'package:log_app/data/parser.dart';

void main() {
  final sampleItems = [
    Item(id: 1, nameTe: 'బియ్యం', nameEn: 'Rice', unit: 'kg', currentStock: 50),
    Item(id: 2, nameTe: 'పంచదార', nameEn: 'Sugar', unit: 'kg', currentStock: 50),
    Item(id: 3, nameTe: 'నూనె', nameEn: 'Oil', unit: 'litre', currentStock: 50),
    Item(id: 4, nameTe: 'ఉప్పు', nameEn: 'Salt', unit: 'packet', currentStock: 50),
    Item(id: 5, nameTe: 'పప్పు', nameEn: 'Dal', unit: 'kg', currentStock: 50),
  ];

  final sampleCustomers = [
    Customer(id: 1, name: 'రామేష్', balanceDue: 0),
    Customer(id: 2, name: 'సురేష్', balanceDue: 0),
    Customer(id: 3, name: 'Ramesh', balanceDue: 0),
    Customer(id: 4, name: 'Suresh', balanceDue: 0),
  ];

  group('Rule-based Kirana parser tests', () {
    test('1. Telugu script credit sale', () {
      final res = parse(
        'రామేష్కి 5 కిలోల బియ్యం అప్పు ఇచ్చాను, 300 రూపాయలు',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'credit_sale');
      expect(res.customerName, 'రామేష్');
      expect(res.itemName, 'Rice');
      expect(res.itemId, 1);
      expect(res.qty, 5.0);
      expect(res.unit, 'kg');
      expect(res.amount, 300.0);
    });

    test('2. Romanized Telugu credit sale', () {
      final res = parse(
        'Ramesh ki 5 kilo biyyam udhar ichanu, 300 rupayalu',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'credit_sale');
      expect(res.customerName, 'Ramesh');
      expect(res.itemName, 'Rice');
      expect(res.itemId, 1);
      expect(res.qty, 5.0);
      expect(res.unit, 'kg');
      expect(res.amount, 300.0);
    });

    test('3. Telugu script cash sale', () {
      final res = parse(
        '2 లీటర్ల నూనె అమ్మాను 260 రూపాయలు',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'cash_sale');
      expect(res.itemName, 'Oil');
      expect(res.itemId, 3);
      expect(res.qty, 2.0);
      expect(res.unit, 'litre');
      expect(res.amount, 260.0);
    });

    test('4. Romanized Telugu cash sale', () {
      final res = parse(
        '1 kilo sugar ammanu 45 rs',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'cash_sale');
      expect(res.itemName, 'Sugar');
      expect(res.itemId, 2);
      expect(res.qty, 1.0);
      expect(res.unit, 'kg');
      expect(res.amount, 45.0);
    });

    test('5. Telugu script payment received', () {
      final res = parse(
        'సురేష్ 500 రూపాయలు ఇచ్చాడు',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'payment_received');
      expect(res.customerName, 'సురేష్');
      expect(res.amount, 500.0);
    });

    test('6. Romanized Telugu payment received', () {
      final res = parse(
        'Suresh 1000 rupayalu ichadu',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'payment_received');
      expect(res.customerName, 'Suresh');
      expect(res.amount, 1000.0);
    });

    test('7. Romanized Telugu restock', () {
      final res = parse(
        '10 packet uppu techanu',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'restock');
      expect(res.itemName, 'Salt');
      expect(res.itemId, 4);
      expect(res.qty, 10.0);
      expect(res.unit, 'packet');
    });

    test('8. Telugu script restock', () {
      final res = parse(
        '20 కిలోల పప్పు తెచ్చాను',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'restock');
      expect(res.itemName, 'Dal');
      expect(res.itemId, 5);
      expect(res.qty, 20.0);
      expect(res.unit, 'kg');
    });

    test('9. Telugu script expense', () {
      final res = parse(
        'కరెంట్ బిల్లు కట్టాను 450 రూపాయలు',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'expense');
      expect(res.amount, 450.0);
    });

    test('10. Romanized Telugu expense', () {
      final res = parse(
        'Shop rent kattanu 2000 rs',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'expense');
      expect(res.amount, 2000.0);
    });
  });
}
