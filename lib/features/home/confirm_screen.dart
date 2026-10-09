import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/kirana_provider.dart';
import '../../data/models.dart';
import '../../data/parser.dart';

class ConfirmScreen extends StatefulWidget {
  final ParsedEntry parsedEntry;

  const ConfirmScreen({
    super.key,
    required this.parsedEntry,
  });

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  late String _selectedType;
  late TextEditingController _customerController;
  late TextEditingController _qtyController;
  late TextEditingController _amountController;
  int? _selectedItemId;
  bool _isSaving = false;

  final List<Map<String, String>> _types = const [
    {'value': 'credit_sale', 'label': 'Credit Sale (ఉధార్)'},
    {'value': 'cash_sale', 'label': 'Cash Sale (నగదు అమ్మకం)'},
    {'value': 'payment_received', 'label': 'Payment Received (జమ/వసూలు)'},
    {'value': 'restock', 'label': 'Restock (స్టాక్ తెచ్చాను)'},
    {'value': 'expense', 'label': 'Expense (ఖర్చు/బిల్లు)'},
  ];

  String _formatQty(double val) {
    if (val % 1 == 0) {
      return val.toInt().toString();
    }
    final s = val.toString();
    return s.contains('.') ? s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : s;
  }

  String _formatAmount(double val) {
    if (val % 1 == 0) {
      return val.toInt().toString();
    }
    final s = val.toString();
    return s.contains('.') ? s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '') : s;
  }

  String? _getUnitConversionNotice() {
    final raw = widget.parsedEntry.rawText.toLowerCase();
    if (raw.contains('gram') || raw.contains('gm') || raw.contains('గ్రాము')) {
      return 'Converted from grams to kg (గ్రాములు కిలోలుగా మార్చబడింది)';
    }
    if (raw.contains('ml') || raw.contains('మిల్లీ')) {
      return 'Converted from ml to litres (మిల్లీలీటర్లు లీటర్లుగా మార్చబడింది)';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _selectedType = widget.parsedEntry.type ?? 'cash_sale';
    _customerController = TextEditingController(text: widget.parsedEntry.customerName ?? '');

    // Convert grams to kg and ml to litres if parsed unit is gram or ml
    double? initialQty = widget.parsedEntry.qty;
    final parsedUnit = widget.parsedEntry.unit?.toLowerCase();
    if (initialQty != null) {
      if (parsedUnit == 'gram' || parsedUnit == 'gm' || parsedUnit == 'g') {
        initialQty = initialQty / 1000.0;
      } else if (parsedUnit == 'ml' || parsedUnit == 'millilitre') {
        initialQty = initialQty / 1000.0;
      }
    }

    _qtyController = TextEditingController(
      text: initialQty != null ? _formatQty(initialQty) : '',
    );
    _amountController = TextEditingController(
      text: widget.parsedEntry.amount != null ? _formatAmount(widget.parsedEntry.amount!) : '',
    );
    _selectedItemId = widget.parsedEntry.itemId;

    _customerController.addListener(() => setState(() {}));
    _qtyController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _customerController.dispose();
    _qtyController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool _isCustomerRequired() =>
      _selectedType == 'credit_sale' || _selectedType == 'payment_received';

  bool _isItemRequired() =>
      _selectedType == 'cash_sale' || _selectedType == 'credit_sale' || _selectedType == 'restock';

  bool _isQtyRequired() =>
      _selectedType == 'cash_sale' || _selectedType == 'credit_sale' || _selectedType == 'restock';

  bool _isAmountRequired() =>
      _selectedType == 'cash_sale' ||
      _selectedType == 'credit_sale' ||
      _selectedType == 'payment_received' ||
      _selectedType == 'expense';

  bool _isCustomerValid() {
    if (!_isCustomerRequired()) return true;
    return _customerController.text.trim().isNotEmpty;
  }

  bool _isItemValid() {
    if (!_isItemRequired()) return true;
    return _selectedItemId != null;
  }

  bool _isQtyValid() {
    if (!_isQtyRequired()) return true;
    final val = double.tryParse(_qtyController.text.trim());
    return val != null && val > 0;
  }

  bool _isAmountValid() {
    if (!_isAmountRequired()) return true;
    final val = double.tryParse(_amountController.text.trim());
    return val != null && val > 0;
  }

  bool _canSave() {
    return _isCustomerValid() && _isItemValid() && _isQtyValid() && _isAmountValid() && !_isSaving;
  }

  Future<void> _handleSave() async {
    if (!_canSave()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<KiranaProvider>();
      final customer = _customerController.text.trim();
      final qty = double.tryParse(_qtyController.text.trim());
      final amount = double.tryParse(_amountController.text.trim());

      await provider.saveEntry(
        type: _selectedType,
        customerName: customer.isNotEmpty ? customer : null,
        itemId: _selectedItemId,
        qty: qty,
        amount: amount,
        rawText: widget.parsedEntry.rawText,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Entry saved successfully! (విజయవంతంగా నమోదైంది)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(0xFF0B6E5F),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KiranaProvider>();
    final items = provider.items;

    // Match item by id or fallback if item was parsed by name
    if (_selectedItemId == null && widget.parsedEntry.itemName != null) {
      final match = items.where((it) =>
          (it.nameEn != null &&
              it.nameEn!.toLowerCase() == widget.parsedEntry.itemName!.toLowerCase()) ||
          it.nameTe.toLowerCase() == widget.parsedEntry.itemName!.toLowerCase());
      if (match.isNotEmpty) {
        _selectedItemId = match.first.id;
      }
    }

    Item? selectedItem;
    for (final it in items) {
      if (it.id == _selectedItemId) {
        selectedItem = it;
        break;
      }
    }
    final currentUnit = selectedItem?.unit ??
        (widget.parsedEntry.unit == 'gram'
            ? 'kg'
            : widget.parsedEntry.unit == 'ml'
                ? 'litre'
                : widget.parsedEntry.unit ?? 'kg');

    final isEmptyParse = widget.parsedEntry.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Entry (ఖరారు చేయండి)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nothing parsed banner
              if (isEmptyParse)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade800, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade900, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Malli cheppandi (మళ్ళీ చెప్పండి - Please say it again or fill below)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Raw text box
              if (widget.parsedEntry.rawText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice / Typed Input:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.parsedEntry.rawText,
                        style: const TextStyle(fontSize: 17, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

              // 1. Transaction Type Dropdown
              const Text(
                'Transaction Type (రకం)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                isExpanded: true,
                style: const TextStyle(fontSize: 18, color: Colors.black87),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                items: _types
                    .map((t) => DropdownMenuItem(
                          value: t['value'],
                          child: Text(t['label']!, style: const TextStyle(fontSize: 16)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 18),

              // 2. Customer Name Field (Conditional/Required)
              if (_isCustomerRequired()) ...[
                Row(
                  children: [
                    const Text(
                      'Customer (ఖాతాదారుడు)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Text('*', style: TextStyle(color: Colors.red, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _customerController,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Customer name',
                    errorText: !_isCustomerValid() ? 'Customer is required' : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: !_isCustomerValid() ? Colors.red : Colors.grey,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: !_isCustomerValid() ? Colors.red : Colors.grey.shade400,
                        width: !_isCustomerValid() ? 2.0 : 1.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // 3. Item Dropdown (Conditional/Required)
              if (_isItemRequired()) ...[
                Row(
                  children: [
                    const Text(
                      'Item (సరుకు)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Text('*', style: TextStyle(color: Colors.red, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  initialValue: items.any((i) => i.id == _selectedItemId) ? _selectedItemId : null,
                  isExpanded: true,
                  hint: const Text('Select an item', style: TextStyle(fontSize: 16)),
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                  decoration: InputDecoration(
                    errorText: !_isItemValid() ? 'Item is required' : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: !_isItemValid() ? Colors.red : Colors.grey.shade400,
                        width: !_isItemValid() ? 2.0 : 1.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: items
                      .map((item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(
                              '${item.nameEn ?? ''} (${item.nameTe}) - ${item.unit}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedItemId = val;
                    });
                  },
                ),
                const SizedBox(height: 18),
              ],

              // 4. Quantity Field (Conditional/Required)
              if (_isQtyRequired()) ...[
                Row(
                  children: [
                    const Text(
                      'Quantity (పరిమాణం)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Text('*', style: TextStyle(color: Colors.red, fontSize: 18)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B6E5F).withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF0B6E5F).withAlpha(80)),
                      ),
                      child: Text(
                        'Unit: $currentUnit',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B6E5F),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _qtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    suffixText: currentUnit,
                    helperText: _getUnitConversionNotice(),
                    helperMaxLines: 2,
                    hintText: 'e.g. 1, 0.5',
                    errorText: !_isQtyValid() ? 'Valid quantity is required' : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: !_isQtyValid() ? Colors.red : Colors.grey.shade400,
                        width: !_isQtyValid() ? 2.0 : 1.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // 5. Amount Field (Conditional/Required)
              if (_isAmountRequired()) ...[
                Row(
                  children: [
                    const Text(
                      'Amount ₹ (మొత్తం)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Text('*', style: TextStyle(color: Colors.red, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    hintText: '0',
                    errorText: !_isAmountValid() ? 'Valid amount is required' : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: !_isAmountValid() ? Colors.red : Colors.grey.shade400,
                        width: !_isAmountValid() ? 2.0 : 1.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              // Action Buttons: Big Save & Cancel
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B6E5F),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      onPressed: _canSave() ? _handleSave : null,
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Save (సేవ్)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
