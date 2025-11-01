part of 'reports_bloc.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object> get props => [];
}

class ReportsLoading extends ReportsState {}

class ReportsSuccess extends ReportsState {
  final List<ProductEntity> allProducts;
  final List<IngredientEntity> allIngredients;

  const ReportsSuccess({
    required this.allProducts,
    required this.allIngredients,
  });

  @override
  List<Object> get props => [allProducts, allIngredients];
}

class ReportsError extends ReportsState {
  final AppException appException;

  const ReportsError({required this.appException});

  @override
  List<Object> get props => [appException];
} 