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
                if (state.saleStatus == SaleStatus.success) {
                  Future.delayed(Duration(seconds: 3)).then((val) {
                    GetIt.instance<AppStateManager>().triggerAllPagesReload();
                  });
                }
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
                            BlocProvider.of<SalesBloc>(
                              context,
                            ).add(SalesStarted());
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
    // Set default payment method when state is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.state.paymentMethods.isNotEmpty) {
        setState(() {
          _selectedPaymentMethodId =
              widget.state.paymentMethods.first.id.toDouble();
        });
      }
    });
  }

  @override
  void didUpdateWidget(_CartTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selected payment method when payment methods change
    if (widget.state.paymentMethods.isNotEmpty &&
        !widget.state.paymentMethods.any(
          (pm) => pm.id == _selectedPaymentMethodId.toInt(),
        )) {
      setState(() {
        _selectedPaymentMethodId =
            widget.state.paymentMethods.first.id.toDouble();
      });
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
                'نحوه پرداخت: ${widget.state.paymentMethods.firstWhere((pm) => pm.id == _selectedPaymentMethodId.toInt()).name}',
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

  // تابع نمایش موفقیت فروش
  Future<void> _showSuccessDialog(
    BuildContext context,
    List<MapEntry<ProductEntity, int>> items,
    Function onsellComplited,
    double total,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.green[50],
            title: Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(height: 10),
                Text(
                  'فروش موفقیت آمیز',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payment,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'نحوه پرداخت: ${widget.state.paymentMethods.firstWhere((pm) => pm.id == _selectedPaymentMethodId.toInt()).name}',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'مبلغ کل: ${total.toToman()}',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'فاکتور فروش:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Column(
                      children:
                          items
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.shopping_cart,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${item.key.name}: ${item.value} عدد',
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[400]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.celebration,
                          color: Colors.green[800],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'فروش با موفقیت انجام شد!',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  onsellComplited();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('باشه'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SalesBloc>(
      create:
          (context) => SalesBloc(
            productRepository: getIt<IProductRepository>(),
            categoryRepository: getIt<ICategoryRepository>(),
            salesRepository: getIt<ISalesRepository>(),
            paymentMethodsRepository: getIt<IPaymentMethodsRepository>(),
          ),
      child: BlocListener<SalesBloc, SalesState>(
        listener: (context, state) {
          if (state.saleStatus == SaleStatus.success) {
            // Get current items for success dialog
            final items =
                widget.state.quantities.entries
                    .map(
                      (e) => MapEntry(
                        widget.state.allProducts.firstWhere(
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

            _showSuccessDialog(context, items, widget.onsellComplited, total);
          } else if (state.saleStatus == SaleStatus.error) {
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
            final items =
                widget.state.quantities.entries
                    .map(
                      (e) => MapEntry(
                        widget.state.allProducts.firstWhere(
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
                                widget.state.paymentMethods.isEmpty
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
                                    : DropdownButton<double>(
                                      value:
                                          _selectedPaymentMethodId != -1
                                              ? _selectedPaymentMethodId
                                              : null,
                                      hint: const Text('انتخاب کنید'),
                                      items:
                                          widget.state.paymentMethods.map((pm) {
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
      ),
    );
  }
}
