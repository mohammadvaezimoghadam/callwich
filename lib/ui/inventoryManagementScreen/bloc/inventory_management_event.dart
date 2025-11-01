part of 'inventory_management_bloc.dart';

sealed class InventoryManagementEvent {}

final class InventoryManagementStarted extends InventoryManagementEvent {}

final class CategoryFilterChanged extends InventoryManagementEvent {
  final int? categoryId;
  
  CategoryFilterChanged({this.categoryId});
}

final class StockFilterChanged extends InventoryManagementEvent {
  final String stockFilter; // 'all' or 'low-stock'
  
  StockFilterChanged({required this.stockFilter});
}

final class FilterChanged extends InventoryManagementEvent {
  final String filterType; // 'all', 'low-stock', or category name
  final int? categoryId;
  
  FilterChanged({required this.filterType, this.categoryId});
}

final class TabChanged extends InventoryManagementEvent {
  final String tab; // 'products' or 'ingredients'
  
  TabChanged({required this.tab});
} 

final class DeleteIngredientClicked extends InventoryManagementEvent {
   final int ingredientId;

  DeleteIngredientClicked({required this.ingredientId});
  
}