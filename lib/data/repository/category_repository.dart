
import 'package:callwich/data/datasource/category_datasource.dart';
import 'package:callwich/data/models/category.dart';
import 'package:injectable/injectable.dart';

abstract class ICategoryRepository {
  Future<CategoryEntity> addCategory(String name);
  Future<List<CategoryEntity>> getCategories();
  Future<CategoryEntity> getCategoriesbyId(int id);

}

@LazySingleton(as: ICategoryRepository)
class CategoryRepository implements ICategoryRepository {
  final ICategoryDataSource categoryDataSource;
  CategoryRepository(this.categoryDataSource);
  @override
  Future<CategoryEntity> addCategory(String name) async {
    return await categoryDataSource.addCategory(name);  
  }
  
  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await categoryDataSource.getCategories();
  }
  
  @override
  Future<CategoryEntity> getCategoriesbyId(int id) {
    // TODO: implement getCategoriesbyId
    throw UnimplementedError();
  }
}