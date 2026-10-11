class Item {
  final int? id;
  final String nameTe;
  final String nameEn;
  final String unit;
  final double currentStock;
  final int alertDays;
  final double costPrice;
  final double sellPrice;

  Item({
    this.id,
    required this.nameTe,
    required this.nameEn,
    required this.unit,
    this.currentStock = 0.0,
    this.alertDays = 2,
    this.costPrice = 0.0,
    this.sellPrice = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name_te': nameTe,
      'name_en': nameEn,
      'unit': unit,
      'current_stock': currentStock,
      'alert_days': alertDays,
      'cost_price': costPrice,
      'sell_price': sellPrice,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int?,
      nameTe: map['name_te'] as String,
      nameEn: map['name_en'] as String,
      unit: map['unit'] as String,
      currentStock: (map['current_stock'] as num).toDouble(),
      alertDays: map['alert_days'] as int? ?? 2,
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0.0,
      sellPrice: (map['sell_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
