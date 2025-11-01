
import 'package:callwich/data/common/http_response_validator.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class IIngredientsDatasource {
  Future<IngredientEntity> creatIngredient({
    required String name,
    required String unit,
    required double purchasePrice,
    required double stock,
    required double minStock,
    required bool isActive,
  });
  Future<List<IngredientEntity>> getAllIngredients();
  Future<IngredientEntity> getIngredientById();
  Future<void> deletIngredients(int ingredientId);
  Future<IngredientEntity> updateIngrediant({
    required int ingredientId,
    required String name,
    required String unit,
    required double purchasePrice,
    required double stock,
    required double minStock,
    required bool isActive,
  });

}

@LazySingleton(as: IIngredientsDatasource)
class IngredientsDatasource
    with HttpResponseValidatorMixin
    implements IIngredientsDatasource {
  final Dio httpClient;

  IngredientsDatasource({required this.httpClient});
  @override
  Future<IngredientEntity> creatIngredient({
    required String name,
    required String unit,
    required double purchasePrice,
    required double stock,
    required double minStock,
    required bool isActive,
  }) async {
    final response = await httpClient.post(
      "ingredients/",
      data: {
        "name": name,
        "unit": unit,
        "purchase_price": purchasePrice,
        "stock": stock,
        "min_stock": minStock,
        "is_active": isActive,
      },
    );
    validateResponse(response);

    return IngredientEntity.fromJson(response.data);
  }

  @override
  Future<List<IngredientEntity>> getAllIngredients() async {
    final response = await httpClient.get("ingredients/");
    validateResponse(response);
    final List<IngredientEntity> ingredients = [];
    (response.data as List).forEach((element) {
      ingredients.add(IngredientEntity.fromJson(element));
    });
    return ingredients;
  }

  @override
  Future<IngredientEntity> getIngredientById() {
    // TODO: implement getIngredientById
    throw UnimplementedError();
  }

  @override
  Future<IngredientEntity> updateIngrediant({
    required int ingredientId,
    required String name,
    required String unit,
    required double purchasePrice,
    required double stock,
    required double minStock,
    required bool isActive,
  }) async {
    final response = await httpClient.put(
      "ingredients/$ingredientId",
      data: {
        "name": name,
        "unit": unit,
        "purchase_price": purchasePrice,
        "stock": stock,
        "min_stock": minStock,
        "is_active": isActive,
      },
    );

    validateResponse(response);
    return IngredientEntity.fromJson(response.data);
  }
  
  @override
  Future<void> deletIngredients(int ingredientId) async{
    return  await httpClient.delete("ingredients/$ingredientId").then((response) {
      validateResponse(response);
      return;
    });
  }
  }

