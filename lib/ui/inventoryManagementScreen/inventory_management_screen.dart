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

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({Key? key}) : super(key: key);

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  late InventoryManagementBloc _inventoryBloc;
  late final AppStateManager _appStateManager;
  bool showLowStokAlert=true;

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
        backgroundColor: Colors.white,
        body: SafeArea(
          child:
              BlocConsumer<InventoryManagementBloc, InventoryManagementState>(
                bloc: _inventoryBloc,
                listener: (context, state) {
                  if (state is InventoryManagementSuccess) {
                    if (state.inSuccessStateError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorText),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                builder: (context, state) {
                  if (state is InventoryManagementLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is InventoryManagementError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('خطا در بارگذاری داده‌ها'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _inventoryBloc.add(
                              InventoryManagementStarted(),
                            ),
                            child: const Text('تلاش مجدد'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is InventoryManagementSuccess) {
                    return _buildSuccessUI(state, theme);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
        ),
      ),
    );
  }

  Widget _buildSuccessUI(InventoryManagementSuccess state, ThemeData theme) {
   
    return Column(
      children: [
        // Header
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFe5e7eb))),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'موجودی',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AddEditProductScreen(isaddProductMode: false),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFf3f4f6),
                  foregroundColor: const Color(0xFF6b7280),
                ),
              ),
            ],
          ),
        ),

        // Stock Alert
        if (state.lowStockCount > 0)
          Visibility(
            visible: showLowStokAlert,
            child: Container(
              color: Colors.red[50],
              padding: const EdgeInsets.all(16),
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
                        showLowStokAlert = !showLowStokAlert;
                      });
                    },
                    icon: const Icon(Icons.chevron_left),
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),

        // Category Filter Buttons
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFe5e7eb))),
          ),
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

        // Content List
        Expanded(child: _buildContentList(state, theme)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFdbeafe) : const Color(0xFFf3f4f6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: isSelected
                ? const Color(0xFF2563eb)
                : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildContentList(InventoryManagementSuccess state, ThemeData theme) {
    // اگر فیلتر "مواد اولیه" انتخاب شده باشد، فقط مواد اولیه نمایش بده
    if (state.selectedCategoryId == -3) {
      return ListView.builder(
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

    return ListView.builder(
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
        stockColor = Colors.red;
      } else if (currentStock < minStock * 1.5) {
        // موجودی کمتر از 1.5 برابر حداقل - نارنجی
        stockColor = Colors.orange;
      } else {
        // موجودی بیشتر از 1.5 برابر حداقل - سبز
        stockColor = Colors.green;
      }
    } else {
      // اگر موجودی صفر باشد
      stockPercentage = 0.0;
      stockColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFf3f4f6))),
      ),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              baseUrlImg + product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: const Color(0xFFf3f4f6),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image,
                  color: Color(0xFF9ca3af),
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${product.stock} ${product.type == 'purchased' ? 'عدد' : 'گرم'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6b7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.categoryName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9ca3af),
                  ),
                ),
                const SizedBox(height: 8),
                // Stock Progress Bar
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFe5e7eb),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: stockPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: stockColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                // Stock Info Text
                const SizedBox(height: 4),
                Visibility(
                  visible: product.type == 'purchased',
                  child: Text(
                    'موجودی: ${product.stock} / حداقل: ${product.minStock}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: stockColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        stockColor = Colors.red;
      } else if (currentStock < minStock * 1.5) {
        // موجودی کمتر از 1.5 برابر حداقل - نارنجی
        stockColor = Colors.orange;
      } else {
        // موجودی بیشتر از 1.5 برابر حداقل - سبز
        stockColor = Colors.green;
      }
    } else {
      // اگر موجودی صفر باشد
      stockPercentage = 0.0;
      stockColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFf3f4f6))),
      ),
      child: Row(
        children: [
          // Ingredient Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFf3f4f6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.inventory_2,
              color: Color(0xFF9ca3af),
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          // Ingredient Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'مواد اولیه',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9ca3af),
                  ),
                ),
                const SizedBox(height: 8),
                // Stock Progress Bar
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFe5e7eb),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: stockPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: stockColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                // Stock Info Text
                const SizedBox(height: 4),
                Text(
                  'موجودی: ${ingredient.stock} / حداقل: ${ingredient.minStock}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: stockColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons Column (vertical)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stock and Unit Text
              Text(
                '${ingredient.stock} ${ingredient.unit}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6b7280),
                ),
              ),
              const SizedBox(height: 8),
              // Edit Button
              GestureDetector(
                onTap: () => _editIngredient(ingredient),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFdbeafe),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFF2563eb),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Delete Button
              GestureDetector(
                onTap: () => state.deletBtnIsLoading
                    ? () {}
                    : _deleteIngredient(ingredient),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFfee2e2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ingredient.isdLoading
                      ? CircularProgressIndicator(
                          padding: const EdgeInsets.all(8),
                          color: theme.colorScheme.error,
                        )
                      : const Icon(Icons.delete, size: 16, color: Color(0xFFdc2626)),
                ),
              ),
            ],
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
