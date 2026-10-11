import 'package:sqflite/sqflite.dart';
import 'db_factory.dart';

class DatabaseService {
  static const String _dbName = 'log_database.db';
  static const int _dbVersion = 1;

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb([String? overridePath]) async {
    initDatabaseFactory();

    final path = overridePath ?? _dbName;

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // 1. item table
    await db.execute('''
      CREATE TABLE item (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_te TEXT NOT NULL,
        name_en TEXT NOT NULL,
        unit TEXT NOT NULL,
        current_stock REAL NOT NULL DEFAULT 0,
        alert_days INTEGER NOT NULL DEFAULT 2,
        cost_price REAL NOT NULL DEFAULT 0,
        sell_price REAL NOT NULL DEFAULT 0
      )
    ''');

    // 2. customer table
    await db.execute('''
      CREATE TABLE customer (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        balance_due REAL NOT NULL DEFAULT 0
      )
    ''');

    // 3. txn table
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
        FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE SET NULL,
        FOREIGN KEY (customer_id) REFERENCES customer(id) ON DELETE SET NULL
      )
    ''');

    // 4. stock_log table
    await db.execute('''
      CREATE TABLE stock_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        change REAL NOT NULL,
        reason TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE
      )
    ''');

    // 5. alert table
    await db.execute('''
      CREATE TABLE alert (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        predicted_days_left REAL NOT NULL,
        sent_at TEXT NOT NULL,
        seen INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE
      )
    ''');

    // 6. correction_log table
    await db.execute('''
      CREATE TABLE correction_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        txn_id INTEGER,
        raw_text TEXT,
        parsed_fields TEXT,
        final_fields TEXT,
        was_edited INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (txn_id) REFERENCES txn(id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
