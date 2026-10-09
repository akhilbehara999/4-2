class Item {
  final int? id;
  final String nameTe;
  final String? nameEn;
  final String unit;
  final double currentStock;
  final int alertDays;
  final double costPrice;
  final double sellPrice;

  Item({
    this.id,
    required this.nameTe,
    this.nameEn,
    required this.unit,
    this.currentStock = 0.0,
    this.alertDays = 3,
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
      nameEn: map['name_en'] as String?,
      unit: map['unit'] as String,
      currentStock: (map['current_stock'] as num?)?.toDouble() ?? 0.0,
      alertDays: (map['alert_days'] as num?)?.toInt() ?? 3,
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0.0,
      sellPrice: (map['sell_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Customer {
  final int? id;
  final String name;
  final String? phone;
  final double balanceDue;

  Customer({
    this.id,
    required this.name,
    this.phone,
    this.balanceDue = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'balance_due': balanceDue,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      balanceDue: (map['balance_due'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Txn {
  final int? id;
  final String type;
  final int? itemId;
  final int? customerId;
  final double? qty;
  final double amount;
  final String? rawText;
  final String? audioPath;
  final String createdAt;
  final int synced;

  Txn({
    this.id,
    required this.type,
    this.itemId,
    this.customerId,
    this.qty,
    required this.amount,
    this.rawText,
    this.audioPath,
    required this.createdAt,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'item_id': itemId,
      'customer_id': customerId,
      'qty': qty,
      'amount': amount,
      'raw_text': rawText,
      'audio_path': audioPath,
      'created_at': createdAt,
      'synced': synced,
    };
  }

  factory Txn.fromMap(Map<String, dynamic> map) {
    return Txn(
      id: map['id'] as int?,
      type: map['type'] as String,
      itemId: map['item_id'] as int?,
      customerId: map['customer_id'] as int?,
      qty: (map['qty'] as num?)?.toDouble(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      rawText: map['raw_text'] as String?,
      audioPath: map['audio_path'] as String?,
      createdAt: map['created_at'] as String,
      synced: (map['synced'] as num?)?.toInt() ?? 0,
    );
  }
}

class StockLog {
  final int? id;
  final int itemId;
  final double change;
  final String reason;
  final String createdAt;

  StockLog({
    this.id,
    required this.itemId,
    required this.change,
    required this.reason,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'item_id': itemId,
      'change': change,
      'reason': reason,
      'created_at': createdAt,
    };
  }

  factory StockLog.fromMap(Map<String, dynamic> map) {
    return StockLog(
      id: map['id'] as int?,
      itemId: map['item_id'] as int,
      change: (map['change'] as num?)?.toDouble() ?? 0.0,
      reason: map['reason'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}

class Alert {
  final int? id;
  final int itemId;
  final int predictedDaysLeft;
  final String? sentAt;
  final int seen;

  Alert({
    this.id,
    required this.itemId,
    required this.predictedDaysLeft,
    this.sentAt,
    this.seen = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'item_id': itemId,
      'predicted_days_left': predictedDaysLeft,
      'sent_at': sentAt,
      'seen': seen,
    };
  }

  factory Alert.fromMap(Map<String, dynamic> map) {
    return Alert(
      id: map['id'] as int?,
      itemId: map['item_id'] as int,
      predictedDaysLeft: (map['predicted_days_left'] as num?)?.toInt() ?? 0,
      sentAt: map['sent_at'] as String?,
      seen: (map['seen'] as num?)?.toInt() ?? 0,
    );
  }
}
