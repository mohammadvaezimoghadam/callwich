import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'dashboard_bloc_event.dart';
part 'dashboard_bloc_state.dart';

class DashboardBloc extends Bloc<DashboardBlocEvent, DashboardBlocState> {
  DashboardBloc() : super(DashboardBlocLoading()) {
    on<DashboardBlocEvent>((event, emit) async {
      if (event is DashboardStarted) {
        emit(DashboardBlocSuccess());
      } else if (event is DashboardRefresh) {
        emit(DashboardBlocLoading());
        await Future.delayed(const Duration(milliseconds: 300));
        emit(DashboardBlocSuccess());
        event.completer?.complete();
      }
    });
  }
}
