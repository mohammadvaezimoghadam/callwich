class CategoryEntity {
  final int id;
  final String name;

  CategoryEntity({required this.id, required this.name});

  CategoryEntity.fromJson(Map<String, dynamic> json)
    : id = json["id"],
      name = json["name"];
}
