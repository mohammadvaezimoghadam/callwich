import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:callwich/data/common/app_exeption.dart';
import 'package:callwich/data/common/app_state_manager.dart';
import 'package:callwich/data/models/category.dart';
import 'package:callwich/data/models/product.dart';
import 'package:callwich/data/repository/category_repository.dart';
import 'package:callwich/data/repository/ingredients_repository.dart';
import 'package:callwich/data/repository/product_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_it/get_it.dart';

part 'add_product_event.dart';
part 'add_product_state.dart';

class AddProductBloc extends Bloc<AddProductEvent, AddProductState> {
  final IProductRepository productRepo;
  final ICategoryRepository categoryRepository;
  final IIngredientsRepository ingredientsRepository;

  AddProductBloc(
    this.productRepo,
    this.categoryRepository,
    this.ingredientsRepository,
  ) : super(AddProductInitial(categories: [])) {
    on<AddProductEvent>((event, emit) async {
      if (event is AddProductStarted) {
        await _getCategores(event, emit);
      } else if (event is SaveProductBtnIsClicked) {
        await _creatProduct(event, emit, state);
      } else if (event is AddCategoryBtnIsClicked) {
        await _addCategory(event, emit, state);
      } else if (event is SaveIngrediantBtnClicked) {
        await _creatIngredient(event, emit, state);
      } else if (event is UpdateProductEvent) {
        await _editProduct(event, emit, state);
      } else if (event is UpdateIngrediant) {
        await _editIngredient(event, emit, state);
      }
    });
  }

  // Normalizes Persian/Arabic digits and separators to ASCII for safe parsing
  String _normalizeNumberString(String? input) {
    if (input == null) return '';
    var s = input
        .replaceAll('\u066B', '.') // Arabic decimal separator
        .replaceAll('\u066C', ',') // Arabic thousands separator (normalize to comma then remove)
        .replaceAll('\u06D4', '.') // Arabic decimal mark
        .replaceAll('\u066B', '.') // Arabic decimal separator duplicate safety
        .replaceAll('٫', '.') // Arabic decimal point char
        .replaceAll('٬', ',') // Arabic thousands sep char
        .replaceAll('،', ','); // Arabic comma

    // Map Eastern Arabic-Indic digits to ASCII 0-9
    const easternArabic = '٠١٢٣٤٥٦٧٨٩'; // U+0660..U+0669
    const persian = '۰۱۲۳۴۵۶۷۸۹'; // U+06F0..U+06F9
    for (int i = 0; i < 10; i++) {
      s = s.replaceAll(easternArabic[i], i.toString());
      s = s.replaceAll(persian[i], i.toString());
    }

    // Remove grouping separators and spaces
    s = s.replaceAll(',', '');
    s = s.replaceAll(' ', '');
    s = s.replaceAll('\u00A0', ''); // non-breaking space
    return s;
  }

  int _parseInt(String? input, {int fallback = 0}) {
    final normalized = _normalizeNumberString(input);
    if (normalized.isEmpty) return fallback;
    return int.parse(normalized);
  }

  double _parseDouble(String? input, {double fallback = 0.0}) {
    final normalized = _normalizeNumberString(input);
    if (normalized.isEmpty) return fallback;
    return double.parse(normalized);
  }
  Future<void> _creatIngredient(
    SaveIngrediantBtnClicked event,
    Emitter<AddProductState> emit,
    AddProductState state,
  ) async {
    emit(AddProductLoading());

    try {
      await ingredientsRepository.creatIngredient(
        name: event.name,
        purchasePrice: _parseDouble(event.purchasePrice),
        stock: _parseDouble(event.stock),
        minStock: _parseDouble(event.minstock),
        isActive: event.isActive!,
        unit: event.unit,
      );

      // Trigger global reload for all pages
      GetIt.instance<AppStateManager>().triggerAllPagesReload();

      emit(AddProductSuccess());
    } catch (e) {
      emit(
        AddProductError(
          exception: AppException(),
          categories: state is AddProductError
              ? state.categories
              : state is AddProductInitial
              ? state.categories
              : [],
        ),
      );
    }
  }

  Future<void> _getCategores(event, Emitter<AddProductState> emit) async {
    emit(AddProductLoading());
    try {
      final response = await categoryRepository.getCategories();
      final dropDowItems = await getDropDownMenuItem(response);
      emit(AddProductInitial(categories: dropDowItems));
    } catch (e) {
      emit(
        AddProductError(
          exception: e is AppException ? e : AppException(),
          categories: [],
        ),
      );
    }
  }

  Future<void> _creatProduct(
    SaveProductBtnIsClicked event,
    Emitter<AddProductState> emit,
    AddProductState state,
  ) async {
    emit(AddProductLoading());

    try {
      final product = await productRepo.creatProduct(
        event.name,
        _parseInt(event.sellingPrice),
        _parseInt(event.purchasePrice),
        event.categoryId,
        _parseInt(event.stock),
        _parseInt(event.minstock),
        event.isActive,
        event.image,
        event.type,
      );

      // Trigger global reload for all pages
      GetIt.instance<AppStateManager>().triggerAllPagesReload();

      emit(AddProductSuccess(product: product));
    } catch (e) {
      emit(
        AddProductError(
          exception: AppException(),
          categories: state is AddProductError
              ? state.categories
              : state is AddProductInitial
              ? state.categories
              : [],
        ),
      );
    }
  }

  Future<void> _addCategory(event, Emitter<AddProductState> emit, state) async {
    try {
      final response = await categoryRepository.addCategory(event.name);
      final DropdownMenuItem<int> newItem = DropdownMenuItem<int>(
        child: Text(response.name),
        value: response.id,
      );

      state is AddProductInitial ? state.categories.add(newItem) : [];
      emit(AddProductInitial(categories: state.categories));
    } catch (e) {
      emit(
        AddProductError(
          exception: e is AppException ? e : AppException(),
          categories: state is AddProductError
              ? state.categories
              : state is AddProductInitial
              ? state.categories
              : [],
        ),
      );
    }
  }

  Future<List<DropdownMenuItem<int>>> getDropDownMenuItem(
    List<CategoryEntity> categories,
  ) async {
    final List<DropdownMenuItem<int>> categoryList = [];
    categories.forEach((category) {
      categoryList.add(
        DropdownMenuItem(child: Text(category.name), value: category.id),
      );
    });
    return categoryList;
  }

  Future<void> _editProduct(
    UpdateProductEvent event,
    Emitter<AddProductState> emit,
    AddProductState state,
  ) async {
    emit(AddProductLoading());

    try {
      await productRepo.updateProduct(
        event.id,
        event.name,
        _parseDouble(event.sellingPrice),
        event.purchasePrice == null ? 0 : _parseDouble(event.purchasePrice),
        event.categoryId,
        (event.stock == null || event.stock!.isEmpty)
            ? 0.0
            : _parseDouble(event.stock),
        (event.minstock == null || event.minstock!.isEmpty)
            ? 0.0
            : _parseDouble(event.minstock),
        event.isActive!,
        event.image ?? null,
        event.type,
      );

      // Trigger global reload for all pages
      GetIt.instance<AppStateManager>().triggerAllPagesReload();

      emit(AddProductSuccess());
    } catch (e) {
      emit(
        AddProductError(
          exception: AppException(),
          categories: state is AddProductError
              ? state.categories
              : state is AddProductInitial
              ? state.categories
              : [],
        ),
      );
    }
  }

  Future<void> _editIngredient(
    UpdateIngrediant event,
    Emitter<AddProductState> emit,
    AddProductState state,
  ) async {
    emit(AddProductLoading());
    try {
      await ingredientsRepository.updateIngrediant(
        ingredientId: event.id,
        name: event.name,
        purchasePrice: _parseDouble(event.purchasePrice),
        stock: _parseDouble(event.stock),
        minStock: _parseDouble(event.minstock),
        isActive: event.isActive!,
        unit: event.unit,
      );

      // Trigger global reload for all pages
      GetIt.instance<AppStateManager>().triggerAllPagesReload();

      emit(AddProductSuccess());
    } catch (e) {
      emit(
        AddProductError(
          exception: AppException(),
          categories: state is AddProductError
              ? state.categories
              : state is AddProductInitial
              ? state.categories
              : [],
        ),
      );
    }
  }
}
