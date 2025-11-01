import 'package:bloc/bloc.dart';
import 'package:callwich/data/common/app_exeption.dart';
import 'package:callwich/data/models/category.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/models/product.dart';
import 'package:callwich/data/repository/category_repository.dart';
import 'package:callwich/data/repository/ingredients_repository.dart';
import 'package:callwich/data/repository/product_repository.dart';


part 'product_list_event.dart';
part 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final ICategoryRepository categoryRepository;
  final IProductRepository productRepository;
  final IIngredientsRepository ingredientsRepository;
  late  List<ProductEntity> products;
  late List<IngredientEntity> ingredients;
  ProductListBloc(this.categoryRepository, this.productRepository, this.ingredientsRepository)
    : super(ProductListLoading()) {
    on<ProductListEvent>((event, emit) async {
      if (event is ProductListStarted) {
        emit(ProductListLoading());
        try {
          products = await productRepository.getProducts();
          final categories = await categoryRepository.getCategories();
          ingredients=await ingredientsRepository.getAllIngredients();
          List<ProductEntity> filltredProductByCatId =
              _fillteredProductByCategory(
                categoryId:event.categoryId==null? categories.first.id:event.categoryId!,
                products: products,
              );

          emit(
            ProductListSuccess(
              selectedCategoryId:event.categoryId==null? categories.first.id:event.categoryId!,
              searchMode: false,
              products: filltredProductByCatId,
              categories: categories,
              gridLoading: false,
              ingredients: ingredients,
              selectedTabIndex: 0,
            ),
          );
        } catch (e) {
          emit(
            ProductListError(
              appException: e is AppException ? e : AppException(),
            ),
          );
        }
      } else if (event is OnTabChangeEvent) {
        await _onTabChange(emit: emit, event: event, products: products);
      } else if (event is OnSubmitEvent) {
        await _onSearch(emit: emit, event: event, products: products);
      }else if(event is DeleteBtnCLiced){
        await _onDeleteProduct(event: event, emit: emit);
      }
    });
  }

  List<ProductEntity> _fillteredProductByCategory({
    required int categoryId,
    required List<ProductEntity> products,
  }) {
    List<ProductEntity> fillteredProductsByCategory = [];
    fillteredProductsByCategory =
        products.where((element) {
          return element.categoryId == categoryId;
        }).toList();
    return fillteredProductsByCategory;
  }

  Future<void> _onTabChange({
    required Emitter<ProductListState> emit,
    required OnTabChangeEvent event,
    required List<ProductEntity> products,
  }) async {
    ProductListSuccess curentState = (state as ProductListSuccess);
    emit(
      ProductListSuccess(
        selectedCategoryId: event.categoryId,
        searchMode: false,
        products: curentState.products,
        categories: curentState.categories,
        gridLoading: true,
        ingredients: ingredients
      ),
    );
    await Future.delayed(Duration(seconds: 1));
    List<ProductEntity> filltredProductByCatId = _fillteredProductByCategory(
      categoryId: event.categoryId,
      products: products,
    );

    emit(
      ProductListSuccess(
        selectedCategoryId: event.categoryId,
        searchMode: false,
        products: filltredProductByCatId,
        categories: curentState.categories,
        gridLoading: false,
        ingredients: ingredients
      ),
    );
  }

  List<ProductEntity> _searchOnProducts({
    required String searchTerm,
    required List<ProductEntity> products,
  }) {
    final lowerSearchTerm = searchTerm.trim().toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(lowerSearchTerm);
    }).toList();
  }

  Future<void> _onSearch({
    required Emitter<ProductListState> emit,
    required OnSubmitEvent event,
    required List<ProductEntity> products,
  }) async {
    ProductListSuccess curentState = (state as ProductListSuccess);
    emit(
      ProductListSuccess(
        selectedCategoryId: event.categoryId,
        searchMode: true,
        products: curentState.products,
        categories: curentState.categories,
        gridLoading: true,
        ingredients: ingredients
      ),
    );
    await Future.delayed(Duration(seconds: 1));
    List<ProductEntity> filltredProductByCatId = _searchOnProducts(
      searchTerm: event.searchTerm,
      products: products,
    );

    emit(
      ProductListSuccess(
        selectedCategoryId: event.categoryId,
        searchMode: true,
        products: filltredProductByCatId,
        categories: curentState.categories,
        gridLoading: false,
        ingredients: ingredients
      ),
    );
  }

  Future<void> _onDeleteProduct({
    required DeleteBtnCLiced event,
    required Emitter<ProductListState> emit,
  }) async {
    try {
      // حذف از سرور
      await productRepository.deletProduct(event.productId);

      // به‌روزرسانی لیست لوکال بدون فراخوانی مجدد API
      products = products.where((p) => p.id != event.productId).toList();

      // اگر در Success هستیم، خروجی را با فیلتر دسته فعلی بساز
      if (state is ProductListSuccess) {
        final current = state as ProductListSuccess;
        final filtered = _fillteredProductByCategory(
          categoryId: current.selectedCategoryId,
          products: products,
        );

        emit(
          ProductListSuccess(
            selectedCategoryId: current.selectedCategoryId,
            searchMode: false,
            products: filtered,
            categories: current.categories,
            gridLoading: false,
            ingredients: ingredients
          ),
        );
      } else {
        // در غیر این صورت، دوباره لیست را از API بارگذاری کن
        add(ProductListStarted());
      }
    } catch (e) {
      emit(
        ProductListError(
          appException: e is AppException ? e : AppException(),
        ),
      );
    }
  }
}
