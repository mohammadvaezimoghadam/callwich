import 'package:flutter/material.dart';

import 'package:callwich/res/strings.dart';

class ProductFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController sellingPriceController;
  final TextEditingController purchasePriceController;
  final TextEditingController stockController;
  final TextEditingController minStockController;
  final TextEditingController unitController;
  final int? category;
  final List<DropdownMenuItem<int>> categories;
  final ValueChanged<int?> onCategoryChanged;
  final String productType;
  final ValueChanged<String> onProductTypeChanged;
  final bool isPurchased;
  final bool isaddProductMode;
  final bool isEditingProductMode;
  final void Function() onAddCategory;
  final void Function(String field, String value)? onFieldChanged;

  ProductFormWidget({
    Key? key,
    required this.formKey,
    required this.nameController,
    required this.sellingPriceController,
    required this.purchasePriceController,
    required this.stockController,
    required this.minStockController,
    required this.unitController,
    required this.category,
    required this.categories,
    required this.onCategoryChanged,
    required this.productType,
    required this.onProductTypeChanged,
    required this.isPurchased,
    required this.isaddProductMode,
    this.onFieldChanged,
    required this.onAddCategory,
    required this.isEditingProductMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      onChanged: () => (context as Element).markNeedsBuild(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isaddProductMode || isEditingProductMode
                ? AppStrings.productDetails
                : AppStrings.ingredientDetails,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: nameController,

            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color:theme.colorScheme.primary),
              ),
              labelText: nameController.text.isNotEmpty
                  ? (isaddProductMode
                      ? AppStrings.productName
                      : AppStrings.ingredienttName)
                  : null,
              hintText:
                  isaddProductMode
                      ? AppStrings.productName
                      : AppStrings.ingredienttName,
              filled: true,
              fillColor: const Color(0xFFf3ece7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(color: Color(0xFF9a6c4c)),
            ),
            validator:
                (v) =>
                    v == null || v.trim().isEmpty
                        ? AppStrings.requiredField
                        : null,
            onChanged:
                onFieldChanged != null
                    ? (val) => onFieldChanged!("name", val)
                    : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: sellingPriceController,

            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color:theme.colorScheme.primary),
              ),
              labelText: sellingPriceController.text.isNotEmpty
                  ? AppStrings.sellingPrice
                  : null,
              hintText: AppStrings.sellingPrice,
              prefixIcon: const Icon(
                Icons.attach_money,
                color: Color(0xFF9a6c4c),
              ),
              filled: true,
              fillColor: const Color(0xFFf3ece7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(color: Color(0xFF9a6c4c)),
            ),
            validator:
                (v) =>
                    v == null || v.trim().isEmpty
                        ? AppStrings.requiredField
                        : null,
            onChanged:
                onFieldChanged != null
                    ? (val) => onFieldChanged!("sellingPrice", val)
                    : null,
          ),
          const SizedBox(height: 16),
           Visibility(visible: !isaddProductMode && !isEditingProductMode,child: TextFormField( 
            controller: unitController,

           // keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color:theme.colorScheme.primary),
              ),
               labelText: unitController.text.isNotEmpty
                   ? AppStrings.unit
                   : null,
              hintText: AppStrings.unit,
              prefixIcon: const Icon(
                Icons.attach_money,
                color: Color(0xFF9a6c4c),
              ),
              filled: true,
              fillColor: const Color(0xFFf3ece7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              hintStyle: const TextStyle(color: Color(0xFF9a6c4c)),
            ),
            validator:
                (v) =>
                    v == null || v.trim().isEmpty
                        ? AppStrings.requiredField
                        : null,
            onChanged:
                onFieldChanged != null
                    ? (val) => onFieldChanged!("sellingPrice", val)
                    : null,
          ),),
          Visibility(
            visible: isaddProductMode || isEditingProductMode,
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    hint: Text(AppStrings.category),
                    value: category,
                    items: categories,
                    onChanged: onCategoryChanged,
                    decoration: InputDecoration(
                      labelText: AppStrings.category,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      filled: true,
                      fillColor: const Color(0xFFf3ece7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(color: Color(0xFF9a6c4c)),
                    ),
                    validator:
                        (v) =>
                            v == null || v == AppStrings.category
                                ? AppStrings.requiredField
                                : null,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFf3ece7),
                  ),
                  child: IconButton(
                    onPressed: onAddCategory,
                    icon: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Visibility(
            visible: isaddProductMode || isEditingProductMode,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFf3ece7),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'manufactured',
                      groupValue: productType,
                      onChanged: (val) => onProductTypeChanged(val!),
                      title: const Text(
                        AppStrings.manufactured,
                        style: TextStyle(fontSize: 14),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      value: 'purchased',
                      groupValue: productType,
                      onChanged: (val) => onProductTypeChanged(val!),
                      title: const Text(
                        AppStrings.purchased,
                        style: TextStyle(fontSize: 14),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if ( isPurchased ) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: purchasePriceController,

                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color:theme.colorScheme.primary),
                      ),
                      labelText: purchasePriceController.text.isNotEmpty
                          ? AppStrings.cost
                          : null,
                      hintText: AppStrings.cost,
                      filled: true,
                      fillColor: const Color(0xFFf3ece7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(color: Color(0xFF9a6c4c)),
                    ),
                    validator:
                        (v) =>
                            v == null || v.trim().isEmpty
                                ? AppStrings.requiredField
                                : null,
                    onChanged:
                        onFieldChanged != null
                            ? (val) => onFieldChanged!("purchasePrice", val)
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: stockController,

                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color:theme.colorScheme.primary),
                      ),
                      labelText: stockController.text.isNotEmpty
                          ? AppStrings.stock
                          : null,
                      hintText: AppStrings.stock,
                      filled: true,
                      fillColor: const Color(0xFFf3ece7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(color: Color(0xFF9a6c4c)),
                    ),
                    validator:
                        (v) =>
                            v == null || v.trim().isEmpty
                                ? AppStrings.requiredField
                                : null,
                    onChanged:
                        onFieldChanged != null
                            ? (val) => onFieldChanged!("stock", val)
                            : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: minStockController,

                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color:theme.colorScheme.primary),
                      ),
                      labelText: minStockController.text.isNotEmpty
                          ? AppStrings.minStock
                          : null,
                      hintText: AppStrings.minStock,
                      filled: true,
                      fillColor: const Color(0xFFf3ece7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(color: Color(0xFF9a6c4c)),
                    ),
                    validator:
                        (v) =>
                            v == null || v.trim().isEmpty
                                ? AppStrings.requiredField
                                : null,
                    onChanged:
                        onFieldChanged != null
                            ? (val) => onFieldChanged!("minStock", val)
                            : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
