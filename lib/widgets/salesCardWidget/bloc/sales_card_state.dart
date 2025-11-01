part of 'sales_card_bloc.dart';

sealed class SalesCardState extends Equatable {
  const SalesCardState();

  @override
  List<Object> get props => [];
}

final class SalesCardLoading extends SalesCardState {}

final class SalesCardSuccess extends SalesCardState {
  final int todaySales;
  final String profitOrLoss;
  final bool isProfit;

  const SalesCardSuccess({
    required this.todaySales,
    required this.profitOrLoss,
    required this.isProfit,
  });
  @override
  // TODO: implement props
  List<Object> get props => [todaySales, profitOrLoss, isProfit];
}

final class SalesCardError extends SalesCardState {
  final AppException appException;

  const SalesCardError({required this.appException});

  @override
  // TODO: implement props
  List<Object> get props => [appException];
}
