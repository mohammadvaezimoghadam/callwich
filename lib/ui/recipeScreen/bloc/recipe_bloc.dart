import 'package:bloc/bloc.dart';
import 'package:callwich/data/common/app_exeption.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/models/recipe_screen_model.dart';
import 'package:callwich/data/repository/ingredients_repository.dart';
import 'package:callwich/data/repository/recipes_repository.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final IRecipesRepository recipesRepository;
  final IIngredientsRepository ingredientsRepository;
  bool isEditingMde = false;
  RecipeBloc(this.recipesRepository, this.ingredientsRepository)
    : super(const RecipeLoading()) {
    on<RecipeStarted>((event, emit) async {
      isEditingMde = event.isEditingMode;
      emit(const RecipeLoading());
      try {
        final ingredients = await ingredientsRepository.getAllIngredients();
        List<RecipeScreenModel> recipeScreenItems = [];
        ingredients.forEach((ingretean) {
          event.selectedIngredient.forEach((map) {
            if (map["ingreEntity"].id == ingretean.id) {
              recipeScreenItems.add(
                RecipeScreenModel(
                  ingredientId: ingretean.id,
                  quantity: map["quantity"], name: '',
                ),
              );
            }
          });
        });
        emit(RecipeLoaded(ingredients.cast<RecipeScreenModel>()));
      } catch (e) {
        emit(RecipeError(e is AppException ? e : AppException()));
      }
    });

    // on<SetIngredientQuantity>((event, emit) async {
    //   final current = state;
    //   if (current is RecipeLoaded) {
    //     IngredientEntity selectedIngredient = current.ingredients.firstWhere((
    //       element,
    //     ) {
    //       return element.id == event.ingredientId;
    //     });

    //     selectedIngredient.quantity = event.quantity;
    //     List<IngredientEntity> selectedIngredientList = current.ingredients
    //         .where((element) {
    //           return element.isSelected == true;
    //         })
    //         .toList();

    //     emit(RecipeLoaded(current.ingredients));
    //   }
    // });

    on<OnSaveBtnClicked>((event, emit) async {
      emit(RecipeLoaded(event.ingredients.cast<RecipeScreenModel>(), isdLoading: true));
      try {
        isEditingMde
            ? await recipesRepository.updateRecipe(
                productId: event.productId,
                ingredients: event.ingredients
                    .where((element) => element.quantityInProduct > 0)
                    .toList(),
              )
            : await recipesRepository.creatRecipes(
                productId: event.productId,
                ingredients: event.ingredients
                    .where((element) => element.quantityInProduct > 0)
                    .toList(),
              );
        emit(AddRecipesSuccess());
      } catch (e) {
        emit(RecipeError(e is AppException ? e : AppException()));
      }
    });
  }
}
