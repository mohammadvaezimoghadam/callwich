part of 'product_ditails_bloc.dart';

sealed class ProductDitailsState  {
  const ProductDitailsState();


}

final class ProductDitailsLoading extends ProductDitailsState {}

final class ProductDitailsSuccess extends ProductDitailsState {
  final bool deletBtnIsLoading;
  final bool recipesLoading;

  ProductDitailsSuccess({
    required this.deletBtnIsLoading,
    required this.recipesLoading,
  });

}

final class ProductDitailsError extends ProductDitailsState {
  final AppException appException;

  ProductDitailsError({required this.appException});

}

final class WhemDeleIsCom extends ProductDitailsState {}
