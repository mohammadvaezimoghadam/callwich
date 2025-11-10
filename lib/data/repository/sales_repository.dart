import 'package:callwich/data/datasource/sales_datasource.dart';
import 'package:injectable/injectable.dart';



import 'package:callwich/data/models/sale.dart';

abstract class ISalesRepository {
  Future<SaleEntity> createSale(
    double paymentMethodId,
    List<Map<String, dynamic>> items, {
    required String customerPhoneNumber,
    required String customerName,
  });
  Future<List<double>> readSales(String startDate, String endDate);
}

@LazySingleton(as: ISalesRepository)
class SalesRepository implements ISalesRepository {
  final ISalesDataSource salesDataSource;

  SalesRepository({required this.salesDataSource});
  @override
  Future<SaleEntity> createSale(
    double paymentMethodId,
    List<Map<String, dynamic>> items, {
    required String customerPhoneNumber,
    required String customerName,
  }) async {
    return await salesDataSource.createSale(
      paymentMethodId,
      items,
      customerPhoneNumber: customerPhoneNumber,
      customerName: customerName,
    );
  }

  @override
  Future<List<double>> readSales(String startDate, String endDate) async {
    return await salesDataSource.readSales(startDate, endDate);
  }
}
