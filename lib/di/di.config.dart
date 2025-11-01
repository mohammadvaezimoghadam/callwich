// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../data/datasource/auth_datasource.dart' as _i423;
import '../data/datasource/category_datasource.dart' as _i795;
import '../data/datasource/ingredients_datasource.dart' as _i142;
import '../data/datasource/payment_metods_datasource.dart' as _i324;
import '../data/datasource/product_datasource.dart' as _i1063;
import '../data/datasource/recipes_datasource.dart' as _i367;
import '../data/datasource/reports_datasource.dart' as _i490;
import '../data/datasource/sales_datasource.dart' as _i903;
import '../data/repository/auth_repository.dart' as _i79;
import '../data/repository/category_repository.dart' as _i538;
import '../data/repository/ingredients_repository.dart' as _i66;
import '../data/repository/payment_methods_repository.dart' as _i103;
import '../data/repository/product_repository.dart' as _i267;
import '../data/repository/recipes_repository.dart' as _i52;
import '../data/repository/reports_repository.dart' as _i1024;
import '../data/repository/sales_repository.dart' as _i611;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i795.ICategoryDataSource>(
      () => _i795.CategoryDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i367.IRecipesDataSource>(
      () => _i367.RecipesDatasource(httpClient: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i324.IPaymentMethodsDatasource>(
      () => _i324.PaymentMethodsDatasource(httpClient: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i52.IRecipesRepository>(
      () => _i52.RecipesRepository(
        recipesDataSource: gh<_i367.IRecipesDataSource>(),
      ),
    );
    gh.lazySingleton<_i903.ISalesDataSource>(
      () => _i903.SalesDataSource(httpClient: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i538.ICategoryRepository>(
      () => _i538.CategoryRepository(gh<_i795.ICategoryDataSource>()),
    );
    gh.lazySingleton<_i1063.IProductDataSource>(
      () => _i1063.ProductDataSource(httpClient: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i611.ISalesRepository>(
      () =>
          _i611.SalesRepository(salesDataSource: gh<_i903.ISalesDataSource>()),
    );
    gh.lazySingleton<_i142.IIngredientsDatasource>(
      () => _i142.IngredientsDatasource(httpClient: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i490.IReportsDataSource>(
      () => _i490.ReportsDataSource(httpClient: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i423.IAuthDataSource>(
      () => _i423.AuthDatasource(httpClient: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i79.IAuthRepository>(
      () => _i79.AuthRepository(authDataSource: gh<_i423.IAuthDataSource>()),
    );
    gh.lazySingleton<_i103.IPaymentMethodsRepository>(
      () => _i103.PaymentMethodsRepository(
        paymentMethodsDatasource: gh<_i324.IPaymentMethodsDatasource>(),
      ),
    );
    gh.lazySingleton<_i66.IIngredientsRepository>(
      () => _i66.IngredientsRepository(
        ingredientsDatasource: gh<_i142.IIngredientsDatasource>(),
      ),
    );
    gh.lazySingleton<_i267.IProductRepository>(
      () => _i267.ProductRepository(
        productDataSource: gh<_i1063.IProductDataSource>(),
      ),
    );
    gh.lazySingleton<_i1024.IReportsRepository>(
      () => _i1024.ReportsRepository(
        reportsDataSource: gh<_i490.IReportsDataSource>(),
      ),
    );
    return this;
  }
}
