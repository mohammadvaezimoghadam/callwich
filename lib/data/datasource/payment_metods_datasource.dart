import 'package:callwich/data/common/http_response_validator.dart';
import 'package:callwich/data/models/payment_metod.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class IPaymentMethodsDatasource {
  Future<List<PaymentMethodEntity>> getPaymentMethods();
  Future<void> createPaymentMethod(String paymentMethod);
}

@LazySingleton(as: IPaymentMethodsDatasource)
class PaymentMethodsDatasource
    with HttpResponseValidatorMixin
    implements IPaymentMethodsDatasource {
  final Dio httpClient;

  PaymentMethodsDatasource({required this.httpClient});

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() async {
    final response = await httpClient.get('payment-methods/');
    validateResponse(response);
    final paymentMethods = <PaymentMethodEntity>[];
    (response.data as List).forEach((elements) {
      paymentMethods.add(PaymentMethodEntity.fromJson(elements));
    });
    return paymentMethods;
  }

  @override
  Future<void> createPaymentMethod(String paymentMethod) async {
    final response = await httpClient.post(
      'payment-methods/',
      data: {"name": paymentMethod},
    );
    validateResponse(response);
  }
}
