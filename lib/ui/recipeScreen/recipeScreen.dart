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
            // Return true when recipes are successfully saved
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFed7c2c)),
                                ),
                                SizedBox(height: 16),
                                Text('در حال بارگذاری مواد اولیه...'),
                              ],
                            ),
                          );
                        }
                        if (state is RecipeError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'خطا در بارگذاری لیست مواد اولیه',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.appException.message,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
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
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 64,
                                    color: Color(0xFF9ca3af),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'مواد اولیه‌ای یافت نشد',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF6b7280),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'لطفاً ابتدا مواد اولیه تعریف کنید',
                                    style: TextStyle(
                                      color: Color(0xFF9ca3af),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: [
                              // Product info banner
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFed7c2c).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFed7c2c),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFed7c2c),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.fastfood,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'دستور پخت برای:',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF6b7280),
                                            ),
                                          ),
                                          Text(
                                            widget.productName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1f2937),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Column(
                                        children: [
                                          // Header for ingredients list
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.05),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Row(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'مواد اولیه',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF1f2937),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'مقدار مصرفی',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF1f2937),
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Ingredients list
                                          Expanded(
                                            child: ListView.separated(
                                              padding: const EdgeInsets.fromLTRB(
                                                16,
                                                0,
                                                16,
                                                80,
                                              ),
                                              itemBuilder: (context, index) {
                                                // Since the ingredients are RecipeScreenModel objects, we need to handle them properly
                                                final item = ingredients[index];
                                                return _buildIngredientItem(
                                                  context,
                                                  item,
                                                  index,
                                                  state,
                                                  theme,
                                                );
                                              },
                                              separatorBuilder: (context, index) =>
                                                  const SizedBox(height: 12),
                                              itemCount: ingredients.length,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Save button at bottom
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          16,
                                          16,
                                          16,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withOpacity(0.1),
                                              Colors.white,
                                              Colors.white,
                                            ],
                                          ),
                                        ),
                                        child: LoginButtonWidget(
                                          onPressed: () {
                                            recipeBloc.add(
                                              OnSaveBtnClicked(
                                                widget.productId,
                                                ingredients.cast<IngredientEntity>(),
                                                isEditingMode: widget.isEditingMode,
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

  Widget _buildIngredientItem(
    BuildContext context,
    dynamic item, // Changed to dynamic since it's RecipeScreenModel
    int index,
    RecipeLoaded state,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ingredient icon and name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFf3f4f6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Color(0xFF9ca3af),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? 'بدون نام',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1f2937),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'شناسه: ${item.ingredientId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9ca3af),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity input
          Expanded(
            flex: 2,
            child: CustomQuantityTextField(
              initialValue: item.quantity.toString(),
              width: double.infinity,
              hintText: '0',
              textAlign: TextAlign.center,
              onChanged: (value) {
                final parsed = int.tryParse(value.trim());
                if (parsed != null) {
                  // Update the quantity in the bloc
                  context.read<RecipeBloc>().add(
                    SetIngredientQuantity(
                      isEditingMode: widget.isEditingMode,
                      ingredientId: item.ingredientId,
                      quantity: parsed,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}