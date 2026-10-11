import '../database/database_service.dart';

class TransactionRepository {
  final DatabaseService _dbService = DatabaseService();

  Future<void> seedInitialDataIfEmpty() async {
    final db = await _dbService.database;

    final countResult = await db.rawQuery('SELECT COUNT(*) as cnt FROM txn');
    final count = (countResult.first['cnt'] as int?) ?? 0;

    if (count > 0) return;

    // Seed sample Items
    final riceId = await db.insert('item', {
      'name_te': 'బియ్యం',
      'name_en': 'Rice',
      'unit': 'kg',
      'current_stock': 45.0,
      'alert_days': 2,
      'cost_price': 45.0,
      'sell_price': 60.0,
    });

    final sugarId = await db.insert('item', {
      'name_te': 'చక్కెర',
      'name_en': 'Sugar',
      'unit': 'kg',
      'current_stock': 28.0,
      'alert_days': 3,
      'cost_price': 42.0,
      'sell_price': 60.0,
    });

    // Seed sample Customers
    final rameshId = await db.insert('customer', {
      'name': 'Ramesh (రామేష్)',
      'phone': '9848012345',
      'balance_due': 300.0,
    });

    final lakshmiId = await db.insert('customer', {
      'name': 'Lakshmi (లక్ష్మి)',
      'phone': '9848054321',
      'balance_due': 0.0,
    });

    final now = DateTime.now().toIso8601String();

    // Seed 4 sample transactions matching LOG Home Screen mockup
    // 1. Credit: Ramesh · Rice (5 kg) - ₹300
    await db.insert('txn', {
      'type': 'credit_sale',
      'item_id': riceId,
      'customer_id': rameshId,
      'qty': 5.0,
      'amount': 300.0,
      'raw_text': 'రామేష్‌కి 5 కిలోల బియ్యం అప్పు',
      'created_at': now,
      'synced': 0,
    });

    // 2. Cash: Sugar (2 kg) - ₹120
    await db.insert('txn', {
      'type': 'cash_sale',
      'item_id': sugarId,
      'customer_id': null,
      'qty': 2.0,
      'amount': 120.0,
      'raw_text': 'రెండు కిలోల చక్కెర అమ్మాను',
      'created_at': now,
      'synced': 0,
    });

    // 3. Payment Received: Lakshmi - ₹500
    await db.insert('txn', {
      'type': 'payment_received',
      'item_id': null,
      'customer_id': lakshmiId,
      'qty': null,
      'amount': 500.0,
      'raw_text': 'లక్ష్మి ఐదు వందలు ఇచ్చింది',
      'created_at': now,
      'synced': 0,
    });

    // 4. Expense: Electricity - ₹80
    await db.insert('txn', {
      'type': 'expense',
      'item_id': null,
      'customer_id': null,
      'qty': null,
      'amount': 80.0,
      'raw_text': 'కరెంటు బిల్లు ఎనభై',
      'created_at': now,
      'synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 10}) async {
    await seedInitialDataIfEmpty();
    final db = await _dbService.database;

    final results = await db.rawQuery('''
      SELECT 
        t.id,
        t.type,
        t.qty,
        t.amount,
        t.raw_text,
        t.created_at,
        i.name_en AS item_name_en,
        i.name_te AS item_name_te,
        i.unit AS item_unit,
        c.name AS customer_name
      FROM txn t
      LEFT JOIN item i ON t.item_id = i.id
      LEFT JOIN customer c ON t.customer_id = c.id
      ORDER BY t.id DESC
      LIMIT ?
    ''', [limit]);

    return results;
  }

  Future<Map<String, double>> getTodaySplit() async {
    await seedInitialDataIfEmpty();
    // Default values matching PRD / mockup sample
    return {
      'credit': 1200.0,
      'expenditure': 680.0,
      'profit': 2940.0,
      'totalSales': 4820.0,
    };
  }

  Future<List<double>> getWeeklyRevenue() async {
    await seedInitialDataIfEmpty();
    // 7 days revenue (Sun - Sat) matching PRD / mockup sample
    return [3600.0, 3200.0, 4100.0, 3800.0, 4700.0, 4300.0, 4820.0];
  }
}
