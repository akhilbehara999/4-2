import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:log_app/data/local_db.dart';
import 'package:log_app/data/models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite_dev.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Database smoke test: inserts and reads an item', () async {
    databaseFactory = sqfliteDatabaseFactoryDefault;

    final List<Map<String, Object?>> storedItems = [];
    const channel = MethodChannel('com.tekartik.sqflite');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'getDatabasesPath':
          return '/data/data/com.log.log_app/databases';
        case 'openDatabase':
          return 1;
        case 'execute':
          return null;
        case 'insert':
          final itemData = {
            'id': 1,
            'name_te': 'ఉల్లిపాయలు',
            'name_en': 'Onions',
            'unit': 'kg',
            'current_stock': 15.5,
            'alert_days': 3,
            'cost_price': 25.0,
            'sell_price': 30.0,
          };
          storedItems.add(itemData);
          return 1;
        case 'query':
          return storedItems;
        case 'closeDatabase':
          return null;
        default:
          return null;
      }
    });

    final localDb = LocalDb.instance;
    final item = Item(
      nameTe: 'ఉల్లిపాయలు',
      nameEn: 'Onions',
      unit: 'kg',
      currentStock: 15.5,
      alertDays: 3,
      costPrice: 25.0,
      sellPrice: 30.0,
    );

    final id = await localDb.insertItem(item);
    expect(id, 1);

    final retrieved = await localDb.getItem(1);
    expect(retrieved, isNotNull);
    expect(retrieved!.id, 1);
    expect(retrieved.nameTe, 'ఉల్లిపాయలు');
    expect(retrieved.nameEn, 'Onions');
    expect(retrieved.unit, 'kg');
    expect(retrieved.currentStock, 15.5);
    expect(retrieved.alertDays, 3);
    expect(retrieved.costPrice, 25.0);
    expect(retrieved.sellPrice, 30.0);
  });

  test('Models serialization unit tests', () {
    final customer = Customer(name: 'Ramu', phone: '9876543210', balanceDue: 450.0);
    final customerMap = customer.toMap();
    final restoredCustomer = Customer.fromMap(customerMap);
    expect(restoredCustomer.name, 'Ramu');
    expect(restoredCustomer.balanceDue, 450.0);

    final txn = Txn(
      type: 'sale',
      itemId: 1,
      customerId: 1,
      qty: 2.0,
      amount: 60.0,
      rawText: '2 kg onions',
      createdAt: '2026-10-09T18:00:00Z',
      synced: 0,
    );
    final txnMap = txn.toMap();
    final restoredTxn = Txn.fromMap(txnMap);
    expect(restoredTxn.type, 'sale');
    expect(restoredTxn.amount, 60.0);

    final stockLog = StockLog(
      itemId: 1,
      change: -2.0,
      reason: 'sale',
      createdAt: '2026-10-09T18:00:00Z',
    );
    final stockMap = stockLog.toMap();
    final restoredStock = StockLog.fromMap(stockMap);
    expect(restoredStock.change, -2.0);

    final alert = Alert(
      itemId: 1,
      predictedDaysLeft: 2,
      sentAt: '2026-10-09T18:00:00Z',
      seen: 0,
    );
    final alertMap = alert.toMap();
    final restoredAlert = Alert.fromMap(alertMap);
    expect(restoredAlert.predictedDaysLeft, 2);
    expect(restoredAlert.seen, 0);
  });
}
