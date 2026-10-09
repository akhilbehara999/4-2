import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/strings.dart';
import '../../data/kirana_provider.dart';
import '../../data/models.dart';
import '../../data/parser.dart';
import 'confirm_screen.dart';
import 'voice_service.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToStock;

  const HomeScreen({
    super.key,
    this.onNavigateToStock,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final VoiceService _voiceService = VoiceService();
  final TextEditingController _typeController = TextEditingController();
  bool _isListening = false;
  bool _handled = false;
  String _partialText = '';
  String _currentLocale = 'te_IN';

  @override
  void initState() {
    super.initState();
    _initVoiceService();
  }

  Future<void> _initVoiceService() async {
    await _voiceService.init();
    if (mounted) {
      setState(() {
        _currentLocale = _voiceService.activeLocaleId;
      });
    }
  }

  @override
  void dispose() {
    _voiceService.stop();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      await _voiceService.stop();
      if (!_handled && _partialText.trim().isNotEmpty) {
        _handled = true;
        _processText(
          _partialText,
          audioPath: 'voice_${DateTime.now().millisecondsSinceEpoch}.wav',
        );
      }
    } else {
      _handled = false;
      setState(() {
        _partialText = '';
        _isListening = true;
      });

      final started = await _voiceService.start(
        onResult: (text, isFinal) {
          if (mounted) {
            setState(() {
              _partialText = text;
              _currentLocale = _voiceService.activeLocaleId;
            });
            if (isFinal && text.trim().isNotEmpty && !_handled) {
              _handled = true;
              setState(() {
                _isListening = false;
              });
              _processText(
                text,
                audioPath: 'voice_${DateTime.now().millisecondsSinceEpoch}.wav',
              );
            }
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
            if (!_handled && _partialText.trim().isNotEmpty) {
              _handled = true;
              _processText(
                _partialText,
                audioPath: 'voice_${DateTime.now().millisecondsSinceEpoch}.wav',
              );
            }
          }
        },
        onError: (err) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
      );

      if (!started && mounted) {
        setState(() {
          _isListening = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Microphone unavailable or permission denied. You can use "Type instead" below.',
              style: TextStyle(fontSize: 16),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _processText(String text, {String? audioPath}) async {
    if (text.trim().isEmpty) return;

    final provider = context.read<KiranaProvider>();
    final parsed = parse(text, provider.items, provider.customers);

    final savedTxnId = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => ConfirmScreen(
          parsedEntry: parsed,
          audioPath: audioPath,
        ),
      ),
    );

    if (savedTxnId is int && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Entry saved! · ఎంట్రీ నమోదైంది',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          backgroundColor: const Color(0xFF0B6E5F),
          action: SnackBarAction(
            label: 'UNDO · రద్దు',
            textColor: Colors.amberAccent,
            onPressed: () async {
              await provider.deleteTransaction(savedTxnId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entry undone and reversed! · ఎంట్రీ రద్దు చేయబడింది!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  void _showRecountEditDialog(BuildContext context, Item item) {
    final qtyController = TextEditingController(
      text: item.currentStock.truncateToDouble() == item.currentStock
          ? item.currentStock.toInt().toString()
          : item.currentStock.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          'Actual Stock: ${item.nameEn ?? ''} (${item.nameTe})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter current physical count in ${item.unit}:'),
            const SizedBox(height: 10),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                suffixText: item.unit,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
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
              final newStock = double.tryParse(qtyController.text.trim());
              if (newStock != null) {
                await context.read<KiranaProvider>().editRecount(item.id!, newStock);
              }
              if (context.mounted) {
                Navigator.of(dialogCtx).pop();
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KiranaProvider>();
    final recentTxns = provider.recentTxns;
    final redItems = provider.redItems;
    final recountItems = provider.recountItems;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              // Tagline
              Text(
                AppStrings.tagline,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              // Locale indicator badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Voice Locale: $_currentLocale (${_currentLocale.startsWith('te') ? 'Telugu' : 'English'})',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // B. Running Low Alert Card
              if (redItems.isNotEmpty) ...[
                Card(
                  color: Colors.red.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.red.shade300, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red.shade800, size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppStrings.runningLow,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                provider.markAlertsSeen();
                                widget.onNavigateToStock?.call();
                              },
                              child: const Text('View Stock →'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: redItems.map((item) {
                            return ActionChip(
                              avatar: const Icon(Icons.error_outline, size: 16, color: Colors.white),
                              backgroundColor: Colors.red.shade700,
                              labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              label: Text('${item.nameEn ?? item.nameTe} (${item.currentStock.toStringAsFixed(0)} ${item.unit})'),
                              onPressed: () {
                                provider.markAlertsSeen();
                                widget.onNavigateToStock?.call();
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // C. Weekly Stock Check Card
              if (recountItems.isNotEmpty) ...[
                Card(
                  color: Colors.amber.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.amber.shade400, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.checklist_rtl_rounded, color: Colors.amber.shade900, size: 26),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.weeklyStockCheck,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...recountItems.map((item) {
                          final countStr = item.currentStock.toStringAsFixed(
                              item.currentStock.truncateToDouble() == item.currentStock ? 0 : 1);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.nameTe} $countStr ${item.unit} ఉన్నాయా? · ${item.nameEn ?? item.nameTe} $countStr ${item.unit} undha?',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        side: BorderSide(color: Colors.grey.shade400),
                                      ),
                                      onPressed: () => _showRecountEditDialog(context, item),
                                      child: const Text(AppStrings.edit),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0B6E5F),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                      onPressed: () => provider.confirmRecount(item.id!),
                                      child: const Text(AppStrings.yes),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Large Mic Button
              Material(
                color: _isListening ? Colors.red.shade600 : theme.colorScheme.primary,
                shape: const CircleBorder(),
                elevation: _isListening ? 12 : 6,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: _toggleListening,
                  child: Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    child: Icon(
                      _isListening ? Icons.mic_off : Icons.mic,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _isListening ? 'Listening... Tap to stop' : 'Tap to speak transaction',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _isListening ? Colors.red.shade700 : theme.colorScheme.onSurface,
                ),
              ),

              // Live partial recognized text display
              if (_partialText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 14),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.shade300),
                  ),
                  child: Text(
                    _partialText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF004D40),
                    ),
                  ),
                ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),

              // "Type instead" section
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _typeController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Type instead (e.g. Ramesh ki 5 kg biyyam udhar 300 rs)',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          if (_isListening) {
                            _voiceService.stop();
                            setState(() => _isListening = false);
                          }
                          _handled = true;
                          _processText(val.trim());
                          _typeController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () {
                      final text = _typeController.text.trim();
                      if (text.isNotEmpty) {
                        if (_isListening) {
                          _voiceService.stop();
                          setState(() => _isListening = false);
                        }
                        _handled = true;
                        _processText(text);
                        _typeController.clear();
                      }
                    },
                    child: const Text('Parse'),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Last 10 entries section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recent Entries (గత 10 లావాదేవీలు)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                )
              else if (recentTxns.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No entries recorded yet.\nTap mic or type above to add sales & udhar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTxns.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final txn = recentTxns[index];
                    return _RecentTxnTile(txn: txn, items: provider.items);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentTxnTile extends StatelessWidget {
  final Txn txn;
  final List<Item> items;

  const _RecentTxnTile({required this.txn, required this.items});

  String _formatType(String type) {
    switch (type) {
      case 'credit_sale':
        return 'Credit Sale (ఉధార్)';
      case 'cash_sale':
        return 'Cash Sale (నగదు)';
      case 'payment_received':
        return 'Payment Received (జమ)';
      case 'restock':
        return 'Restock (స్టాక్)';
      case 'expense':
        return 'Expense (ఖర్చు)';
      default:
        return type;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'credit_sale':
        return Colors.orange.shade800;
      case 'cash_sale':
        return const Color(0xFF0B6E5F);
      case 'payment_received':
        return Colors.blue.shade800;
      case 'restock':
        return Colors.purple.shade700;
      case 'expense':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = items.where((i) => i.id == txn.itemId).firstOrNull;
    final qtyStr = txn.qty != null
        ? (txn.qty! % 1 == 0 ? txn.qty!.toInt().toString() : txn.qty.toString())
        : '';
    final itemDesc = item != null
        ? '${item.nameEn ?? item.nameTe} ($qtyStr ${item.unit})'
        : qtyStr;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      onTap: () => _showTxnOptions(context, txn),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _formatType(txn.type),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _typeColor(txn.type),
              ),
            ),
          ),
          if (txn.amount > 0)
            Text(
              '₹${txn.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (itemDesc.isNotEmpty)
            Text(
              itemDesc,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          if (txn.rawText != null && txn.rawText!.isNotEmpty)
            Text(
              '"${txn.rawText}"',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.grey.shade600, size: 20),
            tooltip: 'Edit / Fix Entry (సరిదిద్దు)',
            onPressed: () => _showEditTxnDialog(context, txn),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
            tooltip: 'Undo / Delete Entry (ఎంట్రీ రద్దు చేయి)',
            onPressed: () => _confirmDeleteTxn(context, txn),
          ),
        ],
      ),
    );
  }

  void _showTxnOptions(BuildContext context, Txn txn) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetCtx) {
        final provider = context.read<KiranaProvider>();
        final item = provider.items.where((i) => i.id == txn.itemId).firstOrNull;
        final customer = provider.customers.where((c) => c.id == txn.customerId).firstOrNull;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatType(txn.type),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _typeColor(txn.type),
                    ),
                  ),
                  Text(
                    '₹${txn.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (item != null) ...[
                const SizedBox(height: 6),
                Text('Item: ${item.nameEn ?? item.nameTe} (${txn.qty ?? 0} ${item.unit})',
                    style: const TextStyle(fontSize: 15)),
              ],
              if (customer != null) ...[
                const SizedBox(height: 4),
                Text('Customer: ${customer.name}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ],
              if (txn.rawText != null && txn.rawText!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Spoken: "${txn.rawText}"',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Undo / Delete\nరద్దు చేయి', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                      onPressed: () {
                        Navigator.of(bottomSheetCtx).pop();
                        _confirmDeleteTxn(context, txn);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFF0B6E5F),
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit / Fix\nసరిదిద్దు', textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                      onPressed: () {
                        Navigator.of(bottomSheetCtx).pop();
                        _showEditTxnDialog(context, txn);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditTxnDialog(BuildContext context, Txn txn) {
    final provider = context.read<KiranaProvider>();
    final items = provider.items;
    final customers = provider.customers;
    final currentCustomer = customers.where((c) => c.id == txn.customerId).firstOrNull;

    String editType = txn.type;
    int? editItemId = txn.itemId;
    final customerCtrl = TextEditingController(text: currentCustomer?.name ?? '');
    final qtyCtrl = TextEditingController(
      text: txn.qty != null
          ? (txn.qty! % 1 == 0 ? txn.qty!.toInt().toString() : txn.qty.toString())
          : '1',
    );
    final amountCtrl = TextEditingController(
      text: txn.amount % 1 == 0 ? txn.amount.toInt().toString() : txn.amount.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Edit / Fix Entry · ఎంట్రీ సరిదిద్దండి', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: editType,
                  decoration: const InputDecoration(
                    labelText: 'Type (రకం)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cash_sale', child: Text('Cash Sale (నగదు అమ్మకం)')),
                    DropdownMenuItem(value: 'credit_sale', child: Text('Credit Sale (అప్పు అమ్మకం)')),
                    DropdownMenuItem(value: 'payment_received', child: Text('Payment Received (జమ)')),
                    DropdownMenuItem(value: 'restock', child: Text('Restock (సరుకు రాక)')),
                    DropdownMenuItem(value: 'expense', child: Text('Expense (ఖర్చు)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() {
                        editType = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (editType == 'credit_sale' || editType == 'payment_received') ...[
                  const Text('Customer (ఖాతాదారుడు):', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: customerCtrl.text),
                    optionsBuilder: (textVal) {
                      if (textVal.text.isEmpty) return customers.map((c) => c.name);
                      return customers
                          .where((c) => c.name.toLowerCase().contains(textVal.text.toLowerCase()))
                          .map((c) => c.name);
                    },
                    onSelected: (val) => customerCtrl.text = val,
                    fieldViewBuilder: (ctx, tCtrl, fNode, _) {
                      tCtrl.addListener(() {
                        if (customerCtrl.text != tCtrl.text) {
                          customerCtrl.text = tCtrl.text;
                        }
                      });
                      return TextField(
                        controller: tCtrl,
                        focusNode: fNode,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                if (editType != 'payment_received' && editType != 'expense') ...[
                  DropdownButtonFormField<int>(
                    initialValue: editItemId,
                    decoration: const InputDecoration(
                      labelText: 'Item (సరుకు)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: [
                      const DropdownMenuItem<int>(value: null, child: Text('None / General')),
                      ...items.map((i) => DropdownMenuItem<int>(
                            value: i.id,
                            child: Text('${i.nameEn ?? i.nameTe} (${i.unit})'),
                          )),
                    ],
                    onChanged: (val) => setModalState(() => editItemId = val),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Quantity (పరిమాణం)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    labelText: 'Amount (మొత్తం)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0B6E5F)),
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                final qty = double.tryParse(qtyCtrl.text.trim());
                final custName = customerCtrl.text.trim();

                Navigator.of(dialogCtx).pop();
                if (txn.id != null) {
                  await provider.updateTransaction(
                    txnId: txn.id!,
                    type: editType,
                    customerName: custName.isNotEmpty ? custName : null,
                    itemId: editItemId,
                    qty: qty,
                    amount: amt,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Entry updated successfully · సరిదిద్దబడింది'),
                        backgroundColor: Color(0xFF0B6E5F),
                      ),
                    );
                  }
                }
              },
              child: const Text('Save Changes · మార్పులు సేవ్ చేయి'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTxn(BuildContext context, Txn txn) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('రద్దు చేయండి · Undo Entry?'),
        content: const Text(
          'Are you sure you want to delete this entry? Stock and customer balance changes will be reversed.\n\n(స్టాక్ మరియు బాకీ మార్పులు వెనక్కి తిప్పబడతాయి).',
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
}
