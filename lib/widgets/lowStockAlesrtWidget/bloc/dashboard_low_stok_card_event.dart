part of 'dashboard_low_stok_card_bloc.dart';

sealed class DashboardLowStokCardEvent extends Equatable {
  const DashboardLowStokCardEvent();

  @override
  List<Object> get props => [];
}

final class DashboardLowStokCardStarted extends DashboardLowStokCardEvent {}
