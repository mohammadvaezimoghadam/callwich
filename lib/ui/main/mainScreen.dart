import 'package:callwich/data/repository/auth_repository.dart';
import 'package:callwich/ui/auth/splash/cubit/auth_cubit.dart';
import 'package:callwich/ui/dashboard/dashboard_screen.dart';
import 'package:callwich/ui/inventoryManagementScreen/inventory_management_screen.dart';
import 'package:callwich/ui/producMnagement/products_list_screen.dart';
import 'package:callwich/ui/reportsScreen/reports_screen.dart';
import 'package:callwich/widgets/bottom_navigation_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

const dashboardIndex = 0;
const inventoryManagementIndex = 1;
const productsListIndex = 2;
const reportsIndex = 3;

class _MainScreenState extends State<MainScreen> {
  int selecteScreenIndex = dashboardIndex;

  final List<int> history = [];

  final GlobalKey<NavigatorState> _dashboardKey = GlobalKey();
  final GlobalKey<NavigatorState> _inventoryManagemenKey = GlobalKey();
  final GlobalKey<NavigatorState> _productListKey = GlobalKey();
  final GlobalKey<NavigatorState> _reportsKey = GlobalKey();

  late final Map<int, GlobalKey<NavigatorState>> map = {
    dashboardIndex: _dashboardKey,
    inventoryManagementIndex: _inventoryManagemenKey,
    productsListIndex: _productListKey,
    reportsIndex: _reportsKey,
  };

 

  @override
  void initState() {
    super.initState();
   
    // گوش دادن به تغییرات auth
    AuthRepository.authChangeNotifier.addListener(_onAuthChanged);
    // گوش دادن به تغییرات global state
   // _appStateManager.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    // حذف listener هنگام dispose شدن
    AuthRepository.authChangeNotifier.removeListener(_onAuthChanged);
   // _appStateManager.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    BlocProvider.of<AuthCubit>(
      context,
    ).authChanged(AuthRepository.authChangeNotifier.value);
  }



  Future<bool> _onWillPop() async {
    final currentNavigator = map[selecteScreenIndex]?.currentState;

    // اگر در صفحه فعلی امکان pop وجود دارد
    if (currentNavigator != null && currentNavigator.canPop()) {
      currentNavigator.pop();
      return false;
    }

    // اگر history وجود دارد، به صفحه قبلی برگرد
    if (history.isNotEmpty) {
      setState(() {
        selecteScreenIndex = history.last;
        history.removeLast();
      });
      return false;
    }

    // اگر در داشبورد هستیم و history خالی است، اجازه خروج بده
    if (selecteScreenIndex == dashboardIndex) {
      return true;
    }

    // اگر در تب دیگری هستیم، به داشبورد برگرد
    setState(() {
      selecteScreenIndex = dashboardIndex;
      history.clear();
    });
    return false;
  }

  void _onTabChanged(int index) {
    if (index != selecteScreenIndex) {
      setState(() {
        // صفحه فعلی را به history اضافه کن
        if (selecteScreenIndex != dashboardIndex) {
          // dashboard را به history اضافه نکن
          history.add(selecteScreenIndex);
        }
        selecteScreenIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop) {
            // اگر واقعاً باید از اپ خارج شود
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: selecteScreenIndex,
          children: [
            Navigator(
              key: _dashboardKey,
              onGenerateRoute:
                  (settings) => MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
            ),
            Navigator(
              key: _inventoryManagemenKey,
              onGenerateRoute:
                  (settings) => MaterialPageRoute(
                    builder: (context) => const InventoryManagementScreen(),
                  ),
            ),
            Navigator(
              key: _productListKey,
              onGenerateRoute:
                  (settings) => MaterialPageRoute(
                    builder: (context) => const ProductsListScreen(),
                  ),
            ),
            Navigator(
              key: _reportsKey,
              onGenerateRoute:
                  (settings) => MaterialPageRoute(
                    builder: (context) => const ReportsScreen(),
                  ),
            ),
          ],
        ),

        bottomNavigationBar: BottomNavigationWidget(
          currentIndex: selecteScreenIndex,
          onTap: _onTabChanged,
        ),
      ),
    );
  }
}
