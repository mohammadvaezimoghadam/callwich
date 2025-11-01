import 'package:callwich/data/datasource/product_datasource.dart';
import 'package:callwich/data/models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

abstract class IProductRepository {
  Future<ProductEntity> creatProduct(
    String name,
    int sellingPrice,
    int? purchasePrice, // int → double
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

@LazySingleton(as: IProductRepository)
class ProductRepository implements IProductRepository {
  final IProductDataSource productDataSource;
  ProductRepository({required this.productDataSource});
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
    final product = await productDataSource.creatProduct(
      name,
      sellingPrice,
      purchasePrice,
      categoryId,
      stock,
      minStock,
      isActive,
      image,
      type,
    );
    return product;
  }

  @override
  Future<void> deletProduct(int productId) async {
    await productDataSource.deletProduct(productId);
    return;
  }

  @override
  Future<ProductEntity> getProductById(int productId) {
    // TODO: implement getProductById
    throw UnimplementedError();
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    return await productDataSource.getProducts();
  }

  @override
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
  ) async {
    return await productDataSource.updateProduct(
      productId,
      name,
      sellingPrice,
      purchasePrice,
      categoryId,
      stock,
      minStock,
      isActive,
      image,
      type,
    );
  }

  @override
  Future<List<ProductEntity>> getActiveProduct() {
    // TODO: implement getActiveProduct
    throw UnimplementedError();
  }
}
