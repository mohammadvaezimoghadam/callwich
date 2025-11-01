part of 'sales_trend_bloc.dart';

sealed class SalesTrendEvent extends Equatable {
  const SalesTrendEvent();

  @override
  List<Object> get props => [];
}

final class SalesTrendStarted extends SalesTrendEvent {}

