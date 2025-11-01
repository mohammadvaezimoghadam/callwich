part of 'dashboard_low_stok_card_bloc.dart';

sealed class DashboardLowStokCardState extends Equatable {
  const DashboardLowStokCardState();

  @override
  List<Object> get props => [];
}

final class DashboardLowStokCardLoading extends DashboardLowStokCardState {}

final class DashboardLowStokCardSuccess extends DashboardLowStokCardState {
  final List<ProductEntity> lowStockProducts;
  final List<IngredientEntity> lowStockIngredients;

  const DashboardLowStokCardSuccess({
    required this.lowStockProducts,
    required this.lowStockIngredients,
  });
  @override
  // TODO: implement props
  List<Object> get props => [lowStockProducts, lowStockIngredients];
}

final class DashboardLowStokCardError extends DashboardLowStokCardState {
  final AppException appException;

  const DashboardLowStokCardError({required this.appException});
  @override
  // TODO: implement props
  List<Object> get props => [appException];
}
