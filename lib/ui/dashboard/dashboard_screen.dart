import 'package:callwich/components/extensions.dart';
import 'package:callwich/data/common/app_state_manager.dart';
import 'package:callwich/data/repository/auth_repository.dart';
import 'package:callwich/di/di.dart';
import 'package:callwich/res/dimens.dart';
import 'package:callwich/res/strings.dart';
import 'package:callwich/ui/dashboard/bloc/dashboard_bloc_bloc.dart';

import 'package:callwich/ui/producMnagement/addproduct/add_product_Screen.dart';
import 'package:callwich/ui/salesRegistrationScreen/saleScreen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/dashboard_header_widget.dart';
import '../../widgets/salesCardWidget/sales_card_widget.dart';
import '../../widgets/lowStockAlesrtWidget/low_stock_alert_widget.dart';
import '../../widgets/action_buttons_widget.dart';
import '../../widgets/salesTrendChartWidgets/sales_trend_chart_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardBloc? dashboardBlocBloc;
  @override
  void dispose() {
    dashboardBlocBloc!.close();
    _appStateManager.removeListener(_onAppStateChanged);
    super.dispose();
  }

  late final AppStateManager _appStateManager;

  @override
  void initState() {
    super.initState();
    _appStateManager = getIt<AppStateManager>();
    _appStateManager.addListener(_onAppStateChanged);
  }

  void _onAppStateChanged() {
    if (_appStateManager.shouldReloadDashboard) {
      // Trigger dashboard refresh
      dashboardBlocBloc?.add(DashboardRefresh());
      _appStateManager.resetPageReloadFlag('dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8), // neutral-50
      body: BlocProvider(
        create: (context) {
          dashboardBlocBloc = DashboardBloc();
          dashboardBlocBloc!.add(DashboardStarted());
          return dashboardBlocBloc!;
        },
        child: BlocBuilder<DashboardBloc, DashboardBlocState>(
          builder: (context, state) {
            if (state is DashboardBlocSuccess) {
              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Header (scrolls with content)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: DashboardHeaderWidget(
                                theme: theme,
                                title: AppStrings.dashboard,
                                iconButton: IconButton(
                                  onPressed: () {
                                    getIt<IAuthRepository>().singOut();
                                  },
                                  icon: Icon(Icons.logout),
                                ),
                              ),
                            ),

                            (AppDimens.large - 8).heightBox,

                            // Today's Sales Card
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: SalesCardWidget(theme: theme),
                            ),

                            AppDimens.medium.heightBox,

                            // Low Stock Alert Card
                            LowStockAlertWidget(),

                            AppDimens.medium.heightBox,

                            // Action Buttons
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: ActionButtonsWidget(
                                theme: theme,
                                onNewSale: () {
                                Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).push(
                                    MaterialPageRoute(
                                      builder: (context) => Salescreen(),
                                    ),
                                  ).then((val){
                                    val==true?BlocProvider.of<DashboardBloc>(context).add(DashboardRefresh()):(){};
                                  });

                                  
                                },
                                onAddProduct: () {
                                  // Navigator.pushNamed(context, RouteNames.productsListScreen);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddEditProductScreen(
                                            isaddProductMode: true,
                                          ),
                                    ),
                                  );
                                },
                                onAddingredients: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddEditProductScreen(
                                            isaddProductMode: false,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            AppDimens.medium.heightBox,

                            // Sales Trend Chart
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: SalesTrendChartWidget(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Navigation
                  ],
                ),
              );
            } else if (state is DashboardBlocLoading) {
              return Center(child: CircularProgressIndicator());
            }else{
              throw Exception("state not valid");
            }
          },
        ),
      ),
    );
  }
}
