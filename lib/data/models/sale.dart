import 'package:callwich/data/models/payment_metod.dart';
import 'package:callwich/data/models/product.dart';

class SaleEntity {
  final int id;
  final String invoiceNumber;
  final DateTime saleTime;
  final double totalAmount;
  final double discountAmount;
  final double finalAmount;
  final PaymentMethodEntity paymentMethod;
  final List<SaleItemEntity> items;
  final CustomerEntity customer;

  SaleEntity({
    required this.id,
    required this.invoiceNumber,
    required this.saleTime,
    required this.totalAmount,
    required this.discountAmount,
    required this.finalAmount,
    required this.paymentMethod,
    required this.items,
    required this.customer,
  });

  factory SaleEntity.fromJson(Map<String, dynamic> json) {
    return SaleEntity(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      saleTime: json['sale_time'] != null
          ? DateTime.parse(json['sale_time'])
          : DateTime.now(),
      totalAmount: _toDouble(json['total_amount']),
      discountAmount: _toDouble(json['discount_amount']),
      finalAmount: _toDouble(json['final_amount']),
      paymentMethod: json['payment_method'] != null
          ? PaymentMethodEntity.fromJson(json['payment_method'])
          : PaymentMethodEntity(id: -1, name: 'نامشخص'),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => SaleItemEntity.fromJson(item as Map<String, dynamic>))
          .toList(),
      customer: json['customer'] != null
          ? CustomerEntity.fromJson(json['customer'])
          : CustomerEntity.empty(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

class SaleItemEntity {
  final int id;
  final int saleId;
  final int productId;
  final double quantity;
  final double unitPrice;
  final double purchasePrice;
  final double totalPrice;
  final ProductEntity? product;

  SaleItemEntity({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.purchasePrice,
    required this.totalPrice,
    this.product,
  });

  factory SaleItemEntity.fromJson(Map<String, dynamic> json) {
    return SaleItemEntity(
      id: json['id'] ?? 0,
      saleId: json['sale_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      quantity: SaleEntity._toDouble(json['quantity']),
      unitPrice: SaleEntity._toDouble(json['unit_price']),
      purchasePrice: SaleEntity._toDouble(json['purchase_price']),
      totalPrice: SaleEntity._toDouble(json['total_price']),
      product: json['product'] != null
          ? ProductEntity.fromJson(json['product'])
          : null,
    );
  }
}

class CustomerEntity {
  final int id;
  final String phoneNumber;
  final String name;
  final int totalOrders;
  final DateTime createdAt;

  CustomerEntity({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.totalOrders,
    required this.createdAt,
  });

  factory CustomerEntity.fromJson(Map<String, dynamic> json) {
    return CustomerEntity(
      id: json['id'] ?? 0,
      phoneNumber: json['phone_number']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      totalOrders: json['total_orders'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  factory CustomerEntity.empty() {
    return CustomerEntity(
      id: 0,
      phoneNumber: '',
      name: '',
      totalOrders: 0,
      createdAt: DateTime.now(),
    );
  }
}

