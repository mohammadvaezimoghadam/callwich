import 'package:callwich/data/common/http_response_validator.dart';
import 'package:callwich/data/models/auth.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class IAuthDataSource {
  Future<AuthEntity> login({
    required String userName,
    required String password,
  });
}
@LazySingleton(as: IAuthDataSource)
class AuthDatasource
    with HttpResponseValidatorMixin
    implements IAuthDataSource {
  final Dio httpClient; 

  AuthDatasource({required this.httpClient});

  @override
  Future<AuthEntity> login({
    required String userName,
    required String password,
  }) async {
    final options = Options(contentType: Headers.formUrlEncodedContentType);
    final response = await httpClient.post(
      "auth/login",
      data: {
        //"grant_type": "password",
        "username": userName,
        "password": password,
      },
      options: options
    );

    validateResponse(response);

    return AuthEntity.fromJson(response.data);
  }
}
