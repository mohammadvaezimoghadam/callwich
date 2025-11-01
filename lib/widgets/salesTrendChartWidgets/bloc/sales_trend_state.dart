part of 'sales_trend_bloc.dart';

sealed class SalesTrendState extends Equatable {
  const SalesTrendState();
  
  @override
  List<Object> get props => [];
}

final class SalesTrendLoading extends SalesTrendState {}

final class SalesTrendLoaded extends SalesTrendState {
  final List<Offset> salesData; // Replace dynamic with your actual data type

  const SalesTrendLoaded(this.salesData);

  @override
  List<Object> get props => [salesData];
}

final class SalesTrendError extends SalesTrendState {
  final AppException appException;

  const SalesTrendError(this.appException);

  @override
  List<Object> get props => [appException];
}

