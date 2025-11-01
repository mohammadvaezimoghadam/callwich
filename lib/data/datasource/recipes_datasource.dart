import 'package:callwich/data/common/http_response_validator.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/models/recipe.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class IRecipesDataSource {
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

@LazySingleton(as: IRecipesDataSource)
class RecipesDatasource
    with HttpResponseValidatorMixin
    implements IRecipesDataSource {
  final Dio httpClient;

  RecipesDatasource({required this.httpClient});
  @override
  Future<void> creatRecipes({
    required int productId,
    required List<IngredientEntity> ingredients,
  }) async {
    final items =
        ingredients.map((ingredient) {
          return {
            "ingredient_id": ingredient.id,
            "quantity": ingredient.quantity,
          };
        }).toList();

    final data = {"product_id": productId, "ingredients": items};

    final response = await httpClient.post("recipes/", data: data);
    validateResponse(response);
  }

  @override
  Future<List<RecipeEntity>> getRecipeaByProductId({
    required int productId,
  }) async {
    final response = await httpClient.get("recipes/$productId");
    validateResponse(response);

    final List<RecipeEntity> recipes = [];
    (response.data as List).forEach((element) {
      recipes.add(RecipeEntity.fromJson(element));
    });
    return recipes;
  }

  @override
  Future<List<RecipeEntity>> updateRecipe({
    required int productId,
    required List<IngredientEntity> ingredients,
  }) async {
    final items =
        ingredients.map((ingredient) {
          return {
            "ingredient_id": ingredient.id,
            "quantity": ingredient.quantity,
          };
        }).toList();

    final data = {"product_id": productId, "ingredients": items};

    final response = await httpClient.put("recipes/$productId", data: data);

    validateResponse(response);
    final List<RecipeEntity> recipes = [];
    (response.data as List).forEach((element) {
      recipes.add(RecipeEntity.fromJson(element));
    });
    return recipes;
  }
}
