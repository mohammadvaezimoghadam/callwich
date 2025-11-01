import 'package:callwich/data/common/app_state_manager.dart';
import 'package:callwich/data/repository/ingredients_repository.dart';
import 'package:callwich/data/repository/product_repository.dart';
import 'package:callwich/di/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:callwich/data/repository/reports_repository.dart';
import 'package:callwich/ui/reportsScreen/bloc/reports_bloc.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedTabIndex = 0;
  late ReportsBloc? _reportsBloc;
  late final AppStateManager _appStateManager;

  @override
  void initState() {
    super.initState();
    _appStateManager = getIt<AppStateManager>();
    _reportsBloc = ReportsBloc(
      reportsRepository: getIt<IReportsRepository>(),
      ingredientsRepository: getIt<IIngredientsRepository>(),
      productRepository: getIt<IProductRepository>(),
    );
    _reportsBloc?.add(ReportsStarted());
    _appStateManager.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    _reportsBloc?.close();
    _appStateManager.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() {
    if (_appStateManager.shouldReloadReports) {
      // Trigger reports refresh
      _reportsBloc?.add(ReportsStarted());
      _appStateManager.resetPageReloadFlag('reports');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFfcfaf8),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                color: const Color(0xFFfcfaf8).withOpacity(0.8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'گزارشات',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // For symmetry
                      ],
                    ),
                    // Tabs
                    Container(
                      decoration: const BoxDecoration(
                        border: const Border(
                          bottom: BorderSide(color: Color(0xFFe7d9cf)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _tabButton('گزارش موجودی', 0, theme)),
                          Expanded(child: _tabButton('گزارش سود', 1, theme)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: BlocBuilder<ReportsBloc, ReportsState>(
                  bloc: _reportsBloc,
                  builder: (context, state) {
                    if (state is ReportsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ReportsError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text('خطا در بارگذاری گزارشات'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed:
                                  () => _reportsBloc?.add(ReportsRefresh()),
                              child: const Text('تلاش مجدد'),
                            ),
                          ],
                        ),
                      );
                    } else if (state is ReportsSuccess) {
                      return _selectedTabIndex == 0
                          ? _inventoryReport(theme, state)
                          : _profitReport(theme);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String label, int index, ThemeData theme) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFFed7c2c) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color:
                isSelected ? const Color(0xFFed7c2c) : const Color(0xFF9a6c4c),
          ),
        ),
      ),
    );
  }

  Widget _inventoryReport(ThemeData theme, ReportsSuccess state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'گزارش موجودی',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFe7d9cf)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFf3ece7),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'نام',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1b130d),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'نوع',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1b130d),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'موجودی',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1b130d),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rows - Products
                  ...List.generate(state.allProducts.length, (index) {
                    final product = state.allProducts[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: const Color(0xFFe7d9cf)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                product.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF9a6c4c),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                'محصول',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1b130d),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                '${product.stock} ${product.type == 'purchased' ? 'عدد' : 'گرم'}',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1b130d),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // Rows - Ingredients
                  ...List.generate(state.allIngredients.length, (index) {
                    final ingredient = state.allIngredients[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color:
                                index == state.allIngredients.length - 1
                                    ? Colors.transparent
                                    : const Color(0xFFe7d9cf),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                ingredient.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF9a6c4c),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                'مواد اولیه',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1b130d),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                '${ingredient.stock} ${ingredient.unit}',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1b130d),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profitReport(ThemeData theme) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'گزارش سود و زیان',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder for profit report
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFe7d9cf)),
              ),
              child: const Center(
                child: Text(
                  'گزارش سود به زودی اضافه خواهد شد',
                  style: TextStyle(color: Color(0xFF9a6c4c)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
