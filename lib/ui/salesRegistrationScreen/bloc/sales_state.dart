part of 'sales_bloc.dart';

enum SalesStatus { initial, loading, loaded, error }
enum SaleStatus { initial, processing, success, error }

class SalesState {
  final SalesStatus status;
  final List<CategoryEntity> categories;
  final List<ProductEntity> allProducts;
  final List<ProductEntity> products;
  final int selectedCategoryId; // -1 means all
  final Map<int, int> quantities; // productId -> qty
  final String? errorMessage;
  final SaleStatus saleStatus;
  final bool isProcessingSale;
  final String? saleErrorMessage;
  final List<PaymentMethodEntity> paymentMethods;
  final SaleEntity? completedSale;

  const SalesState({
    required this.status,
    required this.categories,
    required this.allProducts,
    required this.products,
    required this.selectedCategoryId,
    required this.quantities,
    required this.errorMessage,
    required this.saleStatus,
    required this.isProcessingSale,
    required this.saleErrorMessage,
    required this.paymentMethods,
    required this.completedSale,
  });

  const SalesState.initial()
      : status = SalesStatus.initial,
        categories = const [],
        allProducts = const [],
        products = const [],
        selectedCategoryId = -1,
        quantities = const {},
        errorMessage = null,
        saleStatus = SaleStatus.initial,
        isProcessingSale = false,
        saleErrorMessage = null,
        paymentMethods = const [],
        completedSale = null;

  static const Object _undefined = Object();

  SalesState copyWith({
    SalesStatus? status,
    List<CategoryEntity>? categories,
    List<ProductEntity>? allProducts,
    List<ProductEntity>? products,
    int? selectedCategoryId,
    Map<int, int>? quantities,
    String? errorMessage,
    SaleStatus? saleStatus,
    bool? isProcessingSale,
    String? saleErrorMessage,
    List<PaymentMethodEntity>? paymentMethods,
    Object? completedSale = _undefined,
  }) {
    return SalesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      allProducts: allProducts ?? this.allProducts,
      products: products ?? this.products,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      quantities: quantities ?? this.quantities,
      errorMessage: errorMessage ?? this.errorMessage,
      saleStatus: saleStatus ?? this.saleStatus,
      isProcessingSale: isProcessingSale ?? this.isProcessingSale,
      saleErrorMessage: saleErrorMessage ?? this.saleErrorMessage,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      completedSale: identical(completedSale, _undefined)
          ? this.completedSale
          : completedSale as SaleEntity?,
    );
  }


}

