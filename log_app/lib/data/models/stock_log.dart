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
      change: (map['change'] as num).toDouble(),
      reason: map['reason'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
