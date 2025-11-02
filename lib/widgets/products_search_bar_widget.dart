import 'package:flutter/material.dart';
import '../res/strings.dart';
import '../res/dimens.dart';

class ProductsSearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final ThemeData theme;
  final Function(String searchTerm) onSubmit;

  const ProductsSearchBarWidget({
    super.key,
    required this.searchController,
    required this.theme,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.medium.toDouble(),
        vertical: (AppDimens.medium - 4).toDouble(),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(50), // rounded-full
          border: Border.all(color: Colors.transparent),
        ),
        child: TextField(
          onEditingComplete: () {
            onSubmit(searchController.text);
          },
          controller: searchController,
          decoration: InputDecoration(
            hintText: AppStrings.searchProducts,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Color(0xFF9A6C4C),
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 0, right: 12),
              child: Icon(Icons.search, color: Color(0xFF9A6C4C), size: 25),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppDimens.medium.toDouble(),
              vertical: 10,
            ),
          ),
        ),
      ),
    );
  }
}