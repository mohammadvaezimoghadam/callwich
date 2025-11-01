class ProductEntity {
  final int id;
  final String name;
  final String sellingPrice;
  final String purchasePrice;
  final int categoryId;
  final String stock;
  final String minStock;
  final String imageUrl;
  final bool isActive;
  final String categoryName;
  final String type;

  ProductEntity({
    required this.id,
    required this.name,
    required this.sellingPrice,
    required this.purchasePrice,
    required this.categoryId,
    required this.stock,
    required this.minStock,
    required this.imageUrl,
    required this.isActive,
    required this.categoryName,
    required this.type,
  });

  ProductEntity.fromJson(Map<String, dynamic> json)
    : id = json["id"],
      name = json["name"],
      sellingPrice = json["selling_price"].toString(),
      purchasePrice = json["purchase_price"].toString(),
      categoryId = json["category_id"],
      stock = json["stock"].toString(),
      minStock = json["min_stock"].toString(),
      imageUrl = json["image"],
      isActive = json["is_active"],
      categoryName = json["category"]["name"],
      type = json["type"];
}
