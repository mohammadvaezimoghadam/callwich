import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/models/recipe.dart';
import 'package:callwich/data/repository/recipes_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:callwich/data/common/app_exeption.dart';

part 'recipe_placeholder_event.dart';
part 'recipe_placeholder_state.dart';

class RecipePlaceholderBloc
    extends Bloc<RecipePlaceholderEvent, RecipePlaceholderState> {
  final IRecipesRepository recipesRepository;

  RecipePlaceholderBloc(this.recipesRepository)
    : super(RecipePlaceholderLoading()) {
    on<RecipePlaceholderEvent>((event, emit) async {
      if (event is RecipePlaceholderStarted) {
        await _onStarted(event, emit);
      }
    });
  }

  Future<void> _onStarted(
    RecipePlaceholderStarted event,
    Emitter<RecipePlaceholderState> emit,
  ) async {
    emit(RecipePlaceholderLoading());

    try {
      final response = await recipesRepository.getRecipeaByProductId(
        productId: event.productId,
      );
      List<Map<String, dynamic>> finaly = [];
      List<IngredientEntity> ingredients = [];
      List<int> ingredientsId = [];
      response.forEach((element) {
        ingredientsId.add(element.ingredientId);
      });
      ingredientsId.forEach((element) {
        IngredientEntity ingredientEntity = event.ingredients.firstWhere((
          ingredient,
        ) {
          return ingredient.id == element;
        });
        RecipeEntity recipes = response.firstWhere((recipe) {
          return recipe.ingredientId == element;
        });

        finaly.add({
          "ingreEntity": ingredientEntity,
          "quantity": recipes.quantity,
        });
      });

      emit(RecipePlaceholderSuccess(finaly));
    } catch (e) {
      emit(
        RecipePlaceholderError(
          appException: e is AppException ? e : AppException(),
        ),
      );
    }
  }
}
