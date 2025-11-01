import 'package:callwich/data/common/http_response_validator.dart';
import 'package:callwich/data/models/product.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

abstract class IProductDataSource {
  Future<ProductEntity> creatProduct(
    String name,
    int sellingPrice,
    int? purchasePrice,
    int categoryId,
    int? stock, // int? → double?
    int? minStock, // int? → double?
    bool? isActive,
    XFile image,
    String type,
  );
  Future<List<ProductEntity>> getProducts();
  Future<ProductEntity> getProductById(int productId);
  Future<ProductEntity> updateProduct(
    int productId,
    String name,
    double sellingPrice, // int → double
    double? purchasePrice, // int → double
    int? categoryId,
    double? stock, // int → double
    double? minStock, // int → double
    bool? isActive,
    XFile? image,
    String? type,
  );
  Future<void> deletProduct(int productId);
  Future<List<ProductEntity>> getActiveProduct();
}

@LazySingleton(as: IProductDataSource)
class ProductDataSource
    with HttpResponseValidatorMixin
    implements IProductDataSource {
  final Dio httpClient;

  ProductDataSource({required this.httpClient});
  @override
  Future<ProductEntity> creatProduct(
    String name,
    int sellingPrice,
    int? purchasePrice,
    int categoryId,
    int? stock,
    int? minStock,
    bool? isActive,
    XFile image,
    String type,
  ) async {
    final formData = FormData.fromMap({
      'name': name, // String
      'selling_price': sellingPrice, // int
      'category_id': categoryId, // int?
      if (stock != null) 'stock': stock, // int?
      if (minStock != null) 'min_stock': minStock, // int?
      if (isActive != null) 'is_active': isActive, // bool?
      if (purchasePrice != null)
        'purchase_price': purchasePrice, // int? (برای purchased اجباری)
      'type': type, // 'manufactured' | 'purchased'
      'image': await MultipartFile.fromFile(
        image.path,
        filename: image.name,
        contentType: MediaType(
          'image',
          image.mimeType?.split('/').last ?? 'jpeg',
        ),
      ),
    });

    // مثال: اگر محصول خریداری‌شده است، اطمینان از وجود purchase_price
    if (type == 'purchased' && (purchasePrice == null || purchasePrice == 0)) {
      throw Exception(
        'برای محصولات purchased، فیلد purchase_price الزامی و > 0 است.',
      );
    }

    final response = await httpClient.post(
      'products/',
      data: formData,
      // Dio خودش multipart می‌گذارد؛ گذاشتن دستی لازم نیست، اما اشکالی هم ندارد:
      // options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    validateResponse(response);
    final product = ProductEntity.fromJson(response.data);
    return product;
  }

  @override
  Future<void> deletProduct(int productId) async {
    final response = await httpClient.delete('products/${productId.toDouble()}');
    validateResponse(response);
    return;
  }

  @override
  Future<ProductEntity> getProductById(int productId) {
    // TODO: implement getProductById
    throw UnimplementedError();
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    final response = await httpClient.get("products/");
    validateResponse(response);
    final List<ProductEntity> products = [];
    (response.data as List).forEach((element) {
      products.add(ProductEntity.fromJson(element));
    });
    return products;
  }

  @override
  Future<ProductEntity> updateProduct(
    int productId,
    String name,
    double sellingPrice,
    double? purchasePrice,
    int? categoryId,
    double? stock,
    double? minStock,
    bool? isActive,
    XFile? image,
    String? type,
  ) async {
    final formData = FormData.fromMap({
      'name': name, // String
      'selling_price': sellingPrice, // int
      if (categoryId != null) 'category_id': categoryId, // int?
      if (stock != null) 'stock': stock, // int?
      if (minStock != null) 'min_stock': minStock, // int?
      if (isActive != null) 'is_active': isActive, // bool?
      if (purchasePrice != null)
        'purchase_price': purchasePrice, // int? (برای purchased اجباری)
      'type': type, // 'manufactured' | 'purchased'
     if (image != null) 'image': await MultipartFile.fromFile(
        image.path,
        filename: image.name,
        contentType: MediaType(
          'image',
          image.mimeType?.split('/').last ?? 'jpeg',
        ),
      ),
    });
    final response = await httpClient.put(
      'products/$productId',
      data: formData,
    );
    validateResponse(response);
    return ProductEntity.fromJson(response.data);
  }

  @override
  Future<List<ProductEntity>> getActiveProduct() {
    // TODO: implement getActiveProduct
    throw UnimplementedError();
  }
}
