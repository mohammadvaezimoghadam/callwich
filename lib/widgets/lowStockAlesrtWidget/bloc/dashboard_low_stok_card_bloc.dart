import 'package:bloc/bloc.dart';
import 'package:callwich/data/common/app_exeption.dart';
import 'package:callwich/data/models/ingredient.dart';
import 'package:callwich/data/models/product.dart';
import 'package:callwich/data/repository/reports_repository.dart';
import 'package:equatable/equatable.dart';

part 'dashboard_low_stok_card_event.dart';
part 'dashboard_low_stok_card_state.dart';

class DashboardLowStokCardBloc
    extends Bloc<DashboardLowStokCardEvent, DashboardLowStokCardState> {
  final IReportsRepository reportsRepository;
  DashboardLowStokCardBloc({required this.reportsRepository})
    : super(DashboardLowStokCardLoading()) {
    on<DashboardLowStokCardEvent>((event, emit) async {
      if (event is DashboardLowStokCardStarted) {
        emit(DashboardLowStokCardLoading());
        try {
          final lowStockProducts =
              await reportsRepository.getLowStockProducts();
          final lowStockIngredients =
              await reportsRepository.getLowStockIngredients();
          emit(
            DashboardLowStokCardSuccess(
              lowStockProducts: lowStockProducts,
              lowStockIngredients: lowStockIngredients,
            ),
          );
        } catch (e) {
          emit(
            DashboardLowStokCardError(
              appException: e is AppException ? e : AppException(),
            ),
          );
        }
      }
    });
  }
}
