import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class LocalDb {
  static const String databaseName = 'log_kirana.db';
  static const int databaseVersion = 1;

  static final LocalDb instance = LocalDb._internal();
  LocalDb._internal();
  factory LocalDb() => instance;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb({String? overridePath}) async {
    final path = overridePath ?? (kIsWeb ? databaseName : join(await getDatabasesPath(), databaseName));
    _db = await openDatabase(
      path,
      version: databaseVersion,
      onCreate: (db, version) async {
        await createTables(db);
      },
    );

    if (kDebugMode) {
      await _seedDemoItemsIfEmpty(_db!);
    }

    return _db!;
  }

  static Future<void> createTables(Database db) async {
    await db.execute('''
      CREATE TABLE item (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_te TEXT NOT NULL,
        name_en TEXT,
        unit TEXT NOT NULL,
        current_stock REAL NOT NULL DEFAULT 0.0,
        alert_days INTEGER NOT NULL DEFAULT 3,
        cost_price REAL NOT NULL DEFAULT 0.0,
        sell_price REAL NOT NULL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE customer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        balance_due REAL NOT NULL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE txn (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        item_id INTEGER,
        customer_id INTEGER,
        qty REAL,
        amount REAL NOT NULL,
        raw_text TEXT,
        audio_path TEXT,
        created_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (item_id) REFERENCES item(id),
        FOREIGN KEY (customer_id) REFERENCES customer(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        change REAL NOT NULL,
        reason TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES item(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE alert (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        predicted_days_left INTEGER NOT NULL,
        sent_at TEXT,
        seen INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (item_id) REFERENCES item(id)
      )
    ''');
  }

  Future<void> _seedDemoItemsIfEmpty(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM item'),
    );
    if (count == null || count == 0) {
      final demoItems = [
        Item(nameTe: 'బియ్యం', nameEn: 'Rice', unit: 'kg', currentStock: 50, costPrice: 45, sellPrice: 55),
        Item(nameTe: 'పంచదార', nameEn: 'Sugar', unit: 'kg', currentStock: 50, costPrice: 38, sellPrice: 44),
        Item(nameTe: 'నూనె', nameEn: 'Oil', unit: 'litre', currentStock: 50, costPrice: 120, sellPrice: 140),
        Item(nameTe: 'ఉప్పు', nameEn: 'Salt', unit: 'packet', currentStock: 50, costPrice: 18, sellPrice: 22),
        Item(nameTe: 'పప్పు', nameEn: 'Dal', unit: 'kg', currentStock: 50, costPrice: 130, sellPrice: 155),
        Item(nameTe: 'గోధుమ పిండి', nameEn: 'Wheat Flour', unit: 'kg', currentStock: 50, costPrice: 40, sellPrice: 48),
        Item(nameTe: 'కారం', nameEn: 'Chilli Powder', unit: 'packet', currentStock: 50, costPrice: 50, sellPrice: 65),
        Item(nameTe: 'టీ పొడి', nameEn: 'Tea Powder', unit: 'packet', currentStock: 50, costPrice: 70, sellPrice: 85),
      ];
      final batch = db.batch();
      for (final item in demoItems) {
        batch.insert('item', item.toMap());
      }
      await batch.commit(noResult: true);
    }
  }

  /// Saves a Kirana transaction in a single SQLite transaction:
  /// - Inserts into txn (keeping raw_text).
  /// - Cash & credit sales: item stock minus qty. Restock: plus qty. Writes stock_log row.
  /// - Credit sale: customer balance_due plus amount. Payment received: minus amount.
  ///   Creates the customer if new.
  /// - Expense: no stock or balance change.
  Future<int> saveTransaction({
    required String type,
    String? customerName,
    int? itemId,
    double? qty,
    double? amount,
    required String rawText,
  }) async {
    final db = await database;
    return await db.transaction<int>((txn) async {
      int? customerId;

      // 1. Customer balance update / creation
      if (customerName != null && customerName.trim().isNotEmpty) {
        final cleanCustName = customerName.trim();
        final existingCust = await txn.query(
          'customer',
          where: 'LOWER(name) = ?',
          whereArgs: [cleanCustName.toLowerCase()],
          limit: 1,
        );

        double balanceDue = 0.0;
        if (existingCust.isNotEmpty) {
          customerId = existingCust.first['id'] as int;
          balanceDue = (existingCust.first['balance_due'] as num?)?.toDouble() ?? 0.0;
        } else {
          customerId = await txn.insert('customer', {
            'name': cleanCustName,
            'balance_due': 0.0,
          });
          balanceDue = 0.0;
        }

        if (type == 'credit_sale') {
          balanceDue += (amount ?? 0.0);
          await txn.update(
            'customer',
            {'balance_due': balanceDue},
            where: 'id = ?',
            whereArgs: [customerId],
          );
        } else if (type == 'payment_received') {
          balanceDue -= (amount ?? 0.0);
          await txn.update(
            'customer',
            {'balance_due': balanceDue},
            where: 'id = ?',
            whereArgs: [customerId],
          );
        }
      }

      // 2. Item stock & stock_log update
      if (itemId != null && qty != null && qty > 0) {
        final itemRows = await txn.query(
          'item',
          where: 'id = ?',
          whereArgs: [itemId],
          limit: 1,
        );

        if (itemRows.isNotEmpty) {
          final currentStock = (itemRows.first['current_stock'] as num?)?.toDouble() ?? 0.0;
          double change = 0.0;
          String reason = type;

          if (type == 'cash_sale' || type == 'credit_sale') {
            change = -qty;
          } else if (type == 'restock') {
            change = qty;
            reason = 'restock';
          }

          if (change != 0.0) {
            final updatedStock = currentStock + change;
            await txn.update(
              'item',
              {'current_stock': updatedStock},
              where: 'id = ?',
              whereArgs: [itemId],
            );

            await txn.insert('stock_log', {
              'item_id': itemId,
              'change': change,
              'reason': reason,
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        }
      }

      // 3. Insert transaction
      final txnId = await txn.insert('txn', {
        'type': type,
        'item_id': itemId,
        'customer_id': customerId,
        'qty': qty,
        'amount': amount ?? 0.0,
        'raw_text': rawText,
        'created_at': DateTime.now().toIso8601String(),
        'synced': 0,
      });

      return txnId;
    });
  }

  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('item', item.toMap());
  }

  Future<Item?> getItem(int id) async {
    final db = await database;
    final results = await db.query(
      'item',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return Item.fromMap(results.first);
    }
    return null;
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    final results = await db.query('item', orderBy: 'id ASC');
    return results.map((m) => Item.fromMap(m)).toList();
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final results = await db.query('customer', orderBy: 'name ASC');
    return results.map((m) => Customer.fromMap(m)).toList();
  }

  Future<List<Customer>> getCustomersWithBalance() async {
    final db = await database;
    final results = await db.query(
      'customer',
      orderBy: 'balance_due DESC, name ASC',
    );
    return results.map((m) => Customer.fromMap(m)).toList();
  }

  Future<List<Txn>> getRecentTxns({int limit = 10}) async {
    final db = await database;
    final results = await db.query(
      'txn',
      orderBy: 'id DESC',
      limit: limit,
    );
    return results.map((m) => Txn.fromMap(m)).toList();
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
