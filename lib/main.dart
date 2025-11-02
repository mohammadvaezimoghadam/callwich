import 'package:callwich/components/theme.dart';
import 'package:callwich/data/repository/auth_repository.dart';
import 'package:callwich/di/di.dart';
import 'package:callwich/ui/auth/login/login_screen.dart';
import 'package:callwich/ui/auth/splash/cubit/auth_cubit.dart';
import 'package:callwich/ui/auth/splash/splash_screen.dart';

import 'package:callwich/ui/main/mainScreen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await getIt<IAuthRepository>().loadAuthInfo();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return AuthCubit();
      },
      child: MaterialApp(
        title: 'CallWich',
        theme: themeData(),
        // routes: appRoutes,
        // initialRoute: RouteNames.splashScreen,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthLoggedInState) {
               // return MainScreen();
                return const MainScreen();
              } else if (state is AuthLoggedOutState) {
                return const LoginScreen();
              } else {
                return const SplashScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
