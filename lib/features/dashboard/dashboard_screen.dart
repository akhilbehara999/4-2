import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../data/analytics.dart';
import '../../data/kirana_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KiranaProvider>();
    final data = provider.dashboardData;
    final activePeriod = provider.activePeriod;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadData(),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Period Toggle (SegmentedButton)
              Center(
                child: SegmentedButton<DashboardPeriod>(
                  segments: const [
                    ButtonSegment(
                      value: DashboardPeriod.today,
                      label: Text(AppStrings.periodToday, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    ButtonSegment(
                      value: DashboardPeriod.days7,
                      label: Text(AppStrings.period7Days, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    ButtonSegment(
                      value: DashboardPeriod.days30,
                      label: Text(AppStrings.period30Days, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ],
                  selected: {activePeriod},
                  onSelectionChanged: (Set<DashboardPeriod> newSelection) {
                    provider.setPeriod(newSelection.first);
                  },
                ),
              ),
              const SizedBox(height: 18),

              if (provider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (!data.hasData)
                Container(
                  padding: const EdgeInsets.all(40),
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.noDataYet,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Record sales or generate 30 days demo data in Settings to see analytics!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              else ...[
                // 1. Summary Cards Grid
                _SummaryCardsGrid(data: data),
                const SizedBox(height: 24),

                // 2. Daily Sales Bar Chart
                _DailySalesChartCard(points: data.dailySalesPoints),
                const SizedBox(height: 24),

                // 3. Top 5 Items Bar Chart
                if (data.top5Items.isNotEmpty) ...[
                  _TopItemsChartCard(items: data.top5Items),
                  const SizedBox(height: 24),
                ],

                // 4. Slowest 5 Items List
                if (data.slowest5Items.isNotEmpty) ...[
                  _SlowItemsCard(items: data.slowest5Items),
                  const SizedBox(height: 24),
                ],

                // 5. Top 5 Customers by Balance Due
                if (data.top5CustomersDue.isNotEmpty) ...[
                  _TopCustomersDueCard(customers: data.top5CustomersDue),
                  const SizedBox(height: 24),
                ],

                // 6. Items with days_left <= 3
                if (data.lowStockItems.isNotEmpty) ...[
                  _LowStockListCard(items: data.lowStockItems),
                  const SizedBox(height: 16),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCardsGrid extends StatelessWidget {
  final DashboardData data;

  const _SummaryCardsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: AppStrings.sales,
                amount: '₹${data.totalSales.toStringAsFixed(0)}',
                color: const Color(0xFF0B6E5F),
                icon: Icons.payments_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: AppStrings.expenses,
                amount: '₹${data.totalExpenses.toStringAsFixed(0)}',
                color: Colors.red.shade700,
                icon: Icons.receipt_long_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: AppStrings.estimatedProfit,
                amount: '₹${data.estimatedProfit.toStringAsFixed(0)}',
                color: Colors.green.shade800,
                icon: Icons.trending_up,
                subtitle: AppStrings.estimateNote,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: AppStrings.creditGiven,
                amount: '₹${data.creditGiven.toStringAsFixed(0)}',
                color: Colors.orange.shade800,
                icon: Icons.book_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _MetricCard(
          title: AppStrings.totalCreditDue,
          amount: '₹${data.totalCreditDue.toStringAsFixed(0)}',
          color: Colors.amber.shade900,
          icon: Icons.account_balance_wallet_outlined,
          subtitle: 'All-time total balance due across all customers',
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;
  final String? subtitle;

  const _MetricCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withAlpha(50)),
      ),
      color: color.withAlpha(15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatChartAxis(double val) {
  if (val <= 0) return '';
  if (val < 1000) {
    return '₹${val.toInt()}';
  } else if (val < 10000 && val % 1000 != 0) {
    return '₹${(val / 1000).toStringAsFixed(1)}k';
  } else {
    return '₹${(val / 1000).toInt()}k';
  }
}

class _DailySalesChartCard extends StatelessWidget {
  final List<DailySalesPoint> points;

  const _DailySalesChartCard({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final maxVal = points.fold<double>(0.0, (m, p) => p.amount > m ? p.amount : m);
    final maxY = maxVal > 0 ? (maxVal * 1.2) : 100.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Sales Trend (రోజువారీ అమ్మకాలు)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final p = points[group.x.toInt()];
                        return BarTooltipItem(
                          '${p.label}\n₹${p.amount.toStringAsFixed(0)}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (val, meta) {
                          if (val == 0) return const SizedBox.shrink();
                          return Text(
                            _formatChartAxis(val),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < points.length) {
                            if (points.length > 10 && idx % 4 != 0) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                points[idx].label,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: points.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final p = entry.value;
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: p.amount,
                          color: const Color(0xFF0B6E5F),
                          width: points.length > 10 ? 8 : 18,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopItemsChartCard extends StatelessWidget {
  final List<ItemSalesMetric> items;

  const _TopItemsChartCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final maxVal = items.fold<double>(0.0, (m, it) => it.amount > m ? it.amount : m);
    final maxY = maxVal > 0 ? (maxVal * 1.25) : 100.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.topSellingItems,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final it = items[group.x.toInt()];
                        return BarTooltipItem(
                          '${it.itemName}\n₹${it.amount.toStringAsFixed(0)}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (val, meta) {
                          if (val == 0) return const SizedBox.shrink();
                          return Text(
                            _formatChartAxis(val),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < items.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                items[idx].itemName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final it = entry.value;
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: it.amount,
                          color: Colors.teal.shade700,
                          width: 22,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlowItemsCard extends StatelessWidget {
  final List<ItemSalesMetric> items;

  const _SlowItemsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.slowMovingItems,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final it = items[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    '${it.itemName} (${it.nameTe})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text('Current Stock: ${it.currentStock.toStringAsFixed(0)} ${it.unit}'),
                  trailing: Text(
                    '₹${it.amount.toStringAsFixed(0)} sold',
                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TopCustomersDueCard extends StatelessWidget {
  final List<CustomerDueMetric> customers;

  const _TopCustomersDueCard({required this.customers});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.topDueCustomers,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: customers.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = customers[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.amber.shade100,
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                      style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: c.phone != null ? Text(c.phone!) : null,
                  trailing: Text(
                    '₹${c.balanceDue.toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LowStockListCard extends StatelessWidget {
  final List<StockItemEvaluation> items;

  const _LowStockListCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.red.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade900),
                const SizedBox(width: 8),
                Text(
                  AppStrings.lowStockItems,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final eval = items[index];
                final it = eval.item;
                final res = eval.result;
                final daysText = res.daysLeft != null
                    ? '${res.daysLeft!.toStringAsFixed(1)} days left'
                    : 'Out of stock';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    '${it.nameEn ?? ''} (${it.nameTe})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text('Stock: ${it.currentStock.toStringAsFixed(0)} ${it.unit}'),
                  trailing: Text(
                    daysText,
                    style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
