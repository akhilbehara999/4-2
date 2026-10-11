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
      amount: (map['amount'] as num).toDouble(),
      rawText: map['raw_text'] as String?,
      audioPath: map['audio_path'] as String?,
      createdAt: map['created_at'] as String,
      synced: map['synced'] as int? ?? 0,
    );
  }
}
