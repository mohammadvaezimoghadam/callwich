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
  bool isEditingMode = false;
  List<RecipeScreenModel> recipeItems = [];

  RecipeBloc(this.recipesRepository, this.ingredientsRepository)
      : super(const RecipeLoading()) {
    on<RecipeStarted>((event, emit) async {
      isEditingMode = event.isEditingMode;
      emit(const RecipeLoading());
      try {
        final ingredients = await ingredientsRepository.getAllIngredients();
        
        // Convert IngredientEntity to RecipeScreenModel
        List<RecipeScreenModel> recipeScreenItems = [];
        for (var ingredient in ingredients) {
          int quantity = 0;
          
          // If in editing mode, find the existing quantity for this ingredient
          if (event.isEditingMode && event.selectedIngredient != null) {
            for (var map in event.selectedIngredient!) {
              if (map["ingreEntity"].id == ingredient.id) {
                quantity = map["quantity"] as int? ?? 0;
                break;
              }
            }
          }
          
          recipeScreenItems.add(
            RecipeScreenModel(
              ingredientId: ingredient.id,
              name: ingredient.name,
              quantity: quantity,
            ),
          );
        }
        
        recipeItems = recipeScreenItems;
        emit(RecipeLoaded(recipeScreenItems));
      } catch (e) {
        emit(RecipeError(e is AppException ? e : AppException()));
      }
    });

    on<SetIngredientQuantity>((event, emit) async {
      // Update the quantity for the specific ingredient
      for (int i = 0; i < recipeItems.length; i++) {
        if (recipeItems[i].ingredientId == event.ingredientId) {
          recipeItems[i] = RecipeScreenModel(
            ingredientId: recipeItems[i].ingredientId,
            name: recipeItems[i].name,
            quantity: event.quantity,
          );
          break;
        }
      }
      
      // Emit the updated state
      emit(RecipeLoaded(List.from(recipeItems)));
    });

    on<OnSaveBtnClicked>((event, emit) async {
      emit(RecipeLoaded(List.from(recipeItems), isdLoading: true));
      try {
        // Filter out ingredients with zero or negative quantity
        final ingredientsWithQuantity = recipeItems
            .where((item) => item.quantity > 0)  // Only send ingredients with quantity > 0
            .map((item) {
              // Create a new IngredientEntity with the quantity
              // Fix: Set the quantity property instead of quantityInProduct
              return IngredientEntity(
                id: item.ingredientId,
                name: item.name,
                unit: '', // These will be filled from the actual ingredient data
                purchasePrice: '0',
                stock: '0',
                minStock: '0',
                isActive: true,
                quantity: item.quantity, // Fix: Use quantity instead of quantityInProduct
                quantityInProduct: item.quantity, // Also set this for consistency
              );
            })
            .toList();

        // Only proceed if there are ingredients with quantity > 0
        if (ingredientsWithQuantity.isNotEmpty) {
          if (isEditingMode) {
            await recipesRepository.updateRecipe(
              productId: event.productId,
              ingredients: ingredientsWithQuantity,
            );
          } else {
            await recipesRepository.creatRecipes(
              productId: event.productId,
              ingredients: ingredientsWithQuantity,
            );
          }
        }
        
        emit(AddRecipesSuccess());
      } catch (e) {
        emit(RecipeError(e is AppException ? e : AppException()));
      }
    });
  }
}