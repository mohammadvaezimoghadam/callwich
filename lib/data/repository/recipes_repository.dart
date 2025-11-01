import 'package:callwich/data/datasource/recipes_datasource.dart';
import 'package:injectable/injectable.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/models/recipe.dart';



abstract class IRecipesRepository {
  Future<void> creatRecipes({
    required int productId,
    required List<IngredientEntity> ingredients,
  });

  Future<List<RecipeEntity>> updateRecipe({
    required int productId,
    required List<IngredientEntity> ingredients,
  });
  Future<List<RecipeEntity>> getRecipeaByProductId({required int productId});
}

@LazySingleton(as: IRecipesRepository)
class RecipesRepository implements IRecipesRepository {
  final IRecipesDataSource recipesDataSource;

  RecipesRepository({required this.recipesDataSource});
  @override
  Future<void> creatRecipes({
    required int productId,
    required List<IngredientEntity> ingredients,
  }) async {
    await recipesDataSource.creatRecipes(
      productId: productId,
      ingredients: ingredients,
    );
  }

  @override
  Future<List<RecipeEntity>> getRecipeaByProductId({
    required int productId,
  }) async {
    return await recipesDataSource.getRecipeaByProductId(productId: productId);
  }

  @override
  Future<List<RecipeEntity>> updateRecipe({
    required int productId,
    required List<IngredientEntity> ingredients,
  }) async {
    return await recipesDataSource.updateRecipe(
      productId: productId,
      ingredients: ingredients,
    );
  }
}
