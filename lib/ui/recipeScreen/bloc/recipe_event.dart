part of 'recipe_bloc.dart';

sealed class RecipeEvent {
  final bool isEditingMode;
  const RecipeEvent({required this.isEditingMode});
}

final class RecipeStarted extends RecipeEvent {
  final List<Map<String, dynamic>> selectedIngredient;
  const RecipeStarted({
    required super.isEditingMode,
    required this.selectedIngredient,
  });
}

final class SetIngredientQuantity extends RecipeEvent {
  final int ingredientId;
  final int quantity;
  const SetIngredientQuantity({
    required super.isEditingMode,
    required this.ingredientId,
    required this.quantity,
  });
}

final class OnSaveBtnClicked extends RecipeEvent {
  final List<IngredientEntity> ingredients;
  final int productId;

  OnSaveBtnClicked(
    this.productId,
    this.ingredients, {
    required super.isEditingMode,
  });
}
