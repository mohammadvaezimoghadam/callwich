import 'package:callwich/data/models/product.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/repository/category_repository.dart';
import 'package:callwich/data/repository/ingredients_repository.dart';
import 'package:callwich/data/repository/product_repository.dart';
import 'package:callwich/di/di.dart';
import 'package:callwich/ui/producMnagement/addproduct/bloc/add_product_bloc.dart';
import 'package:callwich/ui/recipeScreen/recipeScreen.dart';

import 'package:callwich/widgets/addCategoryDialog.dart';
import 'package:callwich/widgets/dashboard_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:callwich/widgets/product_image_picker_widget.dart';
import 'package:callwich/widgets/product_form_widget.dart';
import 'package:callwich/widgets/login_button_widget.dart';
import 'package:callwich/res/strings.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductEntity? product;
  final IngredientEntity? ingredient;
  const AddEditProductScreen({
    super.key,
    this.isaddProductMode = false,
    this.product,
    this.ingredient,
    this.isEditingProductMode = false,
    this.isEditingIngredentMode = false,
  });
  final bool isaddProductMode;
  final bool isEditingProductMode;
  final bool isEditingIngredentMode;

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  late AddProductBloc _addProductBloc;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _purchasePriceController =
      TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minStockController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  int? _category;
  String _productType = 'manufactured';
  XFile? _image;

  bool get _isPurchased => _productType == 'purchased';

  bool get _canSave {
    final requiredFilled =
        _nameController.text.trim().isNotEmpty && _isPurchased
        ? true
        : _sellingPriceController.text.trim().isNotEmpty &&
              _category != null &&
              _category != 'Category*';
    if (_isPurchased) {
      return requiredFilled &&
          _purchasePriceController.text.trim().isNotEmpty &&
          _stockController.text.trim().isNotEmpty &&
          _minStockController.text.trim().isNotEmpty;
    } else if (widget.isaddProductMode == false) {
      return _nameController.text.trim().isNotEmpty &&
          _sellingPriceController.text.trim().isNotEmpty;
    }
    return requiredFilled;
  }

  @override
  void initState() {
    if (widget.product != null) {
      final product = widget.product;
      _nameController.text = product!.name;
      _sellingPriceController.text = product.sellingPrice;
      _purchasePriceController.text = product.purchasePrice;
      _category = product.categoryId;
      _productType = product.type;
      _stockController.text = product.stock;
      _minStockController.text = product.minStock;
    } else if (widget.ingredient != null) {
      final ingredient = widget.ingredient;
      _sellingPriceController.text = ingredient!.purchasePrice;
      _nameController.text = ingredient!.name;
      _purchasePriceController.text = ingredient.purchasePrice.toString();
      _stockController.text = ingredient.stock;
      _minStockController.text = ingredient.minStock;
      _unitController.text = ingredient.unit;
      _productType = 'purchased'; // مواد اولیه همیشه purchased هستند
    }
    if (widget.isaddProductMode == false) {
      _productType = 'purchased';
    }
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sellingPriceController.dispose();
    _purchasePriceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: BlocProvider<AddProductBloc>(
        create: (context) {
          _addProductBloc = AddProductBloc(
            getIt<IProductRepository>(),
            getIt<ICategoryRepository>(),
            getIt<IIngredientsRepository>(),
          );
          _addProductBloc.add(AddProductStarted());
          return _addProductBloc;
        },
        child: BlocListener<AddProductBloc, AddProductState>(
          listener: (context, state) {
            if (state is AddProductError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.exception.message ?? 'خطایی رخ داده است'),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AddProductSuccess) {
              if (_productType == 'manufactured' &&
                  widget.isEditingProductMode == false) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeScreen(
                      productId: state.product!.id,
                      productName: state.product!.name,
                      
                    ),
                  ),
                );
              } else {
                Navigator.pop(context, true);
              }
            }
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFfcfaf8),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocBuilder<AddProductBloc, AddProductState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DashboardHeaderWidget(
                          title: widget.isaddProductMode
                              ? AppStrings.newProduct
                              : widget.isEditingProductMode
                              ? AppStrings.editProduct
                              : widget.isEditingIngredentMode
                              ? AppStrings.editIngredient
                              : AppStrings.newIngredient,
                          iconButton: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          theme: theme,
                        ),
                        const SizedBox(height: 8),
                        Visibility(
                          visible:
                              widget.isaddProductMode ||
                              widget.isEditingProductMode,
                          child: ProductImagePickerWidget(
                            image: _image,
                            onImagePicked: (picked) {
                              setState(() => _image = picked);
                            },
                            isEditing: widget.isEditingProductMode,
                            imageUrl: widget.product?.imageUrl,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const SizedBox(height: 8),
                        ProductFormWidget(
                          onAddCategory: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddCategoryDialog(
                                title: AppStrings.addCategory,
                                hintText: AppStrings.category,
                                onSave: (String name) {
                                  if (name.isNotEmpty) {
                                    _addProductBloc.add(
                                      AddCategoryBtnIsClicked(name: name),
                                    );
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                          onFieldChanged: (field, value) {
                            setState(() {});
                          },
                          isaddProductMode: widget.isaddProductMode,
                          isEditingProductMode: widget.isEditingProductMode,
                          formKey: _formKey,
                          nameController: _nameController,
                          sellingPriceController: _sellingPriceController,
                          purchasePriceController: _purchasePriceController,
                          unitController: _unitController,
                          stockController: _stockController,
                          minStockController: _minStockController,
                          category: _category,
                          categories: state is AddProductInitial
                              ? state.categories
                              : state is AddProductError
                              ? state.categories
                              : [],
                          onCategoryChanged: (val) =>
                              setState(() => _category = val),
                          productType: _productType,
                          onProductTypeChanged: (val) => setState(() {
                            _productType = val;
                          }),
                          isPurchased: _isPurchased,
                        ),

                        Divider(color: theme.dividerColor),
                        const SizedBox(height: 8),

                        LoginButtonWidget(
                          onPressed: () {
                            if (!_canSave) return;
                            if (_formKey.currentState?.validate() ?? false) {
                              if (widget.isEditingProductMode) {
                                _addProductBloc.add(
                                  UpdateProductEvent(
                                    name: _nameController.text,
                                    sellingPrice: _sellingPriceController.text,
                                    purchasePrice: _productType == 'purchased'
                                        ? _purchasePriceController.text
                                        : null,
                                    categoryId: _category!,
                                    type: _productType,
                                    stock: _stockController.text,
                                    minstock: _minStockController.text,
                                    isActive: widget.product!.isActive,
                                    image: _image,
                                    id: widget.product!.id,
                                  ),
                                );
                              } else if (widget.isEditingIngredentMode) {
                                _addProductBloc.add(
                                  UpdateIngrediant(
                                    widget.ingredient!.id,
                                    name: _nameController.text,
                                    purchasePrice:
                                        _purchasePriceController.text,
                                    unit: _unitController.text,
                                    stock: _stockController.text,
                                    minstock: _minStockController.text,
                                    isActive: widget.ingredient!.isActive,
                                  ),
                                );
                              } else if (widget.isaddProductMode) {
                                _addProductBloc.add(
                                  SaveProductBtnIsClicked(
                                    _nameController.text,
                                    _sellingPriceController.text,
                                    _purchasePriceController.text,
                                    _category!,
                                    _productType,
                                    _stockController.text,
                                    _minStockController.text,
                                    true,
                                    _image!,
                                  ),
                                );
                              } else {
                                _addProductBloc.add(
                                  SaveIngrediantBtnClicked(
                                    name: _nameController.text,
                                    unit: _unitController.text,
                                    purchasePrice:
                                        _purchasePriceController.text,
                                    stock: _stockController.text,
                                    minstock: _minStockController.text,
                                  ),
                                );
                              }
                            }
                          },
                          mainColor: const Color(0xFFed7c2c),
                          label: AppStrings.save,
                          loading: state is AddProductLoading ? true : false,
                          enabled: _canSave,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
