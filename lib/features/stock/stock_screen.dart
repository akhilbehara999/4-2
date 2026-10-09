import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../data/analytics.dart';
import '../../data/kirana_provider.dart';
import '../../data/models.dart';
import '../../data/stock_engine.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  Color _getStatusColor(StockColorStatus status) {
    switch (status) {
      case StockColorStatus.red:
        return Colors.red.shade700;
      case StockColorStatus.amber:
        return Colors.orange.shade800;
      case StockColorStatus.green:
        return const Color(0xFF0B6E5F);
      case StockColorStatus.grey:
        return Colors.grey.shade500;
    }
  }

  String _formatDaysLeft(StockEngineResult result) {
    if (result.isRed && (result.daysLeft == 0 || result.daysLeft == null)) {
      return AppStrings.outOfStock;
    }
    if (result.daysLeft != null) {
      final daysInt = result.daysLeft!.toStringAsFixed(1);
      return '$daysInt ${AppStrings.daysLeft}';
    }
    if (result.message == 'not enough data') {
      return AppStrings.notEnoughData;
    }
    return AppStrings.noRecentSales;
  }

  void _showEditItemDialog(BuildContext context, Item item) {
    final alertDaysController = TextEditingController(text: item.alertDays.toString());
    final costPriceController = TextEditingController(text: item.costPrice.toStringAsFixed(0));
    final sellPriceController = TextEditingController(text: item.sellPrice.toStringAsFixed(0));
    final currentStockController = TextEditingController(
      text: item.currentStock.truncateToDouble() == item.currentStock
          ? item.currentStock.toInt().toString()
          : item.currentStock.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text(
            '${AppStrings.editItem}\n${item.nameEn ?? ''} (${item.nameTe})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentStockController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Current Stock (${item.unit})',
                    hintText: 'Enter stock',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: alertDaysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Alert Days (హెచ్చరిక రోజులు)',
                    hintText: 'Default 2',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: costPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Cost Price ₹ (కొనుగోలు ధర)',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sellPriceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Sell Price ₹ (అమ్మకపు ధర)',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6E5F),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final newStock = double.tryParse(currentStockController.text.trim()) ?? item.currentStock;
                final newAlert = int.tryParse(alertDaysController.text.trim()) ?? item.alertDays;
                final newCost = double.tryParse(costPriceController.text.trim()) ?? item.costPrice;
                final newSell = double.tryParse(sellPriceController.text.trim()) ?? item.sellPrice;

                final updated = Item(
                  id: item.id,
                  nameTe: item.nameTe,
                  nameEn: item.nameEn,
                  unit: item.unit,
                  currentStock: newStock,
                  alertDays: newAlert,
                  costPrice: newCost,
                  sellPrice: newSell,
                );

                await context.read<KiranaProvider>().updateItem(updated);
                if (context.mounted) {
                  Navigator.of(dialogCtx).pop();
                }
              },
              child: const Text(AppStrings.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KiranaProvider>();
    final evaluations = List<StockItemEvaluation>.from(provider.stockEvaluations);

    // Sort red items first, then amber, then green, then grey
    evaluations.sort((a, b) {
      final order = {
        StockColorStatus.red: 0,
        StockColorStatus.amber: 1,
        StockColorStatus.green: 2,
        StockColorStatus.grey: 3,
      };
      final oA = order[a.result.status] ?? 3;
      final oB = order[b.result.status] ?? 3;
      if (oA != oB) return oA.compareTo(oB);
      // Secondary sort: days left ascending
      final dlA = a.result.daysLeft ?? 999.0;
      final dlB = b.result.daysLeft ?? 999.0;
      return dlA.compareTo(dlB);
    });

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadData(),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Inventory Stock (సరుకుల నిల్వ)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tap to edit',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Showing ${evaluations.length} items · Red items sorted first',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),

              if (provider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (evaluations.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Text(
                    AppStrings.noDataYet,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: evaluations.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final eval = evaluations[index];
                    final item = eval.item;
                    final result = eval.result;
                    final statusColor = _getStatusColor(result.status);

                    // Compute progress value for bar (0.0 to 1.0)
                    double progressVal = 0.5;
                    if (result.daysLeft != null) {
                      final maxDays = (item.alertDays + 4).toDouble();
                      progressVal = (result.daysLeft! / maxDays).clamp(0.05, 1.0);
                    } else if (result.status == StockColorStatus.red) {
                      progressVal = 0.05;
                    }

                    return InkWell(
                      onTap: () => _showEditItemDialog(context, item),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: statusColor.withAlpha(35),
                                  child: Icon(Icons.inventory_2, color: statusColor, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.nameEn ?? ''} (${item.nameTe})',
                                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatDaysLeft(result),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${item.currentStock.toStringAsFixed(item.currentStock.truncateToDouble() == item.currentStock ? 0 : 1)} ${item.unit}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: statusColor,
                                      ),
                                    ),
                                    Text(
                                      '₹${item.sellPrice.toStringAsFixed(0)} / ${item.unit}',
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Colored progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressVal,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
