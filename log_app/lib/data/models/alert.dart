class Alert {
  final int? id;
  final int itemId;
  final double predictedDaysLeft;
  final String sentAt;
  final int seen;

  Alert({
    this.id,
    required this.itemId,
    required this.predictedDaysLeft,
    required this.sentAt,
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
      predictedDaysLeft: (map['predicted_days_left'] as num).toDouble(),
      sentAt: map['sent_at'] as String,
      seen: map['seen'] as int? ?? 0,
    );
  }
}
