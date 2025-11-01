class RecipeEntity {
  final int id;
  final int productId;
  final int ingredientId;
  final int quantity;

  RecipeEntity({
    required this.id,
    required this.productId,
    required this.ingredientId,
    required this.quantity,
  });
  RecipeEntity.fromJson(Map<String, dynamic> json)
    : id = json["id"],
      productId = json["product_id"],
      ingredientId = json["ingredient_id"],
      quantity = json["quantity"];
}
