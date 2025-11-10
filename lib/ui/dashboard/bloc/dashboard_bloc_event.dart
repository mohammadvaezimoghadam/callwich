part of 'dashboard_bloc_bloc.dart';

sealed class DashboardBlocEvent {
  const DashboardBlocEvent();


}

final class DashboardStarted extends DashboardBlocEvent {}

final class DashboardRefresh extends DashboardBlocEvent {
  final Completer<void>? completer;

  DashboardRefresh({this.completer});
}
