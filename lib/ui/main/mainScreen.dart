import 'package:callwich/data/repository/auth_repository.dart';
import 'package:callwich/ui/auth/splash/cubit/auth_cubit.dart';
import 'package:callwich/ui/dashboard/dashboard_screen.dart';
import 'package:callwich/ui/inventoryManagementScreen/inventory_management_screen.dart';
import 'package:callwich/ui/producMnagement/products_list_screen.dart';
import 'package:callwich/ui/salesRegistrationScreen/saleScreen.dart';
import 'package:callwich/ui/reportsScreen/reports_screen.dart';
import 'package:callwich/widgets/bottom_navigation_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const dashboardIndex = 0;
const inventoryManagementIndex = 1;
const productsListIndex = 2;
const reportsIndex = 3;

// تعریف گلوبال‌کی‌ها مشابه نمونه
final GlobalKey<NavigatorState> dashboardKey = GlobalKey();
final GlobalKey<NavigatorState> inventoryKey = GlobalKey();
final GlobalKey<NavigatorState> productsKey = GlobalKey();
final GlobalKey<NavigatorState> reportsKey = GlobalKey();

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = dashboardIndex;
  final List<int> _history = [];

  late final Map<int, GlobalKey<NavigatorState>> map = {
    dashboardIndex: dashboardKey,
    inventoryManagementIndex: inventoryKey,
    productsListIndex: productsKey,
    reportsIndex: reportsKey,
  };

  @override
  void initState() {
    super.initState();
    AuthRepository.authChangeNotifier.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    AuthRepository.authChangeNotifier.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    BlocProvider.of<AuthCubit>(context).authChanged(AuthRepository.authChangeNotifier.value);
  }

  Future<bool> _onWillPop() async {
    final currentNavigator = map[selectedIndex]?.currentState;

    // اگر در صفحه فعلی امکان pop وجود دارد
    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    }

    // اگر history وجود دارد، به صفحه قبلی برگرد
    if (_history.isNotEmpty) {
      setState(() {
        selectedIndex = _history.last;
        _history.removeLast();
      });
      return false;
    }

    // اگر در داشبورد هستیم و history خالی است، اجازه خروج بده
    if (selectedIndex == dashboardIndex) {
      return true;
    }

    return true;
  }

  void _onTabChanged(int index) {
    if (index != selectedIndex) {
      setState(() {
        _history.remove(selectedIndex);
        _history.add(selectedIndex);
        selectedIndex = index;
      });
    }
  }

  void _navigateToSaleScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const Salescreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await _onWillPop();
        return shouldPop;
      },
      child: SafeArea(
        child: Scaffold(
          body: IndexedStack(
            index: selectedIndex,
            children: [
              dashboardKey.currentState == null && selectedIndex != dashboardIndex
                  ? Container()
                  : Navigator(
                      key: dashboardKey,
                      onGenerateRoute: (settings) => MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    ),
              inventoryKey.currentState == null && selectedIndex != inventoryManagementIndex
                  ? Container()
                  : Navigator(
                      key: inventoryKey,
                      onGenerateRoute: (settings) => MaterialPageRoute(
                        builder: (context) => const InventoryManagementScreen(),
                      ),
                    ),
              productsKey.currentState == null && selectedIndex != productsListIndex
                  ? Container()
                  : Navigator(
                      key: productsKey,
                      onGenerateRoute: (settings) => MaterialPageRoute(
                        builder: (context) => const ProductsListScreen(),
                      ),
                    ),
              reportsKey.currentState == null && selectedIndex != reportsIndex
                  ? Container()
                  : Navigator(
                      key: reportsKey,
                      onGenerateRoute: (settings) => MaterialPageRoute(
                        builder: (context) => const ReportsScreen(),
                      ),
                    ),
            ],
          ),
          bottomNavigationBar: BottomNavigationWithFab(
            currentIndex: selectedIndex,  
            onTap: _onTabChanged,
            onFabTap: _navigateToSaleScreen,
          ),
        ),
      ),
    );
  }
}
