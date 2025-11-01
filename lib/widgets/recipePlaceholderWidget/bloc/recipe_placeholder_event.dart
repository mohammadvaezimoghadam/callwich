part of 'recipe_placeholder_bloc.dart';

abstract class RecipePlaceholderEvent extends Equatable{}

class RecipePlaceholderStarted extends RecipePlaceholderEvent {
  final int productId;
  final  List<IngredientEntity> ingredients;

  RecipePlaceholderStarted({required this.productId,required this.ingredients});
  
  @override
  // TODO: implement props
  List<Object?> get props => [productId,ingredients];
  
}



