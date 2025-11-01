import 'package:callwich/data/datasource/ingredients_datasource.dart';
import 'package:injectable/injectable.dart';
import 'package:callwich/data/models/ingredient.dart';



abstract class IIngredientsRepository {
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
Future<void> deletIngredient(int ingredientId);
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

@LazySingleton(as: IIngredientsRepository)
class IngredientsRepository implements IIngredientsRepository {
  final IIngredientsDatasource ingredientsDatasource;

  IngredientsRepository({required this.ingredientsDatasource});
  @override
  Future<IngredientEntity> creatIngredient({
    required String name,
    required String unit,
    required double purchasePrice,
    required double stock,
    required double minStock,
    required bool isActive,
  }) async {
    return await ingredientsDatasource.creatIngredient(
      name: name,
      unit: unit,
      purchasePrice: purchasePrice,
      stock: stock,
      minStock: minStock,
      isActive: isActive,
    );
  }

  @override
  Future<List<IngredientEntity>> getAllIngredients() async {
    return await ingredientsDatasource.getAllIngredients();
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
    return await ingredientsDatasource.updateIngrediant(
      ingredientId: ingredientId,
      name: name,
      unit: unit,
      purchasePrice: purchasePrice,
      stock: stock,
      minStock: minStock,
      isActive: isActive,
    );
  }
  
  @override
  Future<void> deletIngredient(int ingredientId) async{
    await ingredientsDatasource.deletIngredients(ingredientId);
  }
}
