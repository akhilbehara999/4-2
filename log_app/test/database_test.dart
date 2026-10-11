import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:log_app/data/database/database_service.dart';
import 'package:log_app/data/models/item.dart';
import 'package:log_app/data/models/customer.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await DatabaseService().close();
  });

  test('Database initializes all 6 tables from PRD and performs CRUD operations', () async {
    final db = await DatabaseService().database;

    // Verify all 6 tables exist in sqlite_master
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    final tableNames = tables.map((row) => row['name'] as String).toSet();

    expect(tableNames, contains('item'));
    expect(tableNames, contains('customer'));
    expect(tableNames, contains('txn'));
    expect(tableNames, contains('stock_log'));
    expect(tableNames, contains('alert'));
    expect(tableNames, contains('correction_log'));

    // Insert an item
    final item = Item(
      nameTe: 'బియ్యం',
      nameEn: 'Rice',
      unit: 'kg',
      currentStock: 50.0,
      alertDays: 2,
      costPrice: 45.0,
      sellPrice: 60.0,
    );
    final itemId = await db.insert('item', item.toMap());
    expect(itemId, isPositive);

    final fetchedItemRows = await db.query('item', where: 'id = ?', whereArgs: [itemId]);
    expect(fetchedItemRows.length, 1);
    final fetchedItem = Item.fromMap(fetchedItemRows.first);
    expect(fetchedItem.nameTe, 'బియ్యం');
    expect(fetchedItem.nameEn, 'Rice');
    expect(fetchedItem.currentStock, 50.0);

    // Insert a customer
    final customer = Customer(
      name: 'Ramesh',
      phone: '9876543210',
      balanceDue: 300.0,
    );
    final customerId = await db.insert('customer', customer.toMap());
    expect(customerId, isPositive);

    final fetchedCustomerRows = await db.query('customer', where: 'id = ?', whereArgs: [customerId]);
    expect(fetchedCustomerRows.length, 1);
    final fetchedCustomer = Customer.fromMap(fetchedCustomerRows.first);
    expect(fetchedCustomer.name, 'Ramesh');
    expect(fetchedCustomer.balanceDue, 300.0);
  });
}
