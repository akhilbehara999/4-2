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
    final path = overridePath ?? join(await getDatabasesPath(), databaseName);
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: (db, version) async {
        await createTables(db);
      },
    );
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

  Future<List<Item>> getItems() async {
    final db = await database;
    final results = await db.query('item');
    return results.map((m) => Item.fromMap(m)).toList();
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
