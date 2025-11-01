import 'package:callwich/data/datasource/payment_metods_datasource.dart';
import 'package:callwich/data/models/payment_metod.dart';
import 'package:injectable/injectable.dart';



abstract class IPaymentMethodsRepository {
  Future<List<PaymentMethodEntity>> getPaymentMethods();
  Future<void> createPaymentMethod(String paymentMethod);
}

@LazySingleton(as: IPaymentMethodsRepository)
class PaymentMethodsRepository implements IPaymentMethodsRepository {
  final IPaymentMethodsDatasource paymentMethodsDatasource;

  PaymentMethodsRepository({required this.paymentMethodsDatasource});
  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() async {
    return await paymentMethodsDatasource.getPaymentMethods();
  }

  @override
  Future<void> createPaymentMethod(String paymentMethod) async {
    await paymentMethodsDatasource.createPaymentMethod(paymentMethod);
  }
}
