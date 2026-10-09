import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../data/kirana_provider.dart';
import '../../data/models.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KiranaProvider>();
    final allCustomers = provider.customers;
    final totalUdhar = allCustomers.fold<double>(
      0.0,
      (sum, c) => sum + (c.balanceDue > 0 ? c.balanceDue : 0),
    );

    final filteredCustomers = _filterQuery.isEmpty
        ? allCustomers
        : allCustomers.where((c) {
            final query = _filterQuery.toLowerCase();
            return c.name.toLowerCase().contains(query) ||
                (c.phone != null && c.phone!.contains(query));
          }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _showAddEntryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Record · నమోదు'),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
      ),
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
                            '${allCustomers.where((c) => c.balanceDue > 0).length} customers due',
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

              // Search & Autocomplete Bar
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  final query = textEditingValue.text.toLowerCase();
                  return allCustomers
                      .where((c) => c.name.toLowerCase().contains(query))
                      .map((c) => c.name);
                },
                onSelected: (String selection) {
                  setState(() {
                    _filterQuery = selection;
                    _searchController.text = selection;
                  });
                  final match = allCustomers.where((c) => c.name == selection).firstOrNull;
                  if (match != null) {
                    _showCustomerHistorySheet(context, match);
                  }
                },
                fieldViewBuilder: (context, fieldTextEditingController, focusNode, onFieldSubmitted) {
                  return TextField(
                    controller: fieldTextEditingController,
                    focusNode: focusNode,
                    onChanged: (val) {
                      setState(() {
                        _filterQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search customer · ఖాతాదారుడిని వెతకండి',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _filterQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                fieldTextEditingController.clear();
                                setState(() {
                                  _filterQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  );
                },
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
              else if (allCustomers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Text(
                    'No customers recorded yet.\nRecord a credit sale or payment on Home tab!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                )
              else if (filteredCustomers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Text(
                    'No customers found matching "$_filterQuery"',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredCustomers.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];
                    final isDue = customer.balanceDue > 0;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      onTap: () => _showCustomerHistorySheet(context, customer),
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
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      subtitle: customer.phone != null && customer.phone!.isNotEmpty
                          ? Text(customer.phone!)
                          : Text(
                              'Tap to view history · చరిత్ర చూడండి',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${customer.balanceDue.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDue ? Colors.red.shade700 : Colors.teal.shade700,
                                ),
                              ),
                              Text(
                                isDue ? 'Due · బాకీ' : 'Settled · తీరింది',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDue ? Colors.red.shade600 : Colors.teal.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          if (isDue)
                            FilledButton.tonal(
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: Colors.teal.shade50,
                                foregroundColor: Colors.teal.shade800,
                              ),
                              onPressed: () => _showMarkPaidDialog(context, customer),
                              child: const Text('Mark Paid\nజమ', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, height: 1.1)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  void _showMarkPaidDialog(BuildContext context, Customer customer) {
    final provider = context.read<KiranaProvider>();
    final amountController = TextEditingController(
      text: customer.balanceDue % 1 == 0
          ? customer.balanceDue.toInt().toString()
          : customer.balanceDue.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final due = customer.balanceDue;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal.shade100,
                  child: Icon(Icons.check_circle, color: Colors.teal.shade800),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mark Paid · బాకీ జమ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(customer.name, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Current Balance Due:', style: TextStyle(fontWeight: FontWeight.w500)),
                        Text('₹${due.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade800)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Payment Amount (జమ మొత్తం):', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Quick Preset Chips
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        label: Text('Full: ₹${due.toStringAsFixed(0)}'),
                        onPressed: () {
                          amountController.text = due % 1 == 0 ? due.toInt().toString() : due.toString();
                        },
                      ),
                      if (due > 100)
                        ActionChip(
                          label: const Text('₹100'),
                          onPressed: () => amountController.text = '100',
                        ),
                      if (due > 500)
                        ActionChip(
                          label: const Text('₹500'),
                          onPressed: () => amountController.text = '500',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text(AppStrings.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.teal.shade700),
                onPressed: () async {
                  final entered = double.tryParse(amountController.text.trim());
                  if (entered == null || entered <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid amount')),
                    );
                    return;
                  }
                  Navigator.of(dialogCtx).pop();
                  await provider.saveEntry(
                    type: 'payment_received',
                    customerName: customer.name,
                    amount: entered,
                    rawText: 'Mark paid / వసూలు: ₹$entered',
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Marked ₹${entered.toStringAsFixed(0)} paid for ${customer.name} (జమ నమోదు చేయబడింది)'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  }
                },
                child: const Text('Save Payment · జమ చేయి'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCustomerHistorySheet(BuildContext context, Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return _CustomerHistorySheet(customer: customer);
      },
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    final provider = context.read<KiranaProvider>();
    final customers = provider.customers;
    final items = provider.items;

    String selectedType = 'credit_sale'; // or 'payment_received'
    final customerController = TextEditingController();
    final amountController = TextEditingController();
    int? selectedItemId = items.isNotEmpty ? items.first.id : null;
    final qtyController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Record Udhar / Payment\nనమోదు చేయండి', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type selection
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'credit_sale',
                        label: Text('Credit (అప్పు)', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.arrow_upward, size: 16),
                      ),
                      ButtonSegment(
                        value: 'payment_received',
                        label: Text('Paid (జమ)', style: TextStyle(fontSize: 12)),
                        icon: Icon(Icons.arrow_downward, size: 16),
                      ),
                    ],
                    selected: {selectedType},
                    onSelectionChanged: (val) {
                      setModalState(() {
                        selectedType = val.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Customer name with autocomplete
                  const Text('Customer Name (ఖాతాదారుడు):', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return customers.map((c) => c.name);
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return customers
                          .where((c) => c.name.toLowerCase().contains(query))
                          .map((c) => c.name);
                    },
                    onSelected: (String selection) {
                      customerController.text = selection;
                    },
                    fieldViewBuilder: (ctx, textController, focusNode, onEditingComplete) {
                      // Keep sync
                      textController.addListener(() {
                        if (customerController.text != textController.text) {
                          customerController.text = textController.text;
                        }
                      });
                      return TextField(
                        controller: textController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          hintText: 'Type or choose customer...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  const Text('Amount (మొత్తం ₹):', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),

                  if (selectedType == 'credit_sale') ...[
                    const SizedBox(height: 16),
                    const Text('Item (సరుకు - ఐచ్ఛికం):', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      initialValue: selectedItemId,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('General / Other (సాధారణ)'),
                        ),
                        ...items.map((i) => DropdownMenuItem<int>(
                              value: i.id,
                              child: Text('${i.nameEn ?? i.nameTe} (${i.unit})'),
                            )),
                      ],
                      onChanged: (val) {
                        setModalState(() {
                          selectedItemId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Quantity (పరిమాణం):', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: qtyController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text(AppStrings.cancel),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: selectedType == 'credit_sale' ? Colors.amber.shade800 : Colors.teal.shade700,
                ),
                onPressed: () async {
                  final custName = customerController.text.trim();
                  final amount = double.tryParse(amountController.text.trim());
                  final qty = double.tryParse(qtyController.text.trim());

                  if (custName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter customer name')),
                    );
                    return;
                  }
                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid amount')),
                    );
                    return;
                  }

                  Navigator.of(dialogCtx).pop();
                  await provider.saveEntry(
                    type: selectedType,
                    customerName: custName,
                    amount: amount,
                    itemId: selectedType == 'credit_sale' ? selectedItemId : null,
                    qty: selectedType == 'credit_sale' ? (qty ?? 1.0) : null,
                    rawText: selectedType == 'credit_sale' ? 'Udhar credit sale: ₹$amount' : 'Udhar payment: ₹$amount',
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Entry saved successfully for $custName'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  }
                },
                child: const Text('Save · నమోదు చేయి'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CustomerHistorySheet extends StatefulWidget {
  final Customer customer;

  const _CustomerHistorySheet({required this.customer});

  @override
  State<_CustomerHistorySheet> createState() => _CustomerHistorySheetState();
}

class _CustomerHistorySheetState extends State<_CustomerHistorySheet> {
  late Future<List<Txn>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final provider = context.read<KiranaProvider>();
    if (widget.customer.id != null) {
      _historyFuture = provider.getCustomerTransactions(widget.customer.id!);
    } else {
      _historyFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KiranaProvider>();
    final currentCustomer = provider.customers.firstWhere(
      (c) => c.id == widget.customer.id || c.name == widget.customer.name,
      orElse: () => widget.customer,
    );
    final isDue = currentCustomer.balanceDue > 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Customer Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isDue ? Colors.red.shade100 : Colors.teal.shade100,
                    child: Text(
                      currentCustomer.name.isNotEmpty ? currentCustomer.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDue ? Colors.red.shade900 : Colors.teal.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentCustomer.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        if (currentCustomer.phone != null && currentCustomer.phone!.isNotEmpty)
                          Text(currentCustomer.phone!, style: TextStyle(color: Colors.grey.shade600))
                        else
                          Text('Customer Account', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${currentCustomer.balanceDue.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDue ? Colors.red.shade700 : Colors.teal.shade700,
                        ),
                      ),
                      Text(
                        isDue ? 'Balance Due' : 'Settled',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mark Paid action bar if balance > 0
              if (isDue)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      _showQuickMarkPaid(context, currentCustomer);
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark Paid · బాకీ జమ చేయండి', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),

              const Divider(),
              Text(
                'Transaction History (లావాదేవీల చరిత్ర)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),

              // History list
              Expanded(
                child: FutureBuilder<List<Txn>>(
                  future: _historyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == connectionStateWaiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading history: ${snapshot.error}'));
                    }
                    final history = snapshot.data ?? [];
                    if (history.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'No transactions recorded for this customer yet.\nఈ ఖాతాదారునికి ఎటువంటి లావాదేవీలు లేవు.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      itemCount: history.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final txn = history[index];
                        final isCredit = txn.type == 'credit_sale';
                        final item = provider.items.where((i) => i.id == txn.itemId).firstOrNull;
                        final qtyStr = txn.qty != null
                            ? (txn.qty! % 1 == 0 ? txn.qty!.toInt().toString() : txn.qty.toString())
                            : '';
                        final itemDesc = item != null
                            ? '${item.nameEn ?? item.nameTe} ($qtyStr ${item.unit})'
                            : (txn.rawText ?? '');

                        final formattedDate = _formatDate(txn.createdAt);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: isCredit ? Colors.amber.shade100 : Colors.teal.shade100,
                            child: Icon(
                              isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                              color: isCredit ? Colors.amber.shade900 : Colors.teal.shade900,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isCredit ? 'Credit Sale · అప్పు' : 'Payment Received · జమ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isCredit ? Colors.amber.shade900 : Colors.teal.shade900,
                                ),
                              ),
                              Text(
                                '${isCredit ? "+" : "-"}₹${txn.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isCredit ? Colors.red.shade700 : Colors.teal.shade700,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (itemDesc.isNotEmpty)
                                Text(itemDesc, style: const TextStyle(fontSize: 14)),
                              Text(
                                formattedDate,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                            tooltip: 'Undo / Delete Entry',
                            onPressed: () => _confirmDeleteTxn(context, txn),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickMarkPaid(BuildContext context, Customer customer) {
    final provider = context.read<KiranaProvider>();
    final amountController = TextEditingController(
      text: customer.balanceDue % 1 == 0
          ? customer.balanceDue.toInt().toString()
          : customer.balanceDue.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Mark Paid · ${customer.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Balance Due: ₹${customer.balanceDue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: '₹ ',
                labelText: 'Amount Paid (జమ మొత్తం)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.teal.shade700),
            onPressed: () async {
              final val = double.tryParse(amountController.text.trim());
              if (val == null || val <= 0) return;
              Navigator.of(dialogCtx).pop();
              await provider.saveEntry(
                type: 'payment_received',
                customerName: customer.name,
                amount: val,
                rawText: 'Mark paid / వసూలు: ₹$val',
              );
              setState(() {
                _loadHistory();
              });
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Marked ₹${val.toStringAsFixed(0)} paid for ${customer.name}'),
                    backgroundColor: Colors.teal,
                  ),
                );
              }
            },
            child: const Text('Save Payment · జమ చేయి'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTxn(BuildContext context, Txn txn) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('రద్దు చేయండి · Undo Entry?'),
        content: const Text(
          'Are you sure you want to delete this entry? Balance will be adjusted accordingly.\n\n(బాకీ వివరాలు సరిదిద్దబడతాయి).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              if (txn.id != null) {
                await context.read<KiranaProvider>().deleteTransaction(txn.id!);
                setState(() {
                  _loadHistory();
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Entry undone and deleted · ఎంట్రీ రద్దు చేయబడింది'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete · రద్దు చేయి'),
          ),
        ],
      ),
    );
  }

  static const ConnectionState connectionStateWaiting = ConnectionState.waiting;

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} $hour:$min $amPm';
    } catch (_) {
      return isoString;
    }
  }
}
