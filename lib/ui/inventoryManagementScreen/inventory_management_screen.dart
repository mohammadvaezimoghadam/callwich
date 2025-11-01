import 'package:callwich/di/di.dart';
import 'package:callwich/data/common/app_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callwich/data/repository/category_repository.dart';
import 'package:callwich/data/repository/product_repository.dart';
import 'package:callwich/data/repository/ingredients_repository.dart';
import 'package:callwich/ui/inventoryManagementScreen/bloc/inventory_management_bloc.dart';
import 'package:callwich/data/models/product.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/ui/producMnagement/addproduct/add_product_Screen.dart';
import 'package:callwich/data/common/http_client.dart';
import 'package:callwich/ui/producMnagement/productdetails/product_details_screen.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({Key? key}) : super(key: key);

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  late InventoryManagementBloc _inventoryBloc;
  late final AppStateManager _appStateManager;
  bool showLowStockAlert = true;

  @override
  void initState() {
    super.initState();
    _appStateManager = getIt<AppStateManager>();
    _inventoryBloc = InventoryManagementBloc(
      categoryRepository: getIt<ICategoryRepository>(),
      productRepository: getIt<IProductRepository>(),
      ingredientsRepository: getIt<IIngredientsRepository>(),
    );
    _inventoryBloc.add(InventoryManagementStarted());
    _appStateManager.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    _inventoryBloc.close();
    _appStateManager.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() {
    if (_appStateManager.shouldReloadInventory) {
      // Trigger inventory refresh
      _inventoryBloc.add(InventoryManagementStarted());
      _appStateManager.resetPageReloadFlag('inventory');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFf9fafb),
        body: SafeArea(
          child: BlocConsumer<InventoryManagementBloc, InventoryManagementState>(
            bloc: _inventoryBloc,
            listener: (context, state) {
              if (state is InventoryManagementSuccess) {
                if (state.inSuccessStateError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorText),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            builder: (context, state) {
              if (state is InventoryManagementLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFed7c2c)),
                      ),
                      SizedBox(height: 16),
                      Text('در حال بارگذاری داده‌ها...'),
                    ],
                  ),
                );
              } else if (state is InventoryManagementError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('خطا در بارگذاری داده‌ها', style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text(
                        state.appException.message,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _inventoryBloc.add(
                          InventoryManagementStarted(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFed7c2c),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('تلاش مجدد'),
                      ),
                    ],
                  ),
                );
              } else if (state is InventoryManagementSuccess) {
                return _buildSuccessUI(state, theme);
              }
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFed7c2c)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessUI(InventoryManagementSuccess state, ThemeData theme) {
    return Column(
      children: [
        // Header with shadow
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'موجودی',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1f2937),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFed7c2c),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            AddEditProductScreen(isaddProductMode: false),
                      ),
                    ).then((result) {
                      // Refresh inventory data when returning from add/edit screen
                      if (result == true) {
                        _inventoryBloc.add(InventoryManagementStarted());
                      }
                    });
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // Stock Alert with animation
        if (state.lowStockCount > 0)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Visibility(
              key: ValueKey<bool>(showLowStockAlert),
              visible: showLowStockAlert,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: Colors.red[500],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'هشدار موجودی',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                            ),
                          ),
                          Text(
                            '${state.lowStockCount} محصول موجودی کم دارد',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.red[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showLowStockAlert = !showLowStockAlert;
                        });
                      },
                      icon: const Icon(Icons.close),
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Category Filter Buttons with improved styling
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: state.categories
                  .map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _filterButton(
                        category.name,
                        category.id,
                        state.selectedCategoryId == category.id,
                        theme,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),

        // Content List with improved styling
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _inventoryBloc.add(InventoryManagementStarted());
            },
            child: _buildContentList(state, theme),
          ),
        ),
      ],
    );
  }

  Widget _filterButton(
    String label,
    dynamic value,
    bool isSelected,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () {
        _inventoryBloc.add(CategoryFilterChanged(categoryId: value));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFed7c2c) : const Color(0xFFf3f4f6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildContentList(InventoryManagementSuccess state, ThemeData theme) {
    // اگر فیلتر "مواد اولیه" انتخاب شده باشد، فقط مواد اولیه نمایش بده
    if (state.selectedCategoryId == -3) {
      if (state.filteredIngredients.isEmpty) {
        return const Center(
          child: Text('ماده اولیه‌ای یافت نشد'),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.filteredIngredients.length,
        itemBuilder: (context, index) {
          final ingredient = state.filteredIngredients[index];
          return _ingredientCard(ingredient, theme, state);
        },
      );
    }

    // در غیر این صورت، محصولات و مواد اولیه را نمایش بده
    final allItems = <Widget>[];

    // اضافه کردن محصولات
    for (final product in state.filteredProducts) {
      allItems.add(_productCard(product, theme, state));
    }

    // اضافه کردن مواد اولیه (اگر فیلتر "همه" یا "موجودی کم" انتخاب شده باشد)
    if (state.selectedCategoryId == -1 || state.selectedCategoryId == -2) {
      for (final ingredient in state.filteredIngredients) {
        allItems.add(_ingredientCard(ingredient, theme, state));
      }
    }

    if (allItems.isEmpty) {
      return const Center(
        child: Text('آیتمی یافت نشد'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        return allItems[index];
      },
    );
  }

  Widget _productCard(
    ProductEntity product,
    ThemeData theme,
    InventoryManagementSuccess state,
  ) {
    final currentStock = double.tryParse(product.stock) ?? 0.0;
    final minStock = double.tryParse(product.minStock) ?? 0.0;

    // محاسبه طول نوار بر اساس مقدار موجودی فعلی
    double stockPercentage;
    Color stockColor;
    Color stockBgColor;

    // تعیین حداکثر مقدار برای محاسبه طول نوار
    double maxStockForBar;
    if (minStock > 0) {
      // اگر حداقل موجودی تعریف شده باشد، از 3 برابر آن استفاده می‌کنیم
      maxStockForBar = minStock * 3.0;
    } else {
      // اگر حداقل موجودی تعریف نشده باشد، از مقادیر پیش‌فرض استفاده می‌کنیم
      if (product.type == 'purchased') {
        maxStockForBar = 100.0; // حداکثر 100 عدد برای نمایش
      } else {
        maxStockForBar = 1000.0; // حداکثر 1000 گرم برای نمایش
      }
    }

    if (currentStock > 0) {
      // محاسبه درصد بر اساس موجودی فعلی نسبت به حداکثر مقدار نمایش
      stockPercentage = (currentStock / maxStockForBar).clamp(0.0, 1.0);

      // تعیین رنگ بر اساس نسبت موجودی به حداقل موجودی
      if (currentStock < minStock) {
        // موجودی کمتر از حداقل - قرمز
        stockColor = const Color(0xFFef4444); // red-500
        stockBgColor = const Color(0xFFfee2e2); // red-100
      } else if (currentStock < minStock * 1.5) {
        // موجودی کمتر از 1.5 برابر حداقل - نارنجی
        stockColor = const Color(0xFFf97316); // orange-500
        stockBgColor = const Color(0xFFffedd5); // orange-100
      } else {
        // موجودی بیشتر از 1.5 برابر حداقل - سبز
        stockColor = const Color(0xFF22c55e); // green-500
        stockBgColor = const Color(0xFFdcfce7); // green-100
      }
    } else {
      // اگر موجودی صفر باشد
      stockPercentage = 0.0;
      stockColor = const Color(0xFFef4444); // red-500
      stockBgColor = const Color(0xFFfee2e2); // red-100
    }

    return GestureDetector(
      onTap: () {
        // Navigate to product details screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              product: product,
              ingredients: state.rawMaterials,
            ),
          ),
        ).then((result) {
          // Refresh inventory data when returning from product details screen
          if (result == true) {
            _inventoryBloc.add(InventoryManagementStarted());
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with rounded corners
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    baseUrlImg + product.imageUrl,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFFf3f4f6),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image,
                        color: Color(0xFF9ca3af),
                        size: 50,
                      ),
                    ),
                  ),
                  // Product type badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.type == 'purchased' 
                            ? const Color(0xFF3b82f6) // blue-500
                            : const Color(0xFF8b5cf6), // violet-500
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.type == 'purchased' ? 'خریداری' : 'تولیدی',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Product Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name and stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1f2937),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: stockBgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${product.stock} ${product.type == 'purchased' ? 'عدد' : 'گرم'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: stockColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf3f4f6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.categoryName,
                      style: const TextStyle(
                        color: Color(0xFF6b7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Conditional content based on product type
                  if (product.type == 'purchased') ...[
                    // Stock Progress Bar with labels - Only for purchased products
                    Row(
                      children: [
                        Text(
                          'موجودی:',
                          style: TextStyle(
                            color: const Color(0xFF6b7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: stockPercentage,
                              backgroundColor: const Color(0xFFe5e7eb),
                              valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                              minHeight: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Stock details - Only for purchased products
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${currentStock.toStringAsFixed(1)} ${product.type == 'purchased' ? 'عدد' : 'گرم'}',
                          style: TextStyle(
                            color: stockColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'حداقل: ${minStock.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Color(0xFF9ca3af),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // For manufactured products, show a simple message
                    const Row(
                      children: [
                        Text(
                          'محصول تولیدی',
                          style: TextStyle(
                            color: Color(0xFF6b7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ingredientCard(
    IngredientEntity ingredient,
    ThemeData theme,
    InventoryManagementSuccess state,
  ) {
    final currentStock = double.tryParse(ingredient.stock) ?? 0.0;
    final minStock = double.tryParse(ingredient.minStock) ?? 0.0;

    // محاسبه طول نوار بر اساس مقدار موجودی فعلی
    double stockPercentage;
    Color stockColor;
    Color stockBgColor;

    // تعیین حداکثر مقدار برای محاسبه طول نوار
    double maxStockForBar;
    if (minStock > 0) {
      // اگر حداقل موجودی تعریف شده باشد، از 3 برابر آن استفاده می‌کنیم
      maxStockForBar = minStock * 3.0;
    } else {
      // اگر حداقل موجودی تعریف نشده باشد، از مقدار پیش‌فرض استفاده می‌کنیم
      maxStockForBar = 1000.0; // حداکثر 1000 گرم برای نمایش
    }

    if (currentStock > 0) {
      // محاسبه درصد بر اساس موجودی فعلی نسبت به حداکثر مقدار نمایش
      stockPercentage = (currentStock / maxStockForBar).clamp(0.0, 1.0);

      // تعیین رنگ بر اساس نسبت موجودی به حداقل موجودی
      if (currentStock < minStock) {
        // موجودی کمتر از حداقل - قرمز
        stockColor = const Color(0xFFef4444); // red-500
        stockBgColor = const Color(0xFFfee2e2); // red-100
      } else if (currentStock < minStock * 1.5) {
        // موجودی کمتر از 1.5 برابر حداقل - نارنجی
        stockColor = const Color(0xFFf97316); // orange-500
        stockBgColor = const Color(0xFFffedd5); // orange-100
      } else {
        // موجودی بیشتر از 1.5 برابر حداقل - سبز
        stockColor = const Color(0xFF22c55e); // green-500
        stockBgColor = const Color(0xFFdcfce7); // green-100
      }
    } else {
      // اگر موجودی صفر باشد
      stockPercentage = 0.0;
      stockColor = const Color(0xFFef4444); // red-500
      stockBgColor = const Color(0xFFfee2e2); // red-100
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ingredient header with icon
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFf3f4f6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: const Color(0xFF9ca3af),
                    size: 60,
                  ),
                ),
                // Ingredient badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0ea5e9), // sky-500
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'مواد اولیه',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Ingredient Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ingredient name and stock
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        ingredient.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1f2937),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: stockBgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${ingredient.stock} ${ingredient.unit}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: stockColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Stock Progress Bar with labels
                Row(
                  children: [
                    Text(
                      'موجودی:',
                      style: TextStyle(
                        color: const Color(0xFF6b7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: stockPercentage,
                          backgroundColor: const Color(0xFFe5e7eb),
                          valueColor: AlwaysStoppedAnimation<Color>(stockColor),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                // Stock details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${currentStock.toStringAsFixed(1)} ${ingredient.unit}',
                      style: TextStyle(
                        color: stockColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'حداقل: ${minStock.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Color(0xFF9ca3af),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Edit Button
                    GestureDetector(
                      onTap: () => _editIngredient(ingredient),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFdbeafe),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit,
                              size: 16,
                              color: Color(0xFF2563eb),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'ویرایش',
                              style: TextStyle(
                                color: Color(0xFF2563eb),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Delete Button
                    Builder(
                      builder: (localContext) {
                        return GestureDetector(
                          onTap: state.deletBtnIsLoading
                              ? null
                              : () async {
                                  final confirmed = await showDialog<bool>(
                                    context: localContext,
                                    builder: (dialogContext) => AlertDialog(
                                      title: const Text('حذف ماده اولیه'),
                                      content: Text('آیا از حذف "${ingredient.name}" مطمئن هستید؟'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(dialogContext).pop(false),
                                          child: const Text('انصراف'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(dialogContext).pop(true),
                                          child: const Text('حذف'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    _deleteIngredient(ingredient);
                                  }
                                },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFfee2e2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                state.deletBtnIsLoading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.delete,
                                        size: 16,
                                        color: Color(0xFFdc2626),
                                      ),
                                const SizedBox(width: 4),
                                const Text(
                                  'حذف',
                                  style: TextStyle(
                                    color: Color(0xFFdc2626),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editIngredient(IngredientEntity ingredient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen(
          isaddProductMode: false, // برای ویرایش مواد اولیه
          isEditingIngredentMode: true,
          product: null, // برای مواد اولیه null است
          ingredient: ingredient, // ماده اولیه برای ویرایش
        ),
      ),
    ).then((result) {
      // اگر ویرایش موفق بود، صفحه موجودی را به‌روزرسانی کن
      if (result == true) {
        _inventoryBloc.add(InventoryManagementStarted());
      }
    });
  }

  void _deleteIngredient(IngredientEntity ingredient) {
    _inventoryBloc.add(DeleteIngredientClicked(ingredientId: ingredient.id));
  }
}