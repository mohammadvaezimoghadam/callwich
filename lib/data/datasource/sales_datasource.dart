import 'package:callwich/components/extensions.dart';
import 'package:callwich/data/common/http_response_validator.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:callwich/data/models/sale.dart';

abstract class ISalesDataSource {
  Future<SaleEntity> createSale(
    double paymentMethodId,
    List<Map<String, dynamic>> items, {
    required String customerPhoneNumber,
    required String customerName,
  });
  Future<List<double>> readSales(String startDate, String endDate);
}

@LazySingleton(as: ISalesDataSource)
class SalesDataSource
    with HttpResponseValidatorMixin
    implements ISalesDataSource {
  final Dio httpClient;

  SalesDataSource({required this.httpClient});

  @override
  Future<SaleEntity> createSale(
    double paymentMethodId,
    List<Map<String, dynamic>> items, {
    required String customerPhoneNumber,
    required String customerName,
  }) async {
    final normalizedPhoneNumber = customerPhoneNumber.toEnglishDigits();

    // The key was changed from 'payment_method' to 'payment_method_id'
    // to match the backend schema.
    final requestData = {
      'payment_method_id': paymentMethodId,
      'items': items,
      'customer_phone_number': normalizedPhoneNumber,
      'customer_name': customerName,
    };

    final response = await httpClient.post('sales/', data: requestData);
    validateResponse(response);

    return SaleEntity.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<double>> readSales(String startDate, String endDate) async {
    final String startDay = '${startDate}T00:00:00';
    final String endDay = '${endDate}T23:59:59';
    final response = await httpClient.get(
      'sales/',
      queryParameters: {'start_date': startDay, 'end_date': endDay},
      options: Options(
        headers: {
          'accept': 'application/json',
        },
      ),
    );
    validateResponse(response);
    final List<double> salesList = [];
    for (final element in response.data as List) {
      // Assuming the key is 'total_amount' and it's a string that needs parsing.
      // If it's already a number, you can cast it directly.
      salesList.add(double.parse(element["total_amount"].toString()));
    }

    return salesList;
  }
}
