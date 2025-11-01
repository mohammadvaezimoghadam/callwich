part of 'recipe_placeholder_bloc.dart';

abstract class RecipePlaceholderState extends Equatable {}

final class RecipePlaceholderLoading extends RecipePlaceholderState {
  RecipePlaceholderLoading();
  
  @override
  // TODO: implement props
  List<Object?> get props => [];

}


class RecipePlaceholderSuccess extends RecipePlaceholderState {
final List<Map<String,dynamic>> ingredients;
  
  RecipePlaceholderSuccess(this.ingredients,);
  
  @override
  // TODO: implement props
  List<Object?> get props => [ingredients];
}

class RecipePlaceholderError extends RecipePlaceholderState {
  final AppException appException;
  
  RecipePlaceholderError({required this.appException});
  
  @override
  // TODO: implement props
  List<Object?> get props => [appException];
}