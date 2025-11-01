import 'package:callwich/data/common/http_response_validator.dart';
import 'package:callwich/data/models/category.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

abstract class ICategoryDataSource {
  Future<CategoryEntity> addCategory(String name);
  Future<List<CategoryEntity>> getCategories();
  Future<CategoryEntity> getCategoriesbyId(int id);
}

@LazySingleton(as: ICategoryDataSource)
class CategoryDataSource
    with HttpResponseValidatorMixin
    implements ICategoryDataSource {
  final Dio httpClient;
  CategoryDataSource(this.httpClient);
  @override
  Future<CategoryEntity> addCategory(String name) async {
    
    final response = await httpClient.post(
      'categories/',
      data: {
        "name":name
      },
      options: Options(contentType: "application/json"),
    );
    validateResponse(response);
    return CategoryEntity.fromJson(response.data);
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final response = await httpClient.get('categories/');
    validateResponse(response);
    final List<CategoryEntity> categories = [];
    (response.data as List).forEach((element) {
      categories.add(CategoryEntity.fromJson(element));
    });
    return categories;
  }

  @override
  Future<CategoryEntity> getCategoriesbyId(int id) {
    // TODO: implement getCategoriesbyId
    throw UnimplementedError();
  }
}
