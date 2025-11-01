class IngredientEntity {
  final int id;
  final String name;
  final String unit;
  final String purchasePrice;
  final String stock;
  final String minStock;
  final bool isActive;
  int quantity;
  bool isSelected;
  bool isdLoading;
  int quantityInProduct;

  IngredientEntity({
    required this.id,
    required this.name,
    required this.unit,
    required this.purchasePrice,
    required this.stock,
    required this.minStock,
    required this.isActive,
    this.quantity = 0,
    this.isSelected = false,
    this.isdLoading = false,
    this.quantityInProduct = 0,
  });

  IngredientEntity.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        name = json["name"],
        unit = json["unit"],
        purchasePrice = json["purchase_price"].toString(),
        stock = json["stock"].toString(),
        minStock = json["min_stock"].toString(),
        isActive = json["is_active"],
        quantity = 0,
        isSelected = false,
        isdLoading = false,
        quantityInProduct = 0;
}