import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/kirana_provider.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KiranaProvider>();
    final customers = provider.customers;
    final totalUdhar = customers.fold<double>(
      0.0,
      (sum, c) => sum + (c.balanceDue > 0 ? c.balanceDue : 0),
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadData(),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Summary card
              Card(
                color: Colors.amber.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.amber.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Udhar (మొత్తం బాకీ)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${customers.where((c) => c.balanceDue > 0).length} customers due',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      Text(
                        '₹${totalUdhar.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Customer Ledger (ఖాతాదారుల జాబితా)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              if (provider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (customers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Text(
                    'No customers recorded yet.\nRecord a credit sale or payment on Home tab!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: customers.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    final isDue = customer.balanceDue > 0;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: isDue ? Colors.red.shade100 : Colors.teal.shade100,
                        child: Text(
                          customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDue ? Colors.red.shade900 : Colors.teal.shade900,
                          ),
                        ),
                      ),
                      title: Text(
                        customer.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: customer.phone != null && customer.phone!.isNotEmpty
                          ? Text(customer.phone!)
                          : null,
                      trailing: Text(
                        '₹${customer.balanceDue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDue ? Colors.red.shade700 : Colors.grey.shade700,
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
