import 'package:callwich/data/models/product.dart';
import 'package:flutter/material.dart';
import '../res/dimens.dart';
import 'product_card_widget.dart';

class ProductsGridWidget extends StatelessWidget {
  final List<ProductEntity> products;
  final ThemeData theme;
  final Function(ProductEntity)? onProductTap;

  const ProductsGridWidget({
    super.key,
    required this.products,
    required this.theme,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        AppDimens.medium.toDouble(),
        AppDimens.medium.toDouble(),
        AppDimens.medium.toDouble(),
        100,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCardWidget(
          product: product,
          theme: theme,
          onTap: onProductTap,
        );
      },
    );
  }
}
