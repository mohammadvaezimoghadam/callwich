class PaymentMethodEntity {
  final int id;
  final String name;

  PaymentMethodEntity({required this.id, required this.name});

  factory PaymentMethodEntity.fromJson(Map<String, dynamic> json) {
    return PaymentMethodEntity(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
