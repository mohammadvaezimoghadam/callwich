import 'package:callwich/data/datasource/reports_datasource.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/models/product.dart';
import 'package:injectable/injectable.dart';


abstract class IReportsRepository {
  Future<String> dailySales(String date);
  Future<void> inventoryReport();
  Future<void> profitReport(String startDate, String endDate);
  Future<List<ProductEntity>> getLowStockProducts();
  Future<List<IngredientEntity>> getLowStockIngredients();
}

@LazySingleton(as: IReportsRepository)
class ReportsRepository implements IReportsRepository {
  final IReportsDataSource reportsDataSource;

  ReportsRepository({required this.reportsDataSource});

  @override
  Future<String> dailySales(String date) async {
    return await reportsDataSource.dailySales(date);
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
    return await reportsDataSource.getLowStockIngredients();
  }

  @override
  Future<List<ProductEntity>> getLowStockProducts() async {
    return await reportsDataSource.getLowStockProducts();
  }
}
