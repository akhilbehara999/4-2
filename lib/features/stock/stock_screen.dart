import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/kirana_provider.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KiranaProvider>();
    final items = provider.items;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadData(),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'Inventory Stock (సరుకుల నిల్వ)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Showing ${items.length} items',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 14),

              if (provider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Text(
                    'No items found in stock.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isLowStock = item.currentStock <= 5;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      leading: CircleAvatar(
                        backgroundColor: isLowStock ? Colors.orange.shade100 : const Color(0xFFE0F2F1),
                        child: Icon(
                          Icons.inventory_2,
                          color: isLowStock ? Colors.orange.shade900 : const Color(0xFF0B6E5F),
                        ),
                      ),
                      title: Text(
                        '${item.nameEn ?? ''} (${item.nameTe})',
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Price: ₹${item.sellPrice.toStringAsFixed(0)} / ${item.unit}',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item.currentStock.toStringAsFixed(item.currentStock.truncateToDouble() == item.currentStock ? 0 : 1)} ${item.unit}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isLowStock ? Colors.red.shade700 : const Color(0xFF0B6E5F),
                            ),
                          ),
                          if (isLowStock)
                            Text(
                              'Low stock',
                              style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                            ),
                        ],
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
