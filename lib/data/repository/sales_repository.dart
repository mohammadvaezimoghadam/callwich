import 'package:callwich/data/datasource/sales_datasource.dart';
import 'package:injectable/injectable.dart';



abstract class ISalesRepository {
  Future<void> createSale(double paymentMethodId, List<Map<String, dynamic>> items);
  Future<List<double>> readSales(String startDate, String endDate);
}

@LazySingleton(as: ISalesRepository)
class SalesRepository implements ISalesRepository {
  final ISalesDataSource salesDataSource;

  SalesRepository({required this.salesDataSource});
  @override
  Future<void> createSale(
    double paymentMethodId,
    List<Map<String, dynamic>> items,
  ) async {
    return await salesDataSource.createSale(paymentMethodId, items);
  }

  @override
  Future<List<double>> readSales(String startDate, String endDate) async {
    return await salesDataSource.readSales(startDate, endDate);
  }
}
