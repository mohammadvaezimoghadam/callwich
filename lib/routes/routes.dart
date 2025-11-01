import 'package:callwich/ui/auth/login/login_screen.dart';
import 'package:callwich/ui/auth/splash/splash_screen.dart';
import 'package:callwich/ui/dashboard/dashboard_screen.dart';
import 'package:callwich/ui/producMnagement/products_list_screen.dart';
import 'package:flutter/material.dart';

import 'route_names.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  RouteNames.splashScreen: (context) => const SplahScreen(),
  RouteNames.loginScreen: (context) => const LoginScreen(),
  RouteNames.dashboardScreen: (context) => const DashboardScreen(),
  RouteNames.productsListScreen: (context) => const ProductsListScreen(),
};
