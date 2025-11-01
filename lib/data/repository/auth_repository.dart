import 'package:callwich/data/datasource/auth_datasource.dart';
import 'package:callwich/data/models/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';



abstract class IAuthRepository {
  Future<AuthEntity> login({required userName, required password});
  Future<void> singOut();
  Future<void> loadAuthInfo();
}
@LazySingleton(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  final IAuthDataSource authDataSource;
  static final ValueNotifier<AuthEntity?> authChangeNotifier = ValueNotifier(null);

  AuthRepository({required this.authDataSource});
  @override
  Future<AuthEntity> login({required userName, required password}) async {
    final authEntity = await authDataSource.login(
      userName: userName,
      password: password,
    );
    _persistAuthTokens(authEntity);
    return authEntity;
  }

  Future<void> _persistAuthTokens(AuthEntity authEntity) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.setString("access_token", authEntity.accessToken);
    loadAuthInfo();
  }
  @override
  Future<void> loadAuthInfo() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final String accessToken =
         sharedPreferences.getString("access_token") ?? "";
    if (accessToken.isNotEmpty) {
      authChangeNotifier.value = AuthEntity(
        accessToken: accessToken,
        tokenType: "tokenType",
      );
    } else {
      authChangeNotifier.value = null;
    }
    
  }

  @override
  Future<void> singOut() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.clear();
    authChangeNotifier.value = null;
  }
}
