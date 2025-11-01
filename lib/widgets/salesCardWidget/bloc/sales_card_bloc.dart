import 'package:bloc/bloc.dart';
import 'package:callwich/data/common/app_exeption.dart';
import 'package:callwich/data/repository/reports_repository.dart';
import 'package:equatable/equatable.dart';

part 'sales_card_event.dart';
part 'sales_card_state.dart';

class SalesCardBloc extends Bloc<SalesCardEvent, SalesCardState> {
  final IReportsRepository reportsRepository;
  SalesCardBloc({required this.reportsRepository}) : super(SalesCardLoading()) {
    on<SalesCardEvent>((event, emit) async {
      if (event is SalesCardStartedEvent) {
        await calculatePercent(emit, event) ;
      }
    });
  }

  Future<void> calculatePercent(
    Emitter<SalesCardState> emit,
    SalesCardEvent event,
  ) async {
    emit(SalesCardLoading());
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final yesterdayStart = DateTime(now.year, now.month, now.day - 1);

      final todaySales = int.parse(await reportsRepository.dailySales(
        todayStart.toString(),
      ));
      final yesterdaySales = int.parse(await reportsRepository.dailySales(
        yesterdayStart.toString(),
      ));

      double percentChange = 0;
      bool isProfit = false;

      if (yesterdaySales != 0) {
        percentChange = ((todaySales - yesterdaySales) / yesterdaySales) * 100;
        isProfit = todaySales > yesterdaySales;
      } else {
        // اگر دیروز فروش نداشته باشیم، اگر امروز فروش داشتیم سود حساب میشه
        percentChange = todaySales != 0 ? 100 : 0;
        isProfit = todaySales > 0;
      }

      emit(
        SalesCardSuccess(
          todaySales: todaySales,
          profitOrLoss: percentChange.toString(),
          isProfit: isProfit,
        ),
      );
    } catch (e) {
      emit(
        SalesCardError(appException: e is AppException ? e : AppException()),
      );
    }
  }
}
