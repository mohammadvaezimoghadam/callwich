import 'package:callwich/data/common/app_state_manager.dart';
import 'package:callwich/data/common/http_client.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'di.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies() {
  getIt.registerSingleton<Dio>(httpClient);
  getIt.registerSingleton<AppStateManager>(AppStateManager());
  getIt.init();
}
