part of 'recipe_bloc.dart';

sealed class RecipeState {
  const RecipeState();
}

final class RecipeLoading extends RecipeState {
  const RecipeLoading();
}

final class RecipeLoaded extends RecipeState {
  final List<RecipeScreenModel> ingredients;
 final bool isdLoading;
 
  RecipeLoaded(this.ingredients,  {this.isdLoading=false});
}

final class RecipeError extends RecipeState {
  final AppException appException;
  const RecipeError(this.appException);
}

final class AddRecipesSuccess extends RecipeState{

}
