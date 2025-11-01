part of 'product_ditails_bloc.dart';

sealed class ProductDitailsEvent extends Equatable {
  const ProductDitailsEvent();

  @override
  List<Object> get props => [];
}

final class DeleteBtnIsClicked extends ProductDitailsEvent {
  final int productId;

  DeleteBtnIsClicked({required this.productId});
  @override
  // TODO: implement props
  List<Object> get props => [productId];
}

final class RecipeaStarted extends ProductDitailsEvent{
  
}