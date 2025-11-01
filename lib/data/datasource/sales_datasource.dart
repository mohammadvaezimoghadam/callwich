import 'package:callwich/data/common/http_response_validator.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class ISalesDataSource {
  Future<void> createSale(
    double paymentMethodId, // Changed from int to double
    List<Map<String, dynamic>> items,
  );
  Future<List<double>> readSales(String startDate, String endDate);
}

@LazySingleton(as: ISalesDataSource)
class SalesDataSource
    with HttpResponseValidatorMixin
    implements ISalesDataSource {
  final Dio httpClient;

  SalesDataSource({required this.httpClient});

  @override
  Future<void> createSale(
    double paymentMethodId, // Changed from int to double
    List<Map<String, dynamic>> items,
  ) async {
    // The key was changed from 'payment_method' to 'payment_method_id'
    // to match the backend schema.
    final requestData = {'payment_method_id': paymentMethodId, 'items': items};

    final response = await httpClient.post('sales/', data: requestData);
    validateResponse(response);
  }

  @override
  Future<List<double>> readSales(String startDate, String endDate) async {
    final String startDay = "$startDate" + "T00:00:00";
    final String endDay = "$endDate" + "T23:59:59";
    final response = await httpClient.get(
      'sales/',
      queryParameters: {'start_date': startDay, 'end_date': endDay},
    );
    validateResponse(response);
    final List<double> salesList = [];
    (response.data as List).forEach((element) {
      // Assuming the key is 'total_amount' and it's a string that needs parsing.
      // If it's already a number, you can cast it directly.
      salesList.add(double.parse(element["total_amount"].toString()));
    });

    return salesList;
  }
}
