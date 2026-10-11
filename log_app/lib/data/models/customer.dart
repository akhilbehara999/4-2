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
