import 'models.dart';
import 'stock_engine.dart';

enum DashboardPeriod {
  today,
  days7,
  days30,
}

class DailySalesPoint {
  final DateTime date;
  final String label;
  final double amount;

  DailySalesPoint({
    required this.date,
    required this.label,
    required this.amount,
  });
}

class ItemSalesMetric {
  final int itemId;
  final String itemName;
  final String nameTe;
  final double amount;
  final double qty;
  final String unit;
  final double currentStock;

  ItemSalesMetric({
    required this.itemId,
    required this.itemName,
    required this.nameTe,
    required this.amount,
    required this.qty,
    required this.unit,
    required this.currentStock,
  });
}

class CustomerDueMetric {
  final int customerId;
  final String name;
  final double balanceDue;
  final String? phone;

  CustomerDueMetric({
    required this.customerId,
    required this.name,
    required this.balanceDue,
    this.phone,
  });
}

class StockItemEvaluation {
  final Item item;
  final StockEngineResult result;

  StockItemEvaluation({
    required this.item,
    required this.result,
  });
}

class DashboardData {
  final DashboardPeriod period;
  final double totalSales;
  final double totalExpenses;
  final double estimatedProfit;
  final double creditGiven;
  final double totalCreditDue;
  final List<DailySalesPoint> dailySalesPoints;
  final List<ItemSalesMetric> top5Items;
  final List<ItemSalesMetric> slowest5Items;
  final List<CustomerDueMetric> top5CustomersDue;
  final List<StockItemEvaluation> lowStockItems;
  final bool hasData;

  DashboardData({
    required this.period,
    required this.totalSales,
    required this.totalExpenses,
    required this.estimatedProfit,
    required this.creditGiven,
    required this.totalCreditDue,
    required this.dailySalesPoints,
    required this.top5Items,
    required this.slowest5Items,
    required this.top5CustomersDue,
    required this.lowStockItems,
    required this.hasData,
  });

  factory DashboardData.empty(DashboardPeriod period) {
    return DashboardData(
      period: period,
      totalSales: 0.0,
      totalExpenses: 0.0,
      estimatedProfit: 0.0,
      creditGiven: 0.0,
      totalCreditDue: 0.0,
      dailySalesPoints: [],
      top5Items: [],
      slowest5Items: [],
      top5CustomersDue: [],
      lowStockItems: [],
      hasData: false,
    );
  }
}
