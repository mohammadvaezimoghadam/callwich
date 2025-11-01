import 'package:callwich/data/common/app_state_manager.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/repository/category_repository.dart';
import 'package:callwich/data/repository/ingredients_repository.dart';
import 'package:callwich/data/repository/product_repository.dart';
import 'package:callwich/di/di.dart';
import 'package:callwich/ui/producMnagement/addproduct/add_product_Screen.dart';
import 'package:callwich/ui/producMnagement/bloc/product_list_bloc.dart';
import 'package:callwich/ui/producMnagement/productdetails/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/dashboard_header_widget.dart';
import '../../widgets/products_search_bar_widget.dart';
import '../../widgets/products_tabs_widget.dart';
import '../../widgets/products_grid_widget.dart';
import '../../res/strings.dart';
import '../../res/dimens.dart';
import '../../widgets/products_list_skeleton_widget.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  int _selectedTabIndex = 0;
  int _selectedCategoryId = 0;
  List<IngredientEntity> ingredients = [];
  late final AppStateManager _appStateManager;
  late ProductListBloc? bloc;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _appStateManager = getIt<AppStateManager>();
    _appStateManager.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    bloc?.close();  
    _appStateManager.removeListener(_onAppStateChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onAppStateChanged() {
    if (_appStateManager.shouldReloadProducts) {
      // Trigger products refresh by recreating the bloc
      bloc?.add(ProductListStarted());
      _appStateManager.resetPageReloadFlag('products');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocProvider<ProductListBloc>(
          create: (context) {
             bloc = ProductListBloc(
              getIt<ICategoryRepository>(),
              getIt<IProductRepository>(),
              getIt<IIngredientsRepository>(),
            );
            bloc?.stream.listen((state) {
              if (state is ProductListSuccess) {
                _selectedCategoryId = state.selectedCategoryId;
                ingredients = state.ingredients;
                state.selectedTabIndex!=null?setState(() {
                  _selectedTabIndex=state.selectedTabIndex!;
                }):(){};
              }
            });
            bloc?.add(ProductListStarted());
            return bloc!;
          },
          child: Scaffold(
            body: BlocBuilder<ProductListBloc, ProductListState>(
              builder: (context, state) {
                if (state is ProductListSuccess) {
                  return Column(
                    children: [
                      // Header
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.medium.toDouble(),
                          vertical: AppDimens.medium.toDouble(),
                        ),
                        child: DashboardHeaderWidget(
                          title: AppStrings.products,
                          iconButton: null,
                          theme: theme,
                        ),
                      ),

                      // Search Bar
                      ProductsSearchBarWidget(
                        searchController: _searchController,
                        theme: theme,
                        onSubmit: (String searchTerm) {
                          if (_searchController.text.isNotEmpty) {
                            BlocProvider.of<ProductListBloc>(context).add(
                              OnSubmitEvent(
                                _selectedCategoryId,
                                searchTerm: searchTerm,
                              ),
                            );
                          }
                        },
                      ),

                      // Tabs
                      state.searchMode == true
                          ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("نتایج جستجو"),
                                IconButton(
                                  onPressed: () {
                                    BlocProvider.of<ProductListBloc>(
                                      context,
                                    ).add(
                                      OnTabChangeEvent(
                                        categoryId: _selectedCategoryId,
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.close),
                                ),
                              ],
                            ),
                          )
                          : ProductsTabsWidget(
                            tabs: state.categories,
                            selectedTabIndex: _selectedTabIndex,
                            onTabChanged: ({
                              required categoryId,
                              required index,
                            }) {
                              setState(() {
                                _selectedTabIndex = index;
                                _selectedCategoryId = categoryId;
                                BlocProvider.of<ProductListBloc>(
                                  context,
                                ).add(OnTabChangeEvent(categoryId: categoryId));
                              });
                            },
                            theme: theme,
                          ),

                      // Products Grid
                      Expanded(
                        child:
                            state.gridLoading
                                ? Center(child: CircularProgressIndicator())
                                : ProductsGridWidget(
                                  products: state.products,

                                  theme: theme,
                                  onProductTap: (product) async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ProductDetailsScreen(
                                              product: product,
                                              ingredients: ingredients,
                                            ),
                                      ),
                                    );

                                    // اگر محصول ویرایش شد، لیست را به‌روزرسانی کن
                                    // if (result == true) {
                                    //   BlocProvider.of<ProductListBloc>(
                                    //     context,
                                    //   ).add(
                                    //     ProductListStarted(
                                    //       categoryId: _selectedCategoryId,
                                    //     ),
                                    //   );
                                    // }
                                  },
                                ),
                      ),
                    ],
                  );
                } else if (state is ProductListError) {
                  return Center(
                    child: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        BlocProvider.of<ProductListBloc>(
                          context,
                        ).add(ProductListStarted());
                      },
                    ),
                  );
                } else if (state is ProductListLoading) {
                  return ProductsListSkeletonWidget(theme: theme);
                } else {
                  throw Exception("state is not valid");
                }
              },
            ),

            // Floating Action Button
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            const AddEditProductScreen(isaddProductMode: true),
                  ),
                );

                // اگر محصول جدید اضافه شد، لیست را به‌روزرسانی کن
                // if (result == true) {
                //   BlocProvider.of<ProductListBloc>(
                //     context,
                //   ).add(ProductListStarted());
                // }
              },
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.add,
                color: theme.colorScheme.onPrimary,
                size: 28,
              ),
            ),

            // Bottom Navigation
          ),
        ),
      ),
    );
  }

}
