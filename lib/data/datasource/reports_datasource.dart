import 'package:callwich/data/common/http_response_validator.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/models/product.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class IReportsDataSource {
  Future<String> dailySales(String date);
  Future<void> inventoryReport();
  Future<void> profitReport(String startDate, String endDate);
  Future<List<ProductEntity>> getLowStockProducts();
  Future<List<IngredientEntity>> getLowStockIngredients();
}

@LazySingleton(as: IReportsDataSource)
class ReportsDataSource
    with HttpResponseValidatorMixin
    implements IReportsDataSource {
  final Dio httpClient;

  ReportsDataSource({required this.httpClient});

  @override
  Future<String> dailySales(String date) async {
    final response = await httpClient.get("reports/daily-sales?date=$date");
    validateResponse(response);
    String totalSales = response.data["total_sales"].toString();
    return totalSales;
  }

  @override
  Future<void> inventoryReport() {
    // TODO: implement inventoryReport
    throw UnimplementedError();
  }

  @override
  Future<void> profitReport(String startDate, String endDate) {
    // TODO: implement profitReport
    throw UnimplementedError();
  }

  @override
  Future<List<IngredientEntity>> getLowStockIngredients() async {
    final response = await httpClient.get("reports/low-stock-ingredients");
    validateResponse(response);
    final List<IngredientEntity> ingredients = [];
    (response.data as List).forEach((element) {
      ingredients.add(IngredientEntity.fromJson(element));
    });
    return ingredients;
  }

  @override
  Future<List<ProductEntity>> getLowStockProducts() async {
    final response = await httpClient.get("reports/low-stock-products");
    validateResponse(response);
    final List<ProductEntity> products = [];
    (response.data as List).forEach((element) {
      products.add(ProductEntity.fromJson(element));
    });
    return products;
  }
}
