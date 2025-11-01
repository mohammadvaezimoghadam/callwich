part of 'product_list_bloc.dart';

sealed class ProductListEvent {
  const ProductListEvent();
}

final class ProductListStarted extends ProductListEvent {
  final int? categoryId;

  ProductListStarted({this.categoryId});
}

final class OnTabChangeEvent extends ProductListEvent {
  final int categoryId;

  const OnTabChangeEvent({required this.categoryId});
}

final class OnSubmitEvent extends ProductListEvent {
  final String searchTerm;
  final int categoryId;

  const OnSubmitEvent(this.categoryId, {required this.searchTerm});
}


final class DeleteBtnCLiced extends ProductListEvent{
  final int productId;

  DeleteBtnCLiced({required this.productId});
}
