part of 'inventory_management_bloc.dart';

sealed class InventoryManagementState {}

final class InventoryManagementLoading extends InventoryManagementState {}

final class InventoryManagementError extends InventoryManagementState {
  final AppException appException;

  InventoryManagementError({required this.appException});
}

final class InventoryManagementSuccess extends InventoryManagementState {
  final List<CategoryEntity> categories;
  final List<ProductEntity> allProducts;
  final List<ProductEntity> purchasedProducts;
  final List<IngredientEntity> rawMaterials;
  final List<ProductEntity> filteredProducts;
  final List<IngredientEntity> filteredIngredients;
  final List<ProductEntity> lowStockProducts;
  final List<IngredientEntity> lowStockIngredients;
  final int? selectedCategoryId;
  final String selectedStockFilter;
  final String selectedTab;
  final int lowStockCount;
  final double maxPurchasedStock;
  final double maxManufacturedStock;
  final double maxIngredientStock;
  final bool deletBtnIsLoading;
  final bool inSuccessStateError;
  final String errorText;

  InventoryManagementSuccess({
    required this.categories,
    required this.allProducts,
    required this.purchasedProducts,
    required this.rawMaterials,
    required this.filteredProducts,
    required this.filteredIngredients,
    required this.lowStockProducts,
    required this.lowStockIngredients,
    required this.selectedCategoryId,
    required this.selectedStockFilter,
    required this.selectedTab,
    required this.lowStockCount,
    required this.maxPurchasedStock,
    required this.maxManufacturedStock,
    required this.maxIngredientStock,
    this.deletBtnIsLoading = false,
    this.inSuccessStateError = false,
    this.errorText = "خطای نامشخص",
  });

  InventoryManagementSuccess copyWith({
    List<CategoryEntity>? categories,
    List<ProductEntity>? allProducts,
    List<ProductEntity>? purchasedProducts,
    List<IngredientEntity>? rawMaterials,
    List<ProductEntity>? filteredProducts,
    List<IngredientEntity>? filteredIngredients,
    List<ProductEntity>? lowStockProducts,
    List<IngredientEntity>? lowStockIngredients,
    int? selectedCategoryId,
    String? selectedStockFilter,
    String? selectedTab,
    int? lowStockCount,
    double? maxPurchasedStock,
    double? maxManufacturedStock,
    double? maxIngredientStock,
    bool? deletBtnIsLoading,
    bool? inSuccessStateError,
    String? errorText,
  }) {
    return InventoryManagementSuccess(
      categories: categories ?? this.categories,
      allProducts: allProducts ?? this.allProducts,
      purchasedProducts: purchasedProducts ?? this.purchasedProducts,
      rawMaterials: rawMaterials ?? this.rawMaterials,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      filteredIngredients: filteredIngredients ?? this.filteredIngredients,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
      lowStockIngredients: lowStockIngredients ?? this.lowStockIngredients,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedStockFilter: selectedStockFilter ?? this.selectedStockFilter,
      selectedTab: selectedTab ?? this.selectedTab,
      lowStockCount: lowStockCount ?? this.lowStockCount,
      maxPurchasedStock: maxPurchasedStock ?? this.maxPurchasedStock,
      maxManufacturedStock: maxManufacturedStock ?? this.maxManufacturedStock,
      maxIngredientStock: maxIngredientStock ?? this.maxIngredientStock,
      deletBtnIsLoading: deletBtnIsLoading ?? this.deletBtnIsLoading,
      inSuccessStateError: inSuccessStateError ?? this.inSuccessStateError,
      errorText: errorText ?? this.errorText,
    );
  }
}