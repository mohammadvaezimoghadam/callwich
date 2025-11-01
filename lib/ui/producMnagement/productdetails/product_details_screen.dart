import 'package:callwich/components/extensions.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/models/product.dart';
import 'package:callwich/data/repository/product_repository.dart';
import 'package:callwich/di/di.dart';
import 'package:callwich/ui/producMnagement/addproduct/add_product_Screen.dart';
import 'package:callwich/ui/producMnagement/productdetails/bloc/product_ditails_bloc.dart';
import 'package:flutter/material.dart';
import 'package:callwich/res/strings.dart';
import 'package:callwich/widgets/availability_status_widget.dart';
import 'package:callwich/widgets/product_action_buttons_widget.dart';
import 'package:callwich/widgets/recipePlaceholderWidget/recipe_placeholder_widget.dart';
import 'package:callwich/data/common/http_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductDetailsScreen extends StatelessWidget {
  final ProductEntity product;
  late ProductDitailsBloc _bloc;
  final List<IngredientEntity> ingredients;
  ProductDetailsScreen({
    super.key,
    required this.product,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: BlocProvider<ProductDitailsBloc>(
          create: (context) {
            _bloc = ProductDitailsBloc(getIt<IProductRepository>());
            return _bloc;
          },
          child: BlocListener<ProductDitailsBloc, ProductDitailsState>(
            listener: (context, state) {
              if (state is WhemDeleIsCom) {
                Navigator.pop(context, true);
              } else if (state is ProductDitailsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.appException.message),
                    backgroundColor: Colors.red[700],
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Scaffold(
              backgroundColor: const Color(0xFFfcfaf8),
              body: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Container(
                      color: const Color(0xFFfcfaf8).withOpacity(0.8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                AppStrings.productDetails,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // For symmetry
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image with floating action
                            Container(
                              height: 200,
                              width: double.infinity,
                              child: ClipRRect(
                                child: Image.network(
                                  baseUrlImg + product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: const Color(0xFFf3f4f6),
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Color(0xFF9ca3af),
                                          size: 60,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      AvailabilityStatusWidget(
                                        isAvailable: product.isActive,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Price, Category, Type
                                  _infoRow(
                                    'قیمت',
                                    double.parse(
                                      product.sellingPrice,
                                    ).toToman(),
                                    theme,
                                  ),
                                  _infoRow(
                                    'دسته‌بندی',
                                    product.categoryName,
                                    theme,
                                  ),
                                  _infoRow('نوع', product.type, theme),
                                  const SizedBox(height: 32),

                                  // Recipe
                                  Visibility(
                                    visible: product.type == "manufactured",
                                    child: RecipePlaceholderWidget(
                                      productId: product.id,
                                      ingredients: ingredients,
                                      productName: product.name,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Edit & Delete Buttons
                                  BlocBuilder<
                                    ProductDitailsBloc,
                                    ProductDitailsState
                                  >(
                                    builder: (context, state) {
                                      if (state is ProductDitailsSuccess ||
                                          state is ProductDitailsError ||
                                          state is WhemDeleIsCom) {
                                        return ProductActionButtonsWidget(
                                          onEditPressed: () async {
                                            final result =
                                                await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddEditProductScreen(
                                                  isEditingProductMode: true,
                                                  product: product,
                                                ),
                                              ),
                                            );

                                            if (result == true) {
                                              Navigator.pop(context, true);
                                            }
                                          },
                                          dleletLoading:
                                              state is ProductDitailsSuccess
                                                  ? state.deletBtnIsLoading
                                                  : false,
                                          onDeletePressed: () {
                                            _showDeleteDialog(context, () {
                                              BlocProvider.of<
                                                      ProductDitailsBloc>(
                                                  context).add(
                                                DeleteBtnIsClicked(
                                                  productId: product.id,
                                                ),
                                              );
                                            });
                                          },
                                        );
                                      } else {
                                        throw Exception("state not valid");
                                      }
                                    },
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Function() onDeletetap) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            content: const Text("آیا از حذف این محصول مطمئن هستید؟"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('خیر'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDeletetap();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('بله حذف کن'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(
    String label,
    String value,
    ThemeData theme, {
    bool border = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: border
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFe7d9cf))),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9a6c4c),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

