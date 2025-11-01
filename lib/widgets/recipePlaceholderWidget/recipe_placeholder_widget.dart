import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/repository/recipes_repository.dart';
import 'package:callwich/di/di.dart';
import 'package:callwich/ui/recipeScreen/recipeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/recipe_placeholder_bloc.dart';

class RecipePlaceholderWidget extends StatelessWidget {
  final List<IngredientEntity> ingredients;
  final String productName;
  final int productId;
  final String message;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const RecipePlaceholderWidget({
    Key? key,
    required this.productId,
    required this.ingredients,
    required this.productName,
    this.message = "دستور تهیه یافت نشد",
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create:
          (context) => RecipePlaceholderBloc(getIt<IRecipesRepository>())..add(
            RecipePlaceholderStarted(
              productId: productId,
              ingredients: ingredients,
            ),
          ),

      child: BlocBuilder<RecipePlaceholderBloc, RecipePlaceholderState>(
        builder: (context, state) {
          if (state is RecipePlaceholderLoading) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor ?? const Color(0xFFf3ece7),
                borderRadius: borderRadius ?? BorderRadius.circular(12),
              ),
              padding: padding ?? const EdgeInsets.all(16),
              child: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is RecipePlaceholderSuccess) {
            if (state.ingredients.isNotEmpty) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'دستور تهیه',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                            size: 18,
                          ),
                          tooltip: 'ویرایش دستور تهیه',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => RecipeScreen(
                                      productId: productId,
                                      productName: productName,
                                      isEditingMode: true,
                                      recpes: state.ingredients,
                                    ),
                              ),
                            ).then((onValue) {
                            onValue==true?  BlocProvider.of<RecipePlaceholderBloc>(
                                context,
                              ).add(
                                RecipePlaceholderStarted(
                                  productId: productId,
                                  ingredients: ingredients,
                                ),
                              ):(){};
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: backgroundColor ?? const Color(0xFFf3ece7),
                      borderRadius: borderRadius ?? BorderRadius.circular(12),
                    ),
                    padding: padding ?? const EdgeInsets.all(16),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: ListView.builder(
                        itemCount: state.ingredients.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> item = state.ingredients[index];
                          IngredientEntity ingredient = item["ingreEntity"];
                          int quantity = item["quantity"];
                          return _infoRow(
                            label: ingredient.name,
                            value: quantity.toString(),
                            theme: theme,
                            unit: ingredient.unit,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Container(
                decoration: BoxDecoration(
                  color: backgroundColor ?? const Color(0xFFf3ece7),
                  borderRadius: borderRadius ?? BorderRadius.circular(12),
                ),
                padding: padding ?? const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          textColor ??
                          theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          } else if (state is RecipePlaceholderError) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: borderRadius ?? BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              padding: padding ?? const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[600], size: 24),
                  const SizedBox(height: 8),
                  Text(
                    state.appException.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context.read<RecipePlaceholderBloc>().add(
                        RecipePlaceholderStarted(
                          productId: productId,
                          ingredients: ingredients,
                        ),
                      );
                    },
                    child: const Text('تلاش مجدد'),
                  ),
                ],
              ),
            );
          }

          // Default fallback
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor ?? const Color(0xFFf3ece7),
              borderRadius: borderRadius ?? BorderRadius.circular(12),
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: Center(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      textColor ?? theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
    required ThemeData theme,
    required String unit,
    bool border = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration:
          border
              ? const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFe7d9cf))),
              )
              : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9a6c4c),
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Text(
                unit,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
