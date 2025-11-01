import 'package:bloc/bloc.dart';
import 'package:callwich/data/common/app_exeption.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/models/product.dart';
import 'package:callwich/data/repository/reports_repository.dart';
import 'package:callwich/data/repository/product_repository.dart';
import 'package:callwich/data/repository/ingredients_repository.dart';
import 'package:equatable/equatable.dart';

part 'reports_event.dart';
part 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final IReportsRepository reportsRepository;
  final IProductRepository productRepository;
  final IIngredientsRepository ingredientsRepository;

  ReportsBloc({required this.reportsRepository,required this.ingredientsRepository,required this.productRepository})
      : super(ReportsLoading()) {
    on<ReportsEvent>((event, emit) async {
      if (event is ReportsStarted) {
        emit(ReportsLoading());
        try {
          // دریافت همه محصولات و مواد اولیه
          final allProducts = await productRepository.getProducts();
          final allIngredients = await ingredientsRepository.getAllIngredients();
          
          // فیلتر کردن فقط محصولات خریدنی
          final purchasedProducts = allProducts.where((product) => product.type == 'purchased').toList();
          
          emit(ReportsSuccess(
            allProducts: purchasedProducts,
            allIngredients: allIngredients,
          ));
        } catch (e) {
          emit(ReportsError(
            appException: e is AppException ? e : AppException(),
          ));
        }
      }
      
      if (event is ReportsRefresh) {
        emit(ReportsLoading());
        try {
          // دریافت همه محصولات و مواد اولیه
          final allProducts = await productRepository.getProducts();
          final allIngredients = await ingredientsRepository.getAllIngredients();
          
          // فیلتر کردن فقط محصولات خریدنی
          final purchasedProducts = allProducts.where((product) => product.type == 'purchased').toList();
          
          emit(ReportsSuccess(
            allProducts: purchasedProducts,
            allIngredients: allIngredients,
          ));
        } catch (e) {
          emit(ReportsError(
            appException: e is AppException ? e : AppException(),
          ));
        }
      }
    });
  }
} 