import 'package:flutter/material.dart';
import 'analytics.dart';
import 'local_db.dart';
import 'models.dart';

class KiranaProvider extends ChangeNotifier {
  final LocalDb _db = LocalDb.instance;

  List<Item> _items = [];
  List<Customer> _customers = [];
  List<Txn> _recentTxns = [];
  List<StockItemEvaluation> _stockEvaluations = [];
  List<Item> _redItems = [];
  List<Item> _recountItems = [];
  DashboardPeriod _activePeriod = DashboardPeriod.days7;
  DashboardData _dashboardData = DashboardData.empty(DashboardPeriod.days7);

  bool _isLoading = false;

  List<Item> get items => _items;
  List<Customer> get customers => _customers;
  List<Txn> get recentTxns => _recentTxns;
  List<StockItemEvaluation> get stockEvaluations => _stockEvaluations;
  List<Item> get redItems => _redItems;
  List<Item> get recountItems => _recountItems;
  DashboardPeriod get activePeriod => _activePeriod;
  DashboardData get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _db.getAllItems();
      _customers = await _db.getCustomersWithBalance();
      _recentTxns = await _db.getRecentTxns(limit: 10);
      _stockEvaluations = await _db.checkAndTriggerLowStockAlerts();
      _redItems = _stockEvaluations.where((e) => e.result.isRed).map((e) => e.item).toList();
      _recountItems = await _db.getItemsNeedingWeeklyRecount(limit: 3);
      _dashboardData = await _db.getDashboardData(_activePeriod);
    } catch (e) {
      debugPrint('Error loading Kirana data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setPeriod(DashboardPeriod period) async {
    _activePeriod = period;
    notifyListeners();
    _dashboardData = await _db.getDashboardData(_activePeriod);
    notifyListeners();
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

  Future<void> updateItem(Item item) async {
    await _db.updateItem(item);
    await loadData();
  }

  Future<void> confirmRecount(int itemId) async {
    await _db.confirmRecountOk(itemId);
    _recountItems = await _db.getItemsNeedingWeeklyRecount(limit: 3);
    notifyListeners();
  }

  Future<void> editRecount(int itemId, double newQty) async {
    await _db.editStockRecount(itemId, newQty);
    await loadData();
  }

  Future<void> markAlertsSeen() async {
    await _db.markAlertsSeen();
  }

  Future<void> generateDemoData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _db.generateDemoData();
      await loadData();
    } catch (e) {
      debugPrint('Error generating demo data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetAllData() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _db.resetAllData();
      await loadData();
    } catch (e) {
      debugPrint('Error resetting data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
