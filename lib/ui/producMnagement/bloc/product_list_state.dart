part of 'product_list_bloc.dart';

sealed class ProductListState  {
  const ProductListState();

  
  
}

final class ProductListLoading extends ProductListState {}

final class ProductListError extends ProductListState {
  final AppException appException;

  const ProductListError({required this.appException});

}

final class ProductListSuccess extends ProductListState {
  final List<ProductEntity> products;
  final List<CategoryEntity> categories;
  final bool gridLoading;
  final bool searchMode;
  final int selectedCategoryId;
  final List<IngredientEntity> ingredients;
  final int? selectedTabIndex;

  const ProductListSuccess( {
    required this.products,
    required this.categories,
    required this.gridLoading,
    required this.searchMode,
    required this.selectedCategoryId,
    required this.ingredients,
    this.selectedTabIndex,
  });

}
