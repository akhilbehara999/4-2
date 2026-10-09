import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../core/notifications.dart';
import 'analytics.dart';
import 'models.dart';
import 'parser.dart';
import 'stock_engine.dart';

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

    await db.execute('''
      CREATE TABLE IF NOT EXISTS correction_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        txn_id INTEGER,
        raw_text TEXT NOT NULL,
        audio_path TEXT,
        parsed_type TEXT,
        parsed_customer TEXT,
        parsed_item_id INTEGER,
        parsed_qty REAL,
        parsed_amount REAL,
        final_type TEXT NOT NULL,
        final_customer TEXT,
        final_item_id INTEGER,
        final_qty REAL,
        final_amount REAL NOT NULL,
        was_edited INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (txn_id) REFERENCES txn(id)
      )
    ''');
  }

  Future<void> _seedDemoItemsIfEmpty(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM item'),
    );
    if (count == null || count == 0) {
      final demoItems = [
        Item(nameTe: 'బియ్యం', nameEn: 'Rice', unit: 'kg', currentStock: 50, alertDays: 2, costPrice: 45, sellPrice: 55),
        Item(nameTe: 'పంచదార', nameEn: 'Sugar', unit: 'kg', currentStock: 50, alertDays: 2, costPrice: 38, sellPrice: 44),
        Item(nameTe: 'నూనె', nameEn: 'Oil', unit: 'litre', currentStock: 50, alertDays: 2, costPrice: 120, sellPrice: 140),
        Item(nameTe: 'ఉప్పు', nameEn: 'Salt', unit: 'packet', currentStock: 50, alertDays: 2, costPrice: 18, sellPrice: 22),
        Item(nameTe: 'పప్పు', nameEn: 'Dal', unit: 'kg', currentStock: 50, alertDays: 2, costPrice: 130, sellPrice: 155),
        Item(nameTe: 'గోధుమ పిండి', nameEn: 'Wheat Flour', unit: 'kg', currentStock: 50, alertDays: 2, costPrice: 40, sellPrice: 48),
        Item(nameTe: 'కారం', nameEn: 'Chilli Powder', unit: 'packet', currentStock: 50, alertDays: 2, costPrice: 50, sellPrice: 65),
        Item(nameTe: 'టీ పొడి', nameEn: 'Tea Powder', unit: 'packet', currentStock: 50, alertDays: 2, costPrice: 70, sellPrice: 85),
      ];
      final batch = db.batch();
      for (final item in demoItems) {
        batch.insert('item', item.toMap());
      }
      await batch.commit(noResult: true);
    }
  }

  Future<int> saveTransaction({
    required String type,
    String? customerName,
    int? itemId,
    double? qty,
    double? amount,
    required String rawText,
    String? audioPath,
    ParsedEntry? parsedEntry,
  }) async {
    final db = await database;
    return await db.transaction<int>((txn) async {
      int? customerId;

      if (customerName != null && customerName.trim().isNotEmpty) {
        final cleanCustName = customerName.trim();
        final allCustomers = await txn.query('customer');
        Map<String, dynamic>? matchedRow;

        for (final row in allCustomers) {
          final rowName = (row['name'] as String?) ?? '';
          if (areSameCustomer(cleanCustName, rowName)) {
            matchedRow = row;
            break;
          }
        }

        double balanceDue = 0.0;
        if (matchedRow != null) {
          customerId = matchedRow['id'] as int;
          balanceDue = (matchedRow['balance_due'] as num?)?.toDouble() ?? 0.0;
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

      final txnId = await txn.insert('txn', {
        'type': type,
        'item_id': itemId,
        'customer_id': customerId,
        'qty': qty,
        'amount': amount ?? 0.0,
        'raw_text': rawText,
        'audio_path': audioPath,
        'created_at': DateTime.now().toIso8601String(),
        'synced': 0,
      });

      // Write correction log comparing parsed values against final saved values
      final wasEdited = parsedEntry != null &&
          (parsedEntry.type != type ||
           (parsedEntry.customerName ?? '').trim().toLowerCase() != (customerName ?? '').trim().toLowerCase() ||
           parsedEntry.itemId != itemId ||
           parsedEntry.qty != qty ||
           parsedEntry.amount != (amount ?? 0.0));

      await txn.insert('correction_log', {
        'txn_id': txnId,
        'raw_text': rawText,
        'audio_path': audioPath,
        'parsed_type': parsedEntry?.type,
        'parsed_customer': parsedEntry?.customerName,
        'parsed_item_id': parsedEntry?.itemId,
        'parsed_qty': parsedEntry?.qty,
        'parsed_amount': parsedEntry?.amount,
        'final_type': type,
        'final_customer': customerName,
        'final_item_id': itemId,
        'final_qty': qty,
        'final_amount': amount ?? 0.0,
        'was_edited': wasEdited ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      return txnId;
    });
  }

  Future<bool> deleteTransaction(int txnId) async {
    final db = await database;
    return await db.transaction<bool>((txn) async {
      final rows = await txn.query('txn', where: 'id = ?', whereArgs: [txnId], limit: 1);
      if (rows.isEmpty) return false;
      final row = rows.first;
      final type = row['type'] as String;
      final itemId = row['item_id'] as int?;
      final customerId = row['customer_id'] as int?;
      final qty = (row['qty'] as num?)?.toDouble();
      final amount = (row['amount'] as num?)?.toDouble() ?? 0.0;

      // 1. Reverse stock changes
      if (itemId != null && qty != null && qty > 0) {
        final itemRows = await txn.query('item', where: 'id = ?', whereArgs: [itemId], limit: 1);
        if (itemRows.isNotEmpty) {
          final currentStock = (itemRows.first['current_stock'] as num?)?.toDouble() ?? 0.0;
          double stockChange = 0.0;
          String reason = 'undo';
          if (type == 'cash_sale' || type == 'credit_sale') {
            stockChange = qty; // Add back inventory
            reason = 'undo_sale';
          } else if (type == 'restock') {
            stockChange = -qty; // Deduct erroneously restocked inventory
            reason = 'undo_restock';
          }

          if (stockChange != 0.0) {
            await txn.update(
              'item',
              {'current_stock': currentStock + stockChange},
              where: 'id = ?',
              whereArgs: [itemId],
            );
            await txn.insert('stock_log', {
              'item_id': itemId,
              'change': stockChange,
              'reason': reason,
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        }
      }

      // 2. Reverse customer balance changes
      if (customerId != null) {
        final custRows = await txn.query('customer', where: 'id = ?', whereArgs: [customerId], limit: 1);
        if (custRows.isNotEmpty) {
          final balanceDue = (custRows.first['balance_due'] as num?)?.toDouble() ?? 0.0;
          double newBalance = balanceDue;
          if (type == 'credit_sale') {
            newBalance = (balanceDue - amount).clamp(0.0, double.infinity);
          } else if (type == 'payment_received') {
            newBalance = balanceDue + amount;
          }
          await txn.update(
            'customer',
            {'balance_due': newBalance},
            where: 'id = ?',
            whereArgs: [customerId],
          );
        }
      }

      // 3. Delete from correction_log and txn
      await txn.delete('correction_log', where: 'txn_id = ?', whereArgs: [txnId]);
      await txn.delete('txn', where: 'id = ?', whereArgs: [txnId]);
      return true;
    });
  }

  Future<bool> updateTransaction({
    required int txnId,
    required String type,
    String? customerName,
    int? itemId,
    double? qty,
    double? amount,
  }) async {
    final db = await database;
    return await db.transaction<bool>((txn) async {
      final rows = await txn.query('txn', where: 'id = ?', whereArgs: [txnId], limit: 1);
      if (rows.isEmpty) return false;
      final oldRow = rows.first;
      final oldType = oldRow['type'] as String;
      final oldItemId = oldRow['item_id'] as int?;
      final oldCustomerId = oldRow['customer_id'] as int?;
      final oldQty = (oldRow['qty'] as num?)?.toDouble();
      final oldAmount = (oldRow['amount'] as num?)?.toDouble() ?? 0.0;

      // 1. Reverse old stock changes
      if (oldItemId != null && oldQty != null && oldQty > 0) {
        final itemRows = await txn.query('item', where: 'id = ?', whereArgs: [oldItemId], limit: 1);
        if (itemRows.isNotEmpty) {
          final cur = (itemRows.first['current_stock'] as num?)?.toDouble() ?? 0.0;
          double revertStock = 0.0;
          if (oldType == 'cash_sale' || oldType == 'credit_sale') {
            revertStock = oldQty;
          } else if (oldType == 'restock') {
            revertStock = -oldQty;
          }
          if (revertStock != 0.0) {
            await txn.update('item', {'current_stock': cur + revertStock}, where: 'id = ?', whereArgs: [oldItemId]);
          }
        }
      }

      // 2. Reverse old customer balance
      if (oldCustomerId != null) {
        final custRows = await txn.query('customer', where: 'id = ?', whereArgs: [oldCustomerId], limit: 1);
        if (custRows.isNotEmpty) {
          final bal = (custRows.first['balance_due'] as num?)?.toDouble() ?? 0.0;
          double revBal = bal;
          if (oldType == 'credit_sale') {
            revBal = (bal - oldAmount).clamp(0.0, double.infinity);
          } else if (oldType == 'payment_received') {
            revBal = bal + oldAmount;
          }
          await txn.update('customer', {'balance_due': revBal}, where: 'id = ?', whereArgs: [oldCustomerId]);
        }
      }

      // 3. Resolve new customer
      int? newCustomerId;
      if (customerName != null && customerName.trim().isNotEmpty) {
        final cName = customerName.trim();
        final cRows = await txn.query('customer', where: 'name = ?', whereArgs: [cName], limit: 1);
        if (cRows.isNotEmpty) {
          newCustomerId = cRows.first['id'] as int;
        } else {
          newCustomerId = await txn.insert('customer', {'name': cName, 'balance_due': 0.0});
        }
      }

      // 4. Apply new stock changes
      if (itemId != null && qty != null && qty > 0) {
        final itemRows = await txn.query('item', where: 'id = ?', whereArgs: [itemId], limit: 1);
        if (itemRows.isNotEmpty) {
          final cur = (itemRows.first['current_stock'] as num?)?.toDouble() ?? 0.0;
          double change = 0.0;
          if (type == 'cash_sale' || type == 'credit_sale') {
            change = -qty;
          } else if (type == 'restock') {
            change = qty;
          }
          if (change != 0.0) {
            await txn.update('item', {'current_stock': cur + change}, where: 'id = ?', whereArgs: [itemId]);
            await txn.insert('stock_log', {
              'item_id': itemId,
              'change': change,
              'reason': 'edit_$type',
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        }
      }

      // 5. Apply new customer balance changes
      if (newCustomerId != null) {
        final custRows = await txn.query('customer', where: 'id = ?', whereArgs: [newCustomerId], limit: 1);
        if (custRows.isNotEmpty) {
          final bal = (custRows.first['balance_due'] as num?)?.toDouble() ?? 0.0;
          double newBal = bal;
          if (type == 'credit_sale') {
            newBal = bal + (amount ?? 0.0);
          } else if (type == 'payment_received') {
            newBal = (bal - (amount ?? 0.0)).clamp(0.0, double.infinity);
          }
          await txn.update('customer', {'balance_due': newBal}, where: 'id = ?', whereArgs: [newCustomerId]);
        }
      }

      // 6. Update txn row
      await txn.update(
        'txn',
        {
          'type': type,
          'item_id': itemId,
          'customer_id': newCustomerId,
          'qty': qty,
          'amount': amount ?? 0.0,
        },
        where: 'id = ?',
        whereArgs: [txnId],
      );

      // 7. Update correction_log
      await txn.update(
        'correction_log',
        {
          'final_type': type,
          'final_customer': customerName,
          'final_item_id': itemId,
          'final_qty': qty,
          'final_amount': amount ?? 0.0,
          'was_edited': 1,
        },
        where: 'txn_id = ?',
        whereArgs: [txnId],
      );

      return true;
    });
  }

  Future<List<Txn>> getCustomerTransactions(int customerId) async {
    final db = await database;
    final results = await db.query(
      'txn',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'id DESC',
    );
    return results.map((m) => Txn.fromMap(m)).toList();
  }

  Future<List<CorrectionLog>> getCorrectionLogs() async {
    final db = await database;
    final results = await db.query('correction_log', orderBy: 'id DESC');
    return results.map((m) => CorrectionLog.fromMap(m)).toList();
  }

  Future<Map<String, dynamic>> getExtractionAccuracy() async {
    final db = await database;
    final totalCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM correction_log'),
    ) ?? 0;
    if (totalCount == 0) {
      return {
        'total': 0,
        'exact_matches': 0,
        'accuracy_percentage': 100.0,
      };
    }
    final uneditedCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM correction_log WHERE was_edited = 0'),
    ) ?? 0;
    final pct = (uneditedCount / totalCount) * 100.0;
    return {
      'total': totalCount,
      'exact_matches': uneditedCount,
      'accuracy_percentage': double.parse(pct.toStringAsFixed(1)),
    };
  }

  Future<int> insertItem(Item item) async {
    final db = await database;
    final id = await db.insert('item', item.toMap());
    if (item.currentStock > 0) {
      await db.insert('stock_log', {
        'item_id': id,
        'change': item.currentStock,
        'reason': 'opening_stock',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    return id;
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    final oldItem = item.id != null ? await getItem(item.id!) : null;
    final res = await db.update(
      'item',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );

    // If stock count was modified by hand, write a stock_log audit row
    if (oldItem != null && item.id != null && item.currentStock != oldItem.currentStock) {
      final change = item.currentStock - oldItem.currentStock;
      await db.insert('stock_log', {
        'item_id': item.id,
        'change': change,
        'reason': 'recount',
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    return res;
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

  /// Maps each itemId to its daily sales map (cash_sale and credit_sale)
  Future<Map<int, Map<DateTime, double>>> getAllItemsDailySales({int days = 30}) async {
    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final rows = await db.query(
      'txn',
      columns: ['item_id', 'qty', 'created_at'],
      where: "type IN ('cash_sale', 'credit_sale') AND item_id IS NOT NULL AND created_at >= ?",
      whereArgs: [cutoff.toIso8601String()],
    );

    final result = <int, Map<DateTime, double>>{};
    for (final row in rows) {
      final itemId = row['item_id'] as int?;
      final qty = (row['qty'] as num?)?.toDouble() ?? 0.0;
      final createdAtStr = row['created_at'] as String?;
      if (itemId == null || createdAtStr == null || qty <= 0) continue;

      final parsedDate = DateTime.tryParse(createdAtStr);
      if (parsedDate == null) continue;
      final dayKey = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

      result.putIfAbsent(itemId, () => {})[dayKey] = (result[itemId]![dayKey] ?? 0.0) + qty;
    }
    return result;
  }

  /// Runs the stock engine for all items, triggers notifications and inserts alerts for red items
  Future<List<StockItemEvaluation>> checkAndTriggerLowStockAlerts() async {
    final db = await database;
    final items = await getAllItems();
    final dailySalesMap = await getAllItemsDailySales(days: 30);
    final evaluations = <StockItemEvaluation>[];

    final now = DateTime.now();

    for (final item in items) {
      final sales = dailySalesMap[item.id] ?? {};
      final res = StockEngine.calculateStatus(item: item, dailySales: sales, now: now);
      evaluations.add(StockItemEvaluation(item: item, result: res));

      if (res.isRed) {
        // Check if an alert was sent in the last 24 hours
        final recentAlerts = await db.query(
          'alert',
          where: 'item_id = ?',
          whereArgs: [item.id],
          orderBy: 'id DESC',
          limit: 1,
        );

        bool shouldAlert = true;
        if (recentAlerts.isNotEmpty) {
          final sentAtStr = recentAlerts.first['sent_at'] as String?;
          if (sentAtStr != null) {
            final sentAt = DateTime.tryParse(sentAtStr);
            if (sentAt != null && now.difference(sentAt).inHours < 24) {
              shouldAlert = false;
            }
          }
        }

        if (shouldAlert) {
          final daysInt = (res.daysLeft ?? 0).round();
          await db.insert('alert', {
            'item_id': item.id,
            'predicted_days_left': daysInt,
            'sent_at': now.toIso8601String(),
            'seen': 0,
          });

          if (!kIsWeb) {
            await NotificationService.instance.showLowStockNotification(
              id: item.id ?? 1,
              title: '${item.nameTe} ఇంకా $daysInt రోజులకే సరిపోతుంది',
              body: '${item.nameEn ?? item.nameTe} only has $daysInt days of stock left',
            );
          }
        }
      }
    }

    return evaluations;
  }

  /// Returns items that currently have un-seen alerts or are red
  Future<List<Item>> getRedItems() async {
    final evaluations = await checkAndTriggerLowStockAlerts();
    return evaluations.where((e) => e.result.isRed).map((e) => e.item).toList();
  }

  /// Marks all alerts as seen
  Future<void> markAlertsSeen() async {
    final db = await database;
    await db.update('alert', {'seen': 1}, where: 'seen = 0');
  }

  /// Returns up to [limit] fastest-selling items whose last recount log is older than 7 days
  Future<List<Item>> getItemsNeedingWeeklyRecount({int limit = 3}) async {
    final db = await database;
    final items = await getAllItems();
    final now = DateTime.now();

    final qualifiedItems = <Item>[];
    final salesVelocity = <int, double>{};

    final dailySalesMap = await getAllItemsDailySales(days: 14);

    for (final item in items) {
      if (item.id == null) continue;
      final recentRecount = await db.query(
        'stock_log',
        where: "item_id = ? AND reason IN ('recount', 'recount_ok')",
        orderBy: 'id DESC',
        limit: 1,
      );

      bool needsRecount = false;
      if (recentRecount.isEmpty) {
        needsRecount = true;
      } else {
        final dateStr = recentRecount.first['created_at'] as String?;
        if (dateStr != null) {
          final dt = DateTime.tryParse(dateStr);
          if (dt != null && now.difference(dt).inDays >= 7) {
            needsRecount = true;
          }
        }
      }

      if (needsRecount) {
        qualifiedItems.add(item);
        final sales = dailySalesMap[item.id] ?? {};
        final totalSales = sales.values.fold<double>(0.0, (a, b) => a + b);
        salesVelocity[item.id!] = totalSales;
      }
    }

    // Sort by sales velocity descending
    qualifiedItems.sort((a, b) {
      final vA = salesVelocity[a.id] ?? 0.0;
      final vB = salesVelocity[b.id] ?? 0.0;
      return vB.compareTo(vA);
    });

    return qualifiedItems.take(limit).toList();
  }

  /// Confirms the current stock during weekly stock check
  Future<void> confirmRecountOk(int itemId) async {
    final db = await database;
    await db.insert('stock_log', {
      'item_id': itemId,
      'change': 0.0,
      'reason': 'recount_ok',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Updates stock to new quantity during weekly stock check
  Future<void> editStockRecount(int itemId, double newStock) async {
    final db = await database;
    final item = await getItem(itemId);
    if (item == null) return;

    final diff = newStock - item.currentStock;
    await db.update('item', {'current_stock': newStock}, where: 'id = ?', whereArgs: [itemId]);
    await db.insert('stock_log', {
      'item_id': itemId,
      'change': diff,
      'reason': 'recount',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Generates 30 days of synthetic demo transactions with higher volume on weekends
  Future<void> generateDemoData() async {
    final db = await database;
    final random = Random(42);
    final now = DateTime.now();

    // Ensure we have customers (prevent duplicates if single-script names exist)
    final customerNames = ['Ramesh (రామేష్)', 'Suresh (సురేష్)', 'Lakshmi (లక్ష్మి)', 'Venkat (వెంకట్)', 'Anitha (అనిత)'];
    final customerIds = <int>[];
    final existingCusts = await db.query('customer');

    for (final name in customerNames) {
      final match = existingCusts
          .where((row) => areSameCustomer(name, (row['name'] as String?) ?? ''))
          .firstOrNull;
      if (match != null) {
        customerIds.add(match['id'] as int);
      } else {
        final id = await db.insert('customer', {'name': name, 'balance_due': 0.0});
        customerIds.add(id);
      }
    }

    // Ensure items exist
    final items = await getAllItems();
    if (items.isEmpty) return;

    // Track state in memory
    final itemStock = {for (var i in items) i.id!: 50.0};
    final custBalances = {for (var id in customerIds) id: 0.0};

    final batch = db.batch();

    for (int dayOffset = 29; dayOffset >= 0; dayOffset--) {
      final targetDate = now.subtract(Duration(days: dayOffset));
      final y = targetDate.year;
      final m = targetDate.month;
      final d = targetDate.day;

      final isWeekend = targetDate.weekday == DateTime.saturday || targetDate.weekday == DateTime.sunday;
      final txnCount = isWeekend ? (8 + random.nextInt(6)) : (3 + random.nextInt(4));

      for (int t = 0; t < txnCount; t++) {
        final item = items[random.nextInt(items.length)];
        final isCredit = random.nextDouble() < 0.25;
        final type = isCredit ? 'credit_sale' : 'cash_sale';
        final qty = (1 + random.nextInt(4)).toDouble();
        final amount = qty * item.sellPrice;
        final custId = isCredit ? customerIds[random.nextInt(customerIds.length)] : null;

        // Build timestamps with DateTime(y, m, d, hour, min)
        final hour = 8 + random.nextInt(12); // between 8 AM and 7 PM
        final min = random.nextInt(60);
        final txnTime = DateTime(y, m, d, hour, min);

        batch.insert('txn', {
          'type': type,
          'item_id': item.id,
          'customer_id': custId,
          'qty': qty,
          'amount': amount,
          'raw_text': 'demo',
          'created_at': txnTime.toIso8601String(),
          'synced': 0,
        });

        // Stock change
        itemStock[item.id!] = (itemStock[item.id!] ?? 50.0) - qty;
        batch.insert('stock_log', {
          'item_id': item.id,
          'change': -qty,
          'reason': type,
          'created_at': txnTime.toIso8601String(),
        });

        if (isCredit && custId != null) {
          custBalances[custId] = (custBalances[custId] ?? 0.0) + amount;
        }
      }

      // Occasional restock
      if (dayOffset % 7 == 2) {
        final restockItem = items[random.nextInt(items.length)];
        const restockQty = 30.0;
        itemStock[restockItem.id!] = (itemStock[restockItem.id!] ?? 50.0) + restockQty;
        final restockTime = DateTime(y, m, d, 7, random.nextInt(60));
        batch.insert('txn', {
          'type': 'restock',
          'item_id': restockItem.id,
          'customer_id': null,
          'qty': restockQty,
          'amount': restockQty * restockItem.costPrice,
          'raw_text': 'demo',
          'created_at': restockTime.toIso8601String(),
          'synced': 0,
        });
        batch.insert('stock_log', {
          'item_id': restockItem.id,
          'change': restockQty,
          'reason': 'restock',
          'created_at': restockTime.toIso8601String(),
        });
      }

      // Occasional payment received
      if (dayOffset % 4 == 0) {
        final custId = customerIds[random.nextInt(customerIds.length)];
        final curBal = custBalances[custId] ?? 0.0;
        if (curBal > 200) {
          final payAmount = (100 + random.nextInt(4) * 50).toDouble();
          custBalances[custId] = curBal - payAmount;
          final payTime = DateTime(y, m, d, 18, random.nextInt(60));
          batch.insert('txn', {
            'type': 'payment_received',
            'item_id': null,
            'customer_id': custId,
            'qty': null,
            'amount': payAmount,
            'raw_text': 'demo',
            'created_at': payTime.toIso8601String(),
            'synced': 0,
          });
        }
      }

      // Occasional shop expense
      if (dayOffset % 6 == 1) {
        final expenseAmount = [50.0, 150.0, 300.0, 450.0][random.nextInt(4)];
        final expenseTime = DateTime(y, m, d, 13, random.nextInt(60));
        batch.insert('txn', {
          'type': 'expense',
          'item_id': null,
          'customer_id': null,
          'qty': null,
          'amount': expenseAmount,
          'raw_text': 'demo',
          'created_at': expenseTime.toIso8601String(),
          'synced': 0,
        });
      }
    }

    // Apply final stocks and customer balances
    for (final entry in itemStock.entries) {
      batch.update('item', {'current_stock': max(0.0, entry.value)}, where: 'id = ?', whereArgs: [entry.key]);
    }
    for (final entry in custBalances.entries) {
      batch.update('customer', {'balance_due': max(0.0, entry.value)}, where: 'id = ?', whereArgs: [entry.key]);
    }

    await batch.commit(noResult: true);
  }

  /// Clears all tables and re-seeds demo items
  Future<void> resetAllData() async {
    final db = await database;
    await db.delete('txn');
    await db.delete('stock_log');
    await db.delete('alert');
    await db.delete('customer');
    await db.delete('item');
    await _seedDemoItemsIfEmpty(db);
  }

  /// Calculates Dashboard aggregations for the specified period
  Future<DashboardData> getDashboardData(DashboardPeriod period) async {
    final db = await database;
    final now = DateTime.now();

    DateTime startDate;
    int dayCount;
    switch (period) {
      case DashboardPeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
        dayCount = 1;
        break;
      case DashboardPeriod.days7:
        final d = now.subtract(const Duration(days: 6));
        startDate = DateTime(d.year, d.month, d.day);
        dayCount = 7;
        break;
      case DashboardPeriod.days30:
        final d = now.subtract(const Duration(days: 29));
        startDate = DateTime(d.year, d.month, d.day);
        dayCount = 30;
        break;
    }

    final startDateStr = startDate.toIso8601String();
    final items = await getAllItems();
    final itemMap = {for (var i in items) i.id!: i};

    // 1. Transactions in period
    final txns = await db.query(
      'txn',
      where: 'created_at >= ?',
      whereArgs: [startDateStr],
    );

    if (txns.isEmpty) {
      // Check all-time total credit due
      final custRows = await db.rawQuery('SELECT SUM(balance_due) as total_due FROM customer WHERE balance_due > 0');
      final allTimeDue = custRows.isNotEmpty ? ((custRows.first['total_due'] as num?)?.toDouble() ?? 0.0) : 0.0;
      final evaluations = await checkAndTriggerLowStockAlerts();
      final lowStock = evaluations.where((e) => e.result.daysLeft != null && e.result.daysLeft! <= 3).toList();

      return DashboardData(
        period: period,
        totalSales: 0.0,
        totalExpenses: 0.0,
        estimatedProfit: 0.0,
        creditGiven: 0.0,
        totalCreditDue: allTimeDue,
        dailySalesPoints: [],
        top5Items: [],
        slowest5Items: [],
        top5CustomersDue: [],
        lowStockItems: lowStock,
        hasData: false,
      );
    }

    double totalSales = 0.0;
    double totalExpenses = 0.0;
    double totalCostOfGoods = 0.0;
    double creditGiven = 0.0;

    final itemSalesMap = <int, double>{};
    final itemQtyMap = <int, double>{};
    final dailySalesMap = <DateTime, double>{};

    for (final row in txns) {
      final type = row['type'] as String;
      final amount = (row['amount'] as num?)?.toDouble() ?? 0.0;
      final qty = (row['qty'] as num?)?.toDouble() ?? 0.0;
      final itemId = row['item_id'] as int?;
      final createdAtStr = row['created_at'] as String;
      final createdAt = DateTime.tryParse(createdAtStr) ?? now;
      final dayKey = DateTime(createdAt.year, createdAt.month, createdAt.day);

      if (type == 'cash_sale' || type == 'credit_sale') {
        totalSales += amount;
        dailySalesMap[dayKey] = (dailySalesMap[dayKey] ?? 0.0) + amount;

        if (type == 'credit_sale') {
          creditGiven += amount;
        }

        if (itemId != null) {
          itemSalesMap[itemId] = (itemSalesMap[itemId] ?? 0.0) + amount;
          itemQtyMap[itemId] = (itemQtyMap[itemId] ?? 0.0) + qty;

          final item = itemMap[itemId];
          if (item != null) {
            totalCostOfGoods += qty * item.costPrice;
          }
        }
      } else if (type == 'expense') {
        totalExpenses += amount;
      }
    }

    final estimatedProfit = totalSales - totalCostOfGoods - totalExpenses;

    // Total credit due (all-time)
    final custRows = await db.rawQuery('SELECT SUM(balance_due) as total_due FROM customer WHERE balance_due > 0');
    final totalCreditDue = custRows.isNotEmpty ? ((custRows.first['total_due'] as num?)?.toDouble() ?? 0.0) : 0.0;

    // Daily Sales Points for Bar Chart
    final dailySalesPoints = <DailySalesPoint>[];
    for (int i = 0; i < dayCount; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      final amt = dailySalesMap[dateKey] ?? 0.0;
      final label = period == DashboardPeriod.today
          ? 'Today'
          : '${date.day}/${date.month}';
      dailySalesPoints.add(DailySalesPoint(date: dateKey, label: label, amount: amt));
    }

    // Top 5 items
    final allItemMetrics = items.map((it) {
      return ItemSalesMetric(
        itemId: it.id!,
        itemName: it.nameEn ?? it.nameTe,
        nameTe: it.nameTe,
        amount: itemSalesMap[it.id!] ?? 0.0,
        qty: itemQtyMap[it.id!] ?? 0.0,
        unit: it.unit,
        currentStock: it.currentStock,
      );
    }).toList();

    allItemMetrics.sort((a, b) => b.amount.compareTo(a.amount));
    final top5Items = allItemMetrics.take(5).toList();

    // Slowest 5 items (lowest amount/qty)
    final slowestItems = List<ItemSalesMetric>.from(allItemMetrics);
    slowestItems.sort((a, b) => a.amount.compareTo(b.amount));
    final slowest5Items = slowestItems.take(5).toList();

    // Top 5 customers by balance_due
    final customersDueRows = await db.query(
      'customer',
      where: 'balance_due > 0',
      orderBy: 'balance_due DESC',
      limit: 5,
    );
    final top5CustomersDue = customersDueRows.map((r) {
      return CustomerDueMetric(
        customerId: r['id'] as int,
        name: r['name'] as String,
        balanceDue: (r['balance_due'] as num?)?.toDouble() ?? 0.0,
        phone: r['phone'] as String?,
      );
    }).toList();

    // Items with days_left <= 3
    final evaluations = await checkAndTriggerLowStockAlerts();
    final lowStockItems = evaluations.where((e) {
      if (e.result.daysLeft == null) return e.result.isRed;
      return e.result.daysLeft! <= 3.0;
    }).toList();

    return DashboardData(
      period: period,
      totalSales: totalSales,
      totalExpenses: totalExpenses,
      estimatedProfit: estimatedProfit,
      creditGiven: creditGiven,
      totalCreditDue: totalCreditDue,
      dailySalesPoints: dailySalesPoints,
      top5Items: top5Items,
      slowest5Items: slowest5Items,
      top5CustomersDue: top5CustomersDue,
      lowStockItems: lowStockItems,
      hasData: totalSales > 0 || totalExpenses > 0,
    );
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
