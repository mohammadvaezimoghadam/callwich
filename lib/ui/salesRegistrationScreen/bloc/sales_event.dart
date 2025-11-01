part of 'sales_bloc.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();
  @override
  List<Object?> get props => [];
}

class SalesStarted extends SalesEvent {
  final int? categoryId;
  const SalesStarted({this.categoryId});
}

class SalesCategorySelected extends SalesEvent {
  final int categoryId;
  const SalesCategorySelected(this.categoryId);
  @override
  List<Object?> get props => [categoryId];
}

class SalesIncreaseQty extends SalesEvent {
  final int productId;
  const SalesIncreaseQty(this.productId);
  @override
  List<Object?> get props => [productId];
}

class SalesDecreaseQty extends SalesEvent {
  final int productId;
  const SalesDecreaseQty(this.productId);
  @override
  List<Object?> get props => [productId];
}

class SalesRemoveFromCart extends SalesEvent {
  final int productId;
  const SalesRemoveFromCart(this.productId);
  @override
  List<Object?> get props => [productId];
}

class SalesClearCart extends SalesEvent {}

class SalesConfirmSale extends SalesEvent {
  final double paymentMethodId;
  final List<Map<String, dynamic>> items;
  
  const SalesConfirmSale({
    required this.paymentMethodId,
    required this.items,
  });
  
  @override
  List<Object?> get props => [paymentMethodId, items];
}

class SalesLoadPaymentMethods extends SalesEvent {}

class SalesCreatePaymentMethod extends SalesEvent {
  final String paymentMethodName;
  
  const SalesCreatePaymentMethod({required this.paymentMethodName});
  
  @override
  List<Object?> get props => [paymentMethodName];
}

