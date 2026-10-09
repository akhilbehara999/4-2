import 'package:flutter/material.dart';
import 'local_db.dart';
import 'models.dart';

class KiranaProvider extends ChangeNotifier {
  final LocalDb _db = LocalDb.instance;

  List<Item> _items = [];
  List<Customer> _customers = [];
  List<Txn> _recentTxns = [];
  bool _isLoading = false;

  List<Item> get items => _items;
  List<Customer> get customers => _customers;
  List<Txn> get recentTxns => _recentTxns;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _db.getAllItems();
      _customers = await _db.getCustomersWithBalance();
      _recentTxns = await _db.getRecentTxns(limit: 10);
    } catch (e) {
      debugPrint('Error loading Kirana data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> saveEntry({
    required String type,
    String? customerName,
    int? itemId,
    double? qty,
    double? amount,
    required String rawText,
  }) async {
    final id = await _db.saveTransaction(
      type: type,
      customerName: customerName,
      itemId: itemId,
      qty: qty,
      amount: amount,
      rawText: rawText,
    );
    await loadData();
    return id;
  }
}
