import 'dart:async';

import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/repository/ingredients_repository.dart';
import 'package:callwich/data/repository/recipes_repository.dart';
import 'package:callwich/di/di.dart';
import 'package:callwich/widgets/custom_quantity_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/recipe_bloc.dart';
import '../../widgets/dashboard_header_widget.dart';
import '../../res/strings.dart';
import '../../res/dimens.dart';
import '../../components/extensions.dart';
import '../../widgets/login_button_widget.dart';

class RecipeScreen extends StatefulWidget {
  final int productId;
  final String productName;
  final bool isEditingMode;
  final List<Map<String, dynamic>>? recpes;
  RecipeScreen({
    super.key,
    required this.productId,
    required this.productName,
    this.isEditingMode = false,
    this.recpes,
  });

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  late RecipeBloc recipeBloc;

  late StreamSubscription streamSubscription;

  @override
  void dispose() {
    recipeBloc.close();
    streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RecipeBloc>(
      create: (context) {
        recipeBloc = RecipeBloc(
          getIt<IRecipesRepository>(),
          getIt<IIngredientsRepository>(),
        );
        recipeBloc.add(
          RecipeStarted(
            isEditingMode: widget.isEditingMode,
            selectedIngredient: widget.recpes ?? [],
          ),
        );
        streamSubscription = recipeBloc.stream.listen((state) {
          if (state is AddRecipesSuccess) {
            Navigator.pop(context, true);
          }
        });
        return recipeBloc;
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFFCFAF8),
          body: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: DashboardHeaderWidget(
                      theme: theme,
                      title: AppStrings.recipes,
                      iconButton: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  AppDimens.medium.heightBox,
                  Expanded(
                    child: BlocBuilder<RecipeBloc, RecipeState>(
                      builder: (context, state) {
                        if (state is RecipeLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state is RecipeError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('خطا در بارگذاری لیست مواد اولیه'),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    recipeBloc.add(
                                      RecipeStarted(
                                        isEditingMode: widget.isEditingMode,
                                        selectedIngredient: widget.recpes ?? [],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('تلاش مجدد'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFed7c2c),
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is RecipeLoaded) {
                          final ingredients = state.ingredients;
                          if (ingredients.isEmpty) {
                            return const Center(
                              child: Text('مواد اولیه‌ای یافت نشد'),
                            );
                          }
                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.5),
                                  border: Border(
                                    top: BorderSide(
                                      color: theme.colorScheme.primary,
                                    ),
                                    bottom: BorderSide(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "مواد اولیه را برای  ${widget.productName} انتخاب کنید",
                                  style: theme.textTheme.titleSmall!.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ListView.separated(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          12,
                                          16,
                                          50,
                                        ),
                                        itemBuilder: (context, index) {
                                          final item = ingredients[index];
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                            
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.name,
                                                        style: theme
                                                            .textTheme
                                                            .titleMedium,
                                                      ),
                                                      4.heightBox,
                                                      // Text(
                                                      //   'واحد: ${item.unit}',
                                                      //   style: theme
                                                      //       .textTheme
                                                      //       .bodySmall
                                                      //       ?.copyWith(
                                                      //         color:
                                                      //             const Color(
                                                      //               0xFF9A6C4C,
                                                      //             ),
                                                      //       ),
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                                CustomQuantityTextField(
                                                  // keyValue:
                                                  //     'qty_${item.id}_${item.quantity}',
                                                  initialValue: state
                                                      .ingredients[index]
                                                      .quantity
                                                      .toString(),

                                                  width: 100,
                                                  hintText: '0',
                                                  textAlign: TextAlign.center,
                                                  // onChanged: (value) {
                                                  //   final parsed = int.tryParse(
                                                  //     value.trim(),
                                                  //   );
                                                  //   if (parsed != null &&
                                                  //       parsed > 0) {
                                                  //     context.read<RecipeBloc>().add(
                                                  //       SetIngredientQuantity(
                                                  //         ingredientId: item.id,
                                                  //         quantity: parsed,
                                                  //         isEditingMode: widget
                                                  //             .isEditingMode,
                                                  //       ),
                                                  //     );
                                                  //   }
                                                  // },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 12),
                                        itemCount: ingredients.length,
                                      ),
                                    ),

                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          16,
                                        ),
                                        child: LoginButtonWidget(
                                          onPressed: () {
                                            recipeBloc.add(
                                              OnSaveBtnClicked(
                                                widget.productId,
                                                ingredients.cast<IngredientEntity>(),

                                                isEditingMode:
                                                    widget.isEditingMode,
                                              ),
                                            );
                                          },
                                          mainColor: const Color(0xFFed7c2c),
                                          label: AppStrings.save,
                                          enabled: true,
                                          loading: state.isdLoading,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
