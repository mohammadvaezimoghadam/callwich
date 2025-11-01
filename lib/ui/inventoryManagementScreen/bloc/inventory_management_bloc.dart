import 'package:bloc/bloc.dart';
import 'package:callwich/data/common/app_exeption.dart';
import 'package:callwich/data/common/app_state_manager.dart';
import 'package:callwich/data/models/category.dart';
import 'package:callwich/data/models/product.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/repository/category_repository.dart';
import 'package:callwich/data/repository/product_repository.dart';
import 'package:callwich/data/repository/ingredients_repository.dart';
import 'package:get_it/get_it.dart';

part 'inventory_management_event.dart';
part 'inventory_management_state.dart';

class InventoryManagementBloc
    extends Bloc<InventoryManagementEvent, InventoryManagementState> {
  final ICategoryRepository categoryRepository;
  final IProductRepository productRepository;
  final IIngredientsRepository ingredientsRepository;

  late List<ProductEntity> allProducts;
  late List<IngredientEntity> allIngredients;
  late List<CategoryEntity> allCategories;

  InventoryManagementBloc({
    required this.categoryRepository,
    required this.productRepository,
    required this.ingredientsRepository,
  }) : super(InventoryManagementLoading()) {
    on<InventoryManagementEvent>((event, emit) async {
      if (event is InventoryManagementStarted) {
        await _loadInventoryData(emit);
      } else if (event is CategoryFilterChanged) {
        await _onCategoryFilterChanged(event, emit);
      } else if (event is StockFilterChanged) {
        await _onStockFilterChanged(event, emit);
      } else if (event is FilterChanged) {
        await _onFilterChanged(event, emit);
      } else if (event is TabChanged) {
        await _onTabChanged(event, emit);
      } else if (event is DeleteIngredientClicked) {
        await _onDeleteIngredient(event, emit);
      }
    });
  }

  Future<void> _onDeleteIngredient(
    DeleteIngredientClicked event,
    Emitter<InventoryManagementState> emit,
  ) async {
    // First get the current state
    final currentState = state;
    if (currentState is InventoryManagementSuccess) {
      try {
        // Update UI to show loading state for the specific ingredient
        final updatedIngredients = List<IngredientEntity>.from(currentState.filteredIngredients);
        final index = updatedIngredients.indexWhere((ingredient) => ingredient.id == event.ingredientId);
        
        if (index != -1) {
          // Create a copy of the ingredient with loading state
          final originalIngredient = updatedIngredients[index];
          updatedIngredients[index] = IngredientEntity(
            id: originalIngredient.id,
            name: originalIngredient.name,
            purchasePrice: originalIngredient.purchasePrice,
            unit: originalIngredient.unit,
            stock: originalIngredient.stock,
            minStock: originalIngredient.minStock,
            isActive: originalIngredient.isActive,
            isdLoading: true,
          );
          
          // Emit updated state with loading indicator for the specific ingredient
          emit(currentState.copyWith(
            filteredIngredients: updatedIngredients,
          ));
        }

        // Perform the actual deletion
        await ingredientsRepository.deletIngredient(event.ingredientId);
        
        // After successful deletion, refresh all data
        await _loadInventoryData(emit);
        
        // Trigger reload for other pages
        GetIt.instance<AppStateManager>().triggerAllPagesReload();
      } catch (e) {
        // If deletion fails, revert the loading state and show error
        emit(currentState.copyWith(
          inSuccessStateError: true,
          errorText: e is AppException ? e.message : 'خطای نامشخص در حذف ماده اولیه',
        ));
      }
    }
  }

  Future<void> _loadInventoryData(
    Emitter<InventoryManagementState> emit,
  ) async {
    emit(InventoryManagementLoading());
    try {
      // Load all data
      allProducts = await productRepository.getProducts();
      allCategories = await categoryRepository.getCategories();

      // Get purchased products (products with type 'purchased')
      final purchasedProducts =
          allProducts.where((product) => product.type == 'purchased').toList();

      // Get raw materials (ingredients)
      allIngredients = await _getAllIngredients();

      // Calculate stock percentages and low stock items
      final lowStockProducts = _getLowStockProducts(allProducts);
      final lowStockIngredients = _getLowStockIngredients(allIngredients);

      // Calculate max stock values for better visualization
      final maxPurchasedStock = _getMaxStock(purchasedProducts);
      final maxManufacturedStock = _getMaxStock(
        allProducts.where((p) => p.type != 'purchased').toList(),
      );
      final maxIngredientStock = _getMaxIngredientStock(allIngredients);

      // Create virtual categories for "all", "low-stock", and "ingredients"
      final virtualCategories = [
        CategoryEntity(id: -1, name: 'همه'), // Virtual category for "all"
        CategoryEntity(
          id: -2,
          name: 'موجودی کم',
        ), // Virtual category for "low-stock"
        CategoryEntity(
          id: -3,
          name: 'مواد اولیه',
        ), // Virtual category for "ingredients"
        ...allCategories,
      ];

      // Start with "all" category selected
      final filteredProducts = allProducts;
      final filteredIngredients = allIngredients;

      emit(
        InventoryManagementSuccess(
          categories: virtualCategories,
          allProducts: allProducts,
          purchasedProducts: purchasedProducts,
          rawMaterials: allIngredients,
          filteredProducts: filteredProducts,
          filteredIngredients: filteredIngredients,
          lowStockProducts: lowStockProducts,
          lowStockIngredients: lowStockIngredients,
          selectedCategoryId: -1, // Start with "all" selected
          selectedStockFilter: 'all',
          selectedTab: 'products', // Start with products tab
          lowStockCount: lowStockProducts.length + lowStockIngredients.length,
          maxPurchasedStock: maxPurchasedStock,
          maxManufacturedStock: maxManufacturedStock,
          maxIngredientStock: maxIngredientStock,
        ),
      );
    } catch (e) {
      emit(
        InventoryManagementError(
          appException: e is AppException ? e : AppException(),
        ),
      );
    }
  }

  Future<void> _onCategoryFilterChanged(
    CategoryFilterChanged event,
    Emitter<InventoryManagementState> emit,
  ) async {
    if (state is InventoryManagementSuccess) {
      final currentState = state as InventoryManagementSuccess;

      List<ProductEntity> filteredProducts;
      List<IngredientEntity> filteredIngredients;

      if (event.categoryId == null) {
        // Show all items
        filteredProducts = allProducts;
        filteredIngredients = allIngredients;
      } else if (event.categoryId == -1) {
        // Virtual category "همه" - show all items
        filteredProducts = allProducts;
        filteredIngredients = allIngredients;
      } else if (event.categoryId == -2) {
        // Virtual category "موجودی کم" - show only low stock items
        filteredProducts = _getLowStockProducts(allProducts);
        filteredIngredients = _getLowStockIngredients(allIngredients);
      } else if (event.categoryId == -3) {
        // Virtual category "مواد اولیه" - show only ingredients
        filteredProducts = []; // No products
        filteredIngredients = allIngredients; // All ingredients
      } else {
        // Filter by real category (only for products, ingredients don't have categories)
        filteredProducts = _filterProductsByCategory(
          allProducts,
          event.categoryId!,
        );
        filteredIngredients =
            allIngredients; // Show all ingredients for product categories
      }

      emit(
        currentState.copyWith(
          filteredProducts: filteredProducts,
          filteredIngredients: filteredIngredients,
          selectedCategoryId: event.categoryId,
        ),
      );
    }
  }

  Future<void> _onStockFilterChanged(
    StockFilterChanged event,
    Emitter<InventoryManagementState> emit,
  ) async {
    if (state is InventoryManagementSuccess) {
      final currentState = state as InventoryManagementSuccess;

      List<ProductEntity> filteredProducts;
      if (event.stockFilter == 'all') {
        // Show all products for selected category
        if (currentState.selectedCategoryId != null) {
          filteredProducts = _filterProductsByCategory(
            allProducts,
            currentState.selectedCategoryId!,
          );
        } else {
          filteredProducts = allProducts;
        }
      } else if (event.stockFilter == 'low-stock') {
        // Show only low stock products
        filteredProducts = _getLowStockProducts(allProducts);
        if (currentState.selectedCategoryId != null) {
          filteredProducts = _filterProductsByCategory(
            filteredProducts,
            currentState.selectedCategoryId!,
          );
        }
      } else {
        // Show all products
        filteredProducts = allProducts;
      }

      emit(
        currentState.copyWith(
          filteredProducts: filteredProducts,
          selectedStockFilter: event.stockFilter,
        ),
      );
    }
  }

  Future<void> _onFilterChanged(
    FilterChanged event,
    Emitter<InventoryManagementState> emit,
  ) async {
    if (state is InventoryManagementSuccess) {
      final currentState = state as InventoryManagementSuccess;

      List<ProductEntity> filteredProducts;
      String selectedStockFilter = 'all';
      int? selectedCategoryId = null;

      if (event.filterType == 'all') {
        // Show all products
        filteredProducts = allProducts;
        selectedStockFilter = 'all';
        selectedCategoryId = null;
      } else if (event.filterType == 'low-stock') {
        // Show only low stock products
        filteredProducts = _getLowStockProducts(allProducts);
        selectedStockFilter = 'low-stock';
        selectedCategoryId = null;
      } else {
        // Filter by category
        if (event.categoryId != null) {
          filteredProducts = _filterProductsByCategory(
            allProducts,
            event.categoryId!,
          );
          selectedCategoryId = event.categoryId;
          selectedStockFilter = 'all';
        } else {
          filteredProducts = allProducts;
          selectedCategoryId = null;
          selectedStockFilter = 'all';
        }
      }

      emit(
        currentState.copyWith(
          filteredProducts: filteredProducts,
          selectedCategoryId: selectedCategoryId,
          selectedStockFilter: selectedStockFilter,
        ),
      );
    }
  }

  Future<void> _onTabChanged(
    TabChanged event,
    Emitter<InventoryManagementState> emit,
  ) async {
    if (state is InventoryManagementSuccess) {
      final currentState = state as InventoryManagementSuccess;

      emit(currentState.copyWith(selectedTab: event.tab));
    }
  }

  List<ProductEntity> _filterProductsByCategory(
    List<ProductEntity> products,
    int categoryId,
  ) {
    return products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  List<ProductEntity> _getLowStockProducts(List<ProductEntity> products) {
    return products.where((product) {
      final currentStock = double.tryParse(product.stock) ?? 0.0;
      final minStock = double.tryParse(product.minStock) ?? 0.0;
      // فقط محصولاتی که موجودی آنها کمتر از حداقل موجودی است
      return currentStock < minStock;
    }).toList();
  }

  List<IngredientEntity> _getLowStockIngredients(
    List<IngredientEntity> ingredients,
  ) {
    return ingredients.where((ingredient) {
      final currentStock = double.tryParse(ingredient.stock) ?? 0.0;
      final minStock = double.tryParse(ingredient.minStock) ?? 0.0;
      // فقط مواد اولیه‌ای که موجودی آنها کمتر از حداقل موجودی است
      return currentStock < minStock;
    }).toList();
  }

  Future<List<IngredientEntity>> _getAllIngredients() async {
    try {
      return await ingredientsRepository.getAllIngredients();
    } catch (e) {
      return [];
    }
  }

  double _getMaxStock(List<ProductEntity> products) {
    if (products.isEmpty) return 100.0; // مقدار پیش‌فرض

    double maxStock = 0.0;
    for (final product in products) {
      final stock = double.tryParse(product.stock) ?? 0.0;
      if (stock > maxStock) {
        maxStock = stock;
      }
    }

    // اگر حداکثر موجودی صفر باشد، مقدار پیش‌فرض برگردان
    return maxStock > 0 ? maxStock : 100.0;
  }

  double _getMaxIngredientStock(List<IngredientEntity> ingredients) {
    if (ingredients.isEmpty) return 1000.0; // مقدار پیش‌فرض

    double maxStock = 0.0;
    for (final ingredient in ingredients) {
      final stock = double.tryParse(ingredient.stock) ?? 0.0;
      if (stock > maxStock) {
        maxStock = stock;
      }
    }

    // اگر حداکثر موجودی صفر باشد، مقدار پیش‌فرض برگردان
    return maxStock > 0 ? maxStock : 1000.0;
  }
}