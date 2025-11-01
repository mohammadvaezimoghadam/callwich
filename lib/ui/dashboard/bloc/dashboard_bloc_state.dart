part of 'dashboard_bloc_bloc.dart';

sealed class DashboardBlocState  {
  const DashboardBlocState();
  

}

final class DashboardBlocLoading extends DashboardBlocState {}
final class DashboardBlocSuccess extends DashboardBlocState {}
