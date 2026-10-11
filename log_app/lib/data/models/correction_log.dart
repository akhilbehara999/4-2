class CorrectionLog {
  final int? id;
  final int? txnId;
  final String? rawText;
  final String? parsedFields;
  final String? finalFields;
  final int wasEdited;
  final String createdAt;

  CorrectionLog({
    this.id,
    this.txnId,
    this.rawText,
    this.parsedFields,
    this.finalFields,
    this.wasEdited = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'txn_id': txnId,
      'raw_text': rawText,
      'parsed_fields': parsedFields,
      'final_fields': finalFields,
      'was_edited': wasEdited,
      'created_at': createdAt,
    };
  }

  factory CorrectionLog.fromMap(Map<String, dynamic> map) {
    return CorrectionLog(
      id: map['id'] as int?,
      txnId: map['txn_id'] as int?,
      rawText: map['raw_text'] as String?,
      parsedFields: map['parsed_fields'] as String?,
      finalFields: map['final_fields'] as String?,
      wasEdited: map['was_edited'] as int? ?? 0,
      createdAt: map['created_at'] as String,
    );
  }
}
