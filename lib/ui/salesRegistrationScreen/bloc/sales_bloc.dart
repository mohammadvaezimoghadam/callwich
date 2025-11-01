import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:callwich/data/models/product.dart';
import 'package:callwich/data/models/category.dart';
import 'package:callwich/data/models/payment_metod.dart';
import 'package:callwich/data/repository/product_repository.dart';
import 'package:callwich/data/repository/category_repository.dart';
import 'package:callwich/data/repository/sales_repository.dart';
import 'package:callwich/data/repository/payment_methods_repository.dart';

part 'sales_event.dart';
part 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final IProductRepository productRepository;
  final ICategoryRepository categoryRepository;
  final ISalesRepository salesRepository;
  final IPaymentMethodsRepository paymentMethodsRepository;

  late List<ProductEntity> _allProducts;
  late List<CategoryEntity> _allCategories;
  late List<PaymentMethodEntity> _allPaymentMethods;

  SalesBloc({
    required this.productRepository, 
    required this.categoryRepository,
    required this.salesRepository,
    required this.paymentMethodsRepository,
  }) : super(const SalesState.initial()) {
    on<SalesStarted>(_onStarted);
    on<SalesCategorySelected>(_onCategorySelected);
    on<SalesIncreaseQty>(_onIncreaseQty);
    on<SalesDecreaseQty>(_onDecreaseQty);
    on<SalesRemoveFromCart>(_onRemoveFromCart);
    on<SalesClearCart>(_onClearCart);
    on<SalesConfirmSale>(_onConfirmSale);
    on<SalesLoadPaymentMethods>(_onLoadPaymentMethods);
    on<SalesCreatePaymentMethod>(_onCreatePaymentMethod);
    on<SalesResetSaleStatus>(_onResetSaleStatus);
  }

  Future<void> _onStarted(SalesStarted event, Emitter<SalesState> emit) async {
    emit(state.copyWith(status: SalesStatus.loading));
    try {
      _allProducts = await productRepository.getProducts();
      _allCategories = await categoryRepository.getCategories();
      _allPaymentMethods = await paymentMethodsRepository.getPaymentMethods();

      final int selectedCategoryId = event.categoryId ?? _allCategories.first.id;
      final products = _filterByCategory(selectedCategoryId);

      emit(state.copyWith(
        status: SalesStatus.loaded,
        categories: _allCategories,
        allProducts: _allProducts,
        products: products,
        selectedCategoryId: selectedCategoryId,
        paymentMethods: _allPaymentMethods,
      ));
    } catch (e) {
      emit(state.copyWith(status: SalesStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onCategorySelected(
    SalesCategorySelected event,
    Emitter<SalesState> emit,
  ) async {
    final filtered = _filterByCategory(event.categoryId);
    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      products: filtered,
    ));
  }

  List<ProductEntity> _filterByCategory(int categoryId) {
    if (categoryId == -1) return _allProducts;
    return _allProducts.where((p) => p.categoryId == categoryId).toList();
  }

  void _onIncreaseQty(SalesIncreaseQty event, Emitter<SalesState> emit) {
    final updated = Map<int, int>.from(state.quantities);
    final currentQty = updated[event.productId] ?? 0;
    
    // Find the product to check its type and stock
    final product = _allProducts.firstWhere((p) => p.id == event.productId);
    
    print('SalesBloc: Increasing quantity for product ${product.name} (type: ${product.type}, stock: ${product.stock})');
    
    // Allow manufactured products (تولیدی) to be added regardless of stock
    // For purchased products (خریداری), check stock availability
    if (product.type == "تولیدی" || product.type == "manufactured") {
      // Manufactured products can be added without stock restrictions
      updated[event.productId] = currentQty + 1;
      print('SalesBloc: Manufactured product - quantity increased to ${updated[event.productId]}');
    } else {
      // For purchased products, check if stock is available
      final currentStock = double.tryParse(product.stock) ?? 0;
      if (currentStock > currentQty) {
        updated[event.productId] = currentQty + 1;
        print('SalesBloc: Purchased product - quantity increased to ${updated[event.productId]} (stock: $currentStock)');
      } else {
        print('SalesBloc: Purchased product - cannot increase quantity (stock: $currentStock, current: $currentQty)');
      }
      // If stock is not available, don't increase quantity
    }
    
    emit(state.copyWith(quantities: updated));
  }

  void _onDecreaseQty(SalesDecreaseQty event, Emitter<SalesState> emit) {
    final updated = Map<int, int>.from(state.quantities);
    final current = updated[event.productId] ?? 0;
    if (current <= 1) {
      updated.remove(event.productId);
    } else {
      updated[event.productId] = current - 1;
    }
    emit(state.copyWith(quantities: updated));
  }

  void _onRemoveFromCart(
    SalesRemoveFromCart event,
    Emitter<SalesState> emit,
  ) {
    final updated = Map<int, int>.from(state.quantities);
    updated.remove(event.productId);
    emit(state.copyWith(quantities: updated));
  }

  void _onClearCart(SalesClearCart event, Emitter<SalesState> emit) {
    emit(state.copyWith(quantities: {}));
  }

  Future<void> _onConfirmSale(SalesConfirmSale event, Emitter<SalesState> emit) async {
    emit(state.copyWith(
      isProcessingSale: true,
      saleStatus: SaleStatus.processing,
      saleErrorMessage: null,
    ));

    try {
      await salesRepository.createSale(event.paymentMethodId, event.items);
      
      // Clear cart after successful sale
      emit(state.copyWith(
        isProcessingSale: false,
        saleStatus: SaleStatus.success,
        // Don't clear quantities here, let the UI handle it after showing success screen
        saleErrorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessingSale: false,
        saleStatus: SaleStatus.error,
        saleErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadPaymentMethods(SalesLoadPaymentMethods event, Emitter<SalesState> emit) async {
    try {
      _allPaymentMethods = await paymentMethodsRepository.getPaymentMethods();
      emit(state.copyWith(paymentMethods: _allPaymentMethods));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onCreatePaymentMethod(SalesCreatePaymentMethod event, Emitter<SalesState> emit) async {
    try {
      await paymentMethodsRepository.createPaymentMethod(event.paymentMethodName);
      // Reload payment methods after creating new one
      _allPaymentMethods = await paymentMethodsRepository.getPaymentMethods();
      emit(state.copyWith(paymentMethods: _allPaymentMethods));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onResetSaleStatus(SalesResetSaleStatus event, Emitter<SalesState> emit) {
    emit(state.copyWith(
      saleStatus: SaleStatus.initial,
      saleErrorMessage: null,
    ));
  }
}

