import 'dart:async';

import 'package:callwich/data/common/app_state_manager.dart';
import 'package:callwich/data/common/http_client.dart';
import 'package:callwich/di/di.dart';
import 'package:callwich/res/strings.dart';
import 'package:callwich/widgets/sell_products_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callwich/ui/salesRegistrationScreen/bloc/sales_bloc.dart';
import 'package:callwich/data/repository/product_repository.dart';
import 'package:callwich/data/repository/category_repository.dart';
import 'package:callwich/data/repository/sales_repository.dart';
import 'package:callwich/data/repository/payment_methods_repository.dart';
import 'package:callwich/components/extensions.dart';
import 'package:callwich/data/models/product.dart';
import 'package:callwich/widgets/add_payment_method_widget.dart';
import 'package:get_it/get_it.dart';

class Salescreen extends StatefulWidget {
  const Salescreen({Key? key}) : super(key: key);

  @override
  State<Salescreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<Salescreen> {
  int _selectedTabIndex = 0;
  late final SalesBloc? salesBloc;
  late final StreamSubscription streamSubscription;

  @override
  void dispose() {
    super.dispose();
 
    salesBloc!.close();
    streamSubscription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFfcfaf8),
        body: SafeArea(
          child: BlocProvider<SalesBloc>(
            create: (context) {
              salesBloc = SalesBloc(
                productRepository: getIt<IProductRepository>(),
                categoryRepository: getIt<ICategoryRepository>(),
                salesRepository: getIt<ISalesRepository>(),
                paymentMethodsRepository: getIt<IPaymentMethodsRepository>(),
              );
              salesBloc!.add(const SalesStarted());
              streamSubscription = salesBloc!.stream.listen((state) {
                // Remove the automatic reload from here since it's handled in the success dialog
              });
              return salesBloc!;
            },
            child: Column(
              children: [
                // Header
                Container(
                  color: const Color(0xFFfcfaf8).withOpacity(0.8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context,rootNavigator: true).pop(true),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                AppStrings.pay,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // For symmetry
                        ],
                      ),
                      // Tabs
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Color(0xFFe7d9cf)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _tabButton(
                                AppStrings.productsManagement,
                                0,
                                theme,
                              ),
                            ),
                            Expanded(
                              child: _tabButton(AppStrings.basket, 1, theme),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: BlocBuilder<SalesBloc, SalesState>(
                    builder: (context, state) {
                      if (state.status == SalesStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.status == SalesStatus.error) {
                        return Center(child: Text(state.errorMessage ?? 'خطا'));
                      }

                      if (_selectedTabIndex == 0) {
                        return _ProductsTab(state);
                      } else {
                        return _CartTab(
                          state: state,
                          onsellComplited: () {
                            // This will be called after the dialog closes
                            // The rebuild will happen automatically through the BLoC
                          },
                        );
                      }
                    },
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index, ThemeData theme) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFed7c2c) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color:
                isSelected ? const Color(0xFFed7c2c) : const Color(0xFF9a6c4c),
          ),
        ),
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final SalesState state;
  const _ProductsTab(this.state);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Categories horizontal menu
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: state.categories.length + 1,
            separatorBuilder: (context, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final bool isAll = index == 0;
              final bool isSelected =
                  state.selectedCategoryId ==
                  (isAll ? -1 : state.categories[index - 1].id);
              final String name =
                  isAll ? 'همه' : state.categories[index - 1].name;
              return GestureDetector(
                onTap: () {
                  context.read<SalesBloc>().add(
                    SalesCategorySelected(
                      isAll ? -1 : state.categories[index - 1].id,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.1)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color:
                          isSelected
                              ? Theme.of(context).primaryColor
                              : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      name,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(top: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 0.7,
            ),
            itemCount: state.products.length,
            itemBuilder: (context, index) {
              final product = state.products[index];
              final qty = state.quantities[product.id] ?? 0;
              return ProductCard(
                product: product,
                quantity: qty,
                onDecrease:
                    qty > 0
                        ? () => context.read<SalesBloc>().add(
                          SalesDecreaseQty(product.id),
                        )
                        : null,
                onIncrease:
                    () => context.read<SalesBloc>().add(
                      SalesIncreaseQty(product.id),
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CartTab extends StatefulWidget {
  final SalesState state;
  final Function onsellComplited;
  const _CartTab({required this.state, required this.onsellComplited});

  @override
  State<_CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<_CartTab> {
  double _selectedPaymentMethodId = -1;

  @override
  void initState() {
    super.initState();
    // Load payment methods when the tab is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SalesBloc>().add(SalesLoadPaymentMethods());
    });
  }

  @override
  void didUpdateWidget(_CartTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected payment method when payment methods change
    if (widget.state.paymentMethods != oldWidget.state.paymentMethods) {
      if (widget.state.paymentMethods.isNotEmpty) {
        // Check if current selected payment method still exists
        final currentExists = widget.state.paymentMethods.any(
          (pm) => pm.id == _selectedPaymentMethodId.toInt(),
        );
        
        // If current selection doesn't exist or was -1, select the first one
        if (!currentExists || _selectedPaymentMethodId == -1) {
          setState(() {
            _selectedPaymentMethodId =
                widget.state.paymentMethods.first.id.toDouble();
          });
        }
      } else {
        // If no payment methods, reset selection
        setState(() {
          _selectedPaymentMethodId = -1;
        });
      }
    }
  }

  // تابع نمایش دیالوگ تایید فروش
  void _showSaleConfirmationDialog(
    BuildContext context,
    SalesBloc salesBloc,
    List<MapEntry<ProductEntity, int>> items,
    double total,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تایید فروش'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نحوه پرداخت: ${widget.state.paymentMethods.isNotEmpty ? widget.state.paymentMethods.firstWhere((pm) => pm.id == _selectedPaymentMethodId.toInt(), orElse: () => widget.state.paymentMethods.first).name : 'نامشخص'}',
              ),
              const SizedBox(height: 8),
              Text('مبلغ کل: ${total.toToman()}'),
              const SizedBox(height: 8),
              Text('تعداد اقلام: ${items.length}'),
              const SizedBox(height: 16),
              const Text('آیا از انجام این فروش مطمئن هستید؟'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed:
                  _selectedPaymentMethodId == -1
                      ? null
                      : () {
                        final saleData =
                            items
                                .map(
                                  (item) => {
                                    "product_id": double.parse(
                                      item.key.id.toString(),
                                    ),
                                    "quantity": double.parse(
                                      item.value.toString(),
                                    ),
                                  },
                                )
                                .toList();

                        // ارسال به سرور از طریق BLoC
                        salesBloc.add(
                          SalesConfirmSale(
                            paymentMethodId: _selectedPaymentMethodId,
                            items: saleData,
                          ),
                        );
                        Navigator.of(context).pop();
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFed7c2c),
                foregroundColor: Colors.white,
              ),
              child: const Text('تایید'),
            ),
          ],
        );
      },
    );
  }

  // تابع نمایش صفحه موفقیت فروش
  void _showSuccessScreen(
    BuildContext context,
    List<MapEntry<ProductEntity, int>> items,
    double total,
    String paymentMethodName,
    SalesBloc salesBloc, // Pass the bloc instance
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SalesSuccessScreen(
          items: items,
          total: total,
          paymentMethodName: paymentMethodName,
          onDone: () {
            // Clear the cart
            salesBloc.add(SalesClearCart());
            
            // Trigger inventory reload after successful sale
            try {
              GetIt.instance<AppStateManager>().triggerAllPagesReload();
            } catch (e) {
              print('Error triggering app state reload: $e');
            }
            
            // Rebuild the entire sales screen by triggering a new sales start
            try {
              salesBloc.add(const SalesStarted());
            } catch (e) {
              print('Error restarting sales process: $e');
            }
            
            // Go back to the main sales screen
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the same bloc instance from the parent context instead of creating a new one
    return BlocListener<SalesBloc, SalesState>(
      listener: (context, state) {
        if (state.saleStatus == SaleStatus.success) {
          // Get current items for success screen
          final items =
              state.quantities.entries
                  .map(
                    (e) => MapEntry(
                      state.allProducts.firstWhere(
                        (p) => p.id == e.key,
                      ),
                      e.value,
                    ),
                  )
                  .toList();

          final total = items.fold<double>(0, (sum, entry) {
            final price = double.tryParse(entry.key.sellingPrice) ?? 0;
            final itemTotal = price * entry.value;
            print('Item: ${entry.key.name}, Price: $price, Quantity: ${entry.value}, Item Total: $itemTotal');
            return sum + itemTotal;
          });

          print('Calculated total: $total');

          // Get payment method name
          final paymentMethodName = state.paymentMethods.isNotEmpty
              ? state.paymentMethods.firstWhere(
                  (pm) => pm.id == _selectedPaymentMethodId.toInt(),
                  orElse: () => state.paymentMethods.first,
                ).name
              : 'نامشخص';

          print('Payment method: $paymentMethodName');

          // Get the sales bloc instance
          final salesBloc = context.read<SalesBloc>();

          // Reset the sale status to prevent showing success screen again
          Future.microtask(() {
            salesBloc.add(const SalesResetSaleStatus());
          });

          _showSuccessScreen(context, items, total, paymentMethodName, salesBloc);
        } else if (state.saleStatus == SaleStatus.error) {
          // Reset the sale status to prevent showing error again
          Future.microtask(() {
            context.read<SalesBloc>().add(const SalesResetSaleStatus());
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'خطا در انجام فروش: ${state.saleErrorMessage ?? 'خطای نامشخص'}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

      child: BlocBuilder<SalesBloc, SalesState>(
        builder: (context, state) {
          // Load payment methods when the cart tab is built
          if (state.paymentMethods.isEmpty) {
            context.read<SalesBloc>().add(SalesLoadPaymentMethods());
          }

          final items =
              state.quantities.entries
                  .map(
                    (e) => MapEntry(
                      state.allProducts.firstWhere(
                        (p) => p.id == e.key,
                      ),
                      e.value,
                    ),
                  )
                  .toList();

          final total = items.fold<double>(0, (sum, entry) {
            final price = double.tryParse(entry.key.sellingPrice) ?? 0;
            return sum + price * entry.value;
          });

          return Column(
            children: [
              Expanded(
                child:
                    items.isEmpty
                        ? const Center(child: Text('سبد خرید خالی است'))
                        : ListView.separated(
                          padding: const EdgeInsets.all(12),
                          itemBuilder: (context, index) {
                            final product = items[index].key;
                            final qty = items[index].value;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  '${baseUrlImg}${product.imageUrl}',
                                ),
                              ),
                              title: Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text('تعداد: $qty'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed:
                                    () => context.read<SalesBloc>().add(
                                      SalesRemoveFromCart(product.id),
                                    ),
                              ),
                            );
                          },
                          separatorBuilder:
                              (_, __) => const Divider(height: 1),
                          itemCount: items.length,
                        ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // نحوه پرداخت
                    Row(
                      children: [
                        Text(
                          'نحوه پرداخت: ',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              state.paymentMethods.isEmpty && state.status != SalesStatus.loading
                                  ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'هیچ روش پرداختی موجود نیست',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  )
                                  : state.paymentMethods.isEmpty && state.status == SalesStatus.loading
                                  ? Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: const Text(
                                      'در حال بارگذاری...',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                  : DropdownButton<double>(
                                    value:
                                        _selectedPaymentMethodId != -1 && 
                                        state.paymentMethods.any((pm) => pm.id == _selectedPaymentMethodId.toInt())
                                            ? _selectedPaymentMethodId
                                            : null,
                                    hint: const Text('انتخاب کنید'),
                                    items:
                                        state.paymentMethods.map((pm) {
                                          return DropdownMenuItem<double>(
                                            value: pm.id.toDouble(),
                                            child: Text(pm.name),
                                          );
                                        }).toList(),
                                    onChanged: (double? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          _selectedPaymentMethodId = newValue;
                                        });
                                      }
                                    },
                                    style:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                    isExpanded: true,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        AddPaymentMethodWidget(
                          submit: (name) {
                            BlocProvider.of<SalesBloc>(context).add(
                              SalesCreatePaymentMethod(
                                paymentMethodName: name,
                              ),
                            );
                            // Reload payment methods after creating new one
                            Future.delayed(Duration(milliseconds: 500), () {
                              BlocProvider.of<SalesBloc>(context).add(
                                SalesLoadPaymentMethods(),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // مبلغ کل و دکمه فروش
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'مبلغ کل: ${double.tryParse(total.toStringAsFixed(0))?.toToman() ?? '0 تومان'}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              (items.isEmpty ||
                                      state.isProcessingSale ||
                                      _selectedPaymentMethodId == -1)
                                  ? null
                                  : () => _showSaleConfirmationDialog(
                                    context,
                                    BlocProvider.of<SalesBloc>(context),
                                    items,
                                    total,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFed7c2c),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child:
                              state.isProcessingSale
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                    ),
                                  )
                                  : const Text('انجام فروش'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SalesSuccessScreen extends StatelessWidget {
  final List<MapEntry<ProductEntity, int>> items;
  final double total;
  final String paymentMethodName;
  final Function onDone;

  const SalesSuccessScreen({
    Key? key,
    required this.items,
    required this.total,
    required this.paymentMethodName,
    required this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('SalesSuccessScreen - Received items: ${items.length}, Total: $total, Payment Method: $paymentMethodName');
    
    // Log each item for debugging
    for (var item in items) {
      final price = double.tryParse(item.key.sellingPrice) ?? 0;
      final itemTotal = price * item.value;
      print('Item: ${item.key.name}, Price: $price, Quantity: ${item.value}, Item Total: $itemTotal');
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFf0f9f0), // Light green background
        body: SafeArea(
          child: Column(
            children: [
              // Header with gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Back button with circular background
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.white38,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            onDone();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Success icon with animation effect
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'فروش موفقیت آمیز',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              'فاکتور فروش',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content with scrollable area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary cards
                      Row(
                        children: [
                          // Payment method card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.payment,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'روش پرداخت',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    paymentMethodName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Total amount card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.attach_money,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'مبلغ کل',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    total.toToman(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Items title with decorative line
                      Container(
                        padding: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.green.shade300,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade500,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'اقلام خریداری شده',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Items list with improved styling
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Table header with background
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'نام محصول',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'تعداد',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.green,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'قیمت واحد',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.green,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'مبلغ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.green,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Items with alternating row colors
                            Column(
                              children: [
                                for (int i = 0; i < items.length; i++)
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: i.isEven ? Colors.grey.shade50 : Colors.white,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey.shade200,
                                          width: i == items.length - 1 ? 0 : 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            items[i].key.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${items[i].value}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            (double.tryParse(items[i].key.sellingPrice) ?? 0).toToman(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            ((double.tryParse(items[i].key.sellingPrice) ?? 0) * items[i].value).toToman(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Total row with highlight
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 6,
                                    child: Text(
                                      'جمع کل:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      total.toToman(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Success message with celebration effect
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade400, Colors.green.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.celebration,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'فروش با موفقیت انجام شد!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'آیتم‌های خریداری شده از موجودی کم شدند.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Done button with enhanced styling
              Container(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    onDone();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: Colors.green.withOpacity(0.4),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'فروش جدید',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
