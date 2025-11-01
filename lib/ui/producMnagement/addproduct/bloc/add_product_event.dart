part of 'add_product_bloc.dart';

sealed class AddProductEvent extends Equatable {
  const AddProductEvent();

  @override
  List<Object> get props => [];
}

final class SaveProductBtnIsClicked extends AddProductEvent {
  final String name;
  final String sellingPrice;
  final String? purchasePrice;
  final int categoryId;
  final String type;
  final String? stock;
  final String? minstock;
  final bool? isActive;
  final XFile image;
  const SaveProductBtnIsClicked(
    this.name,
    this.sellingPrice,
    this.purchasePrice,
    this.categoryId,
    this.type,
    this.stock,
    this.minstock,
    this.isActive,
    this.image,
  );

  @override
  List<Object> get props => [
    name,
    sellingPrice,
    purchasePrice!,
    categoryId,
    type,
    stock!,
    minstock!,
    isActive!,
    image,
  ];
}

final class AddCategoryBtnIsClicked extends AddProductEvent {
  final String name;
  const AddCategoryBtnIsClicked({required this.name});

  @override
  List<Object> get props => [name];
}

final class AddProductStarted extends AddProductEvent {}

final class UpdateProductEvent extends AddProductEvent {
  final String name;
  final String sellingPrice;
  final String? purchasePrice;
  final int? categoryId;
  final String? type;
  final String? stock;
  final String? minstock;
  final bool? isActive;
  final XFile? image;
  final int id;

  const UpdateProductEvent({
    required this.id,
    required this.name,
    required this.sellingPrice,
    required this.purchasePrice,
    required this.categoryId,
    required this.type,
    required this.stock,
    required this.minstock,
    required this.isActive,
    required this.image,
  });
  @override
  List<Object> get props => [
    id,
    name,
    sellingPrice,
    purchasePrice!,
    categoryId!,
    type!,
    stock!,
    minstock!,
    isActive!,
    image!,
  ];
}

final class SaveIngrediantBtnClicked extends AddProductEvent {
  final String name;

  final String? purchasePrice;
  final String unit;
  final String? stock;
  final String? minstock;
  final bool? isActive;

  const SaveIngrediantBtnClicked({
    required this.name,
    required this.unit,
    required this.purchasePrice,
    required this.stock,
    required this.minstock,
    this.isActive = true,
  });
  @override
  // TODO: implement props
  List<Object> get props => [
    name,
    unit,
    purchasePrice!,
    stock!,
    minstock!,
    isActive!,
  ];
}

final class UpdateIngrediant extends AddProductEvent {
  final String name;
  final int id;
  final String? purchasePrice;
  final String unit;
  final String? stock;
  final String? minstock;
  final bool? isActive;

  UpdateIngrediant(
    this.id, {
    required this.name,
    required this.purchasePrice,
    required this.unit,
    required this.stock,
    required this.minstock,
    required this.isActive,
  });
  @override
  // TODO: implement props
  List<Object> get props => [
    name,
    unit,
    purchasePrice!,
    stock!,
    minstock!,
    isActive!,
    id,
  ];
}
