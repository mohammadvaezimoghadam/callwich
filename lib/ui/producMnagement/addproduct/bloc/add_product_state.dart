part of 'add_product_bloc.dart';

sealed class AddProductState {
  const AddProductState();
}

final class AddProductInitial extends AddProductState {
  final List<DropdownMenuItem<int>> categories;

  const AddProductInitial({required this.categories});
}

final class AddProductLoading extends AddProductState {}

final class AddProductSuccess extends AddProductState {
  final ProductEntity? product;

  AddProductSuccess({ this.product});
}

final class AddProductError extends AddProductState {
  final AppException exception;
  final List<DropdownMenuItem<int>> categories;

  const AddProductError({required this.exception, required this.categories});
}
