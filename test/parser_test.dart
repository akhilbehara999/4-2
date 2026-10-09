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

    test('11. pappu is NOT read as credit_sale (whole-word matching fix)', () {
      final res = parse(
        '1 kg pappu 120 rs',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'cash_sale');
      expect(res.itemName, 'Dal');
      expect(res.qty, 1.0);
      expect(res.unit, 'kg');
      expect(res.amount, 120.0);
    });

    test('12. price does NOT match Rice (whole-word matching fix)', () {
      final res = parse(
        'sugar price 50 rs',
        sampleItems,
        sampleCustomers,
      );
      expect(res.itemName, 'Sugar');
      expect(res.amount, 50.0);
    });

    test('13. Short customer name does NOT match inside longer words', () {
      final customersWithShort = [
        ...sampleCustomers,
        Customer(id: 5, name: 'Anu', balanceDue: 0),
      ];
      final res = parse(
        'Anupama ki 5 kg biyyam 250 rs',
        sampleItems,
        customersWithShort,
      );
      // "Anupama" is extracted as customer, not the substring "Anu"
      expect(res.customerName, 'Anupama');
      expect(res.itemName, 'Rice');
    });

    test('14. Gram to kg unit conversion (500 gram -> 0.5 kg)', () {
      final res = parse(
        '500 gram sugar 25 rs',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'cash_sale');
      expect(res.itemName, 'Sugar');
      expect(res.qty, 0.5);
      expect(res.unit, 'kg');
      expect(res.amount, 25.0);
    });

    test('15. Millilitre to litre unit conversion (500 ml -> 0.5 litre)', () {
      final res = parse(
        '500 ml oil 75 rs',
        sampleItems,
        sampleCustomers,
      );
      expect(res.type, 'cash_sale');
      expect(res.itemName, 'Oil');
      expect(res.qty, 0.5);
      expect(res.unit, 'litre');
      expect(res.amount, 75.0);
    });

    test('16. Telugu script gram to kg conversion (500 గ్రాములు -> 0.5 kg)', () {
      final res = parse(
        '500 గ్రాములు పంచదార 25 రూపాయలు',
        sampleItems,
        sampleCustomers,
      );
      expect(res.itemName, 'Sugar');
      expect(res.qty, 0.5);
      expect(res.unit, 'kg');
      expect(res.amount, 25.0);
    });

    test('17. areSameCustomer detects identical customers across Telugu variants and English', () {
      expect(areSameCustomer('Ramesh (రామేష్)', 'Ramesh'), isTrue);
      expect(areSameCustomer('Ramesh (రామేష్)', 'రామేష్'), isTrue);
      expect(areSameCustomer('Ramesh (రామేష్)', 'రమేష్'), isTrue);
      expect(areSameCustomer('Ramesh', 'రమేష్'), isTrue);
      expect(areSameCustomer('రామేష్', 'రమేష్'), isTrue);
      expect(areSameCustomer('Suresh (సురేష్)', 'Suresh'), isTrue);
      expect(areSameCustomer('Ramesh', 'Suresh'), isFalse);
    });

    test('18. Parser resolves Telugu variant "రమేష్" to existing customer "Ramesh (రామేష్)"', () {
      final bilingualCustomers = [
        Customer(id: 1, name: 'Ramesh (రామేష్)', balanceDue: 0),
        Customer(id: 2, name: 'Suresh (సురేష్)', balanceDue: 0),
      ];
      final res = parse(
        'రమేష్ కి 5 kg biyyam 250 rs',
        sampleItems,
        bilingualCustomers,
      );
      expect(res.type, 'credit_sale');
      expect(res.customerName, 'Ramesh (రామేష్)');
      expect(res.itemName, 'Rice');
      expect(res.qty, 5.0);
      expect(res.amount, 250.0);
    });

    test('19. Parser resolves English "Ramesh" to existing customer "Ramesh (రామేష్)"', () {
      final bilingualCustomers = [
        Customer(id: 1, name: 'Ramesh (రామేష్)', balanceDue: 0),
        Customer(id: 2, name: 'Suresh (సురేష్)', balanceDue: 0),
      ];
      final res = parse(
        'Ramesh ki 5 kg biyyam 250 rs',
        sampleItems,
        bilingualCustomers,
      );
      expect(res.type, 'credit_sale');
      expect(res.customerName, 'Ramesh (రామేష్)');
      expect(res.itemName, 'Rice');
    });
  });
}
