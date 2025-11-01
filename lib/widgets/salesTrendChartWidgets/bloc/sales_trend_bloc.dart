import 'package:bloc/bloc.dart';
import 'package:callwich/data/common/app_exeption.dart';
import 'package:callwich/data/repository/sales_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

part 'sales_trend_event.dart';
part 'sales_trend_state.dart';

/// Maps a list of raw sales objects (each containing at least `sale_time` and
/// `total_amount`) to a normalized list of Offsets for the chart.
///
/// - Groups by day within [startDate]..[endDate] (inclusive)
/// - Fills missing days with 0
/// - Normalizes Y to 0..1 and flips for canvas (top=0)
/// - X is spaced evenly from 0..1 based on index
List<Offset> mapSalesToOffsets(
  List<Map<String, dynamic>> rawSales, {
  DateTime? startDate,
  DateTime? endDate,
}) {
  if (rawSales.isEmpty) return const <Offset>[];

  DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  // Determine range
  final allDates = <DateTime>[];
  for (final s in rawSales) {
    final dt = parseDate(s['sale_time']);
    if (dt != null) allDates.add(DateTime(dt.year, dt.month, dt.day));
  }
  if (allDates.isEmpty) return const <Offset>[];

  final DateTime rangeStart = startDate != null
      ? DateTime(startDate.year, startDate.month, startDate.day)
      : allDates.reduce((a, b) => a.isBefore(b) ? a : b);
  final DateTime rangeEnd = endDate != null
      ? DateTime(endDate.year, endDate.month, endDate.day)
      : allDates.reduce((a, b) => a.isAfter(b) ? a : b);

  // Build date buckets
  final Map<DateTime, double> totalsByDay = {};
  for (final s in rawSales) {
    final dt = parseDate(s['sale_time']);
    if (dt == null) continue;
    final day = DateTime(dt.year, dt.month, dt.day);
    final amount = (s['total_amount'] is num) ? (s['total_amount'] as num).toDouble() : 0.0;
    totalsByDay.update(day, (v) => v + amount, ifAbsent: () => amount);
  }

  // Walk days from start..end and collect totals (fill zeros)
  final List<DateTime> days = [];
  for (DateTime d = rangeStart; !d.isAfter(rangeEnd); d = d.add(const Duration(days: 1))) {
    days.add(d);
  }
  if (days.length == 1) {
    // Ensure we have at least two points to draw a line
    days.add(days.first);
  }

  final List<double> values = days.map((d) => totalsByDay[d] ?? 0.0).toList();

  // Normalize
  final double maxValue = values.fold<double>(0.0, (m, v) => v > m ? v : m);
  final int n = values.length;
  if (n == 0) return const <Offset>[];

  final List<Offset> points = [];
  for (int i = 0; i < n; i++) {
    final double dx = n == 1 ? 0.0 : i / (n - 1);
    final double norm = maxValue == 0 ? 0.0 : (values[i] / maxValue);
    final double dy = 1 - norm; // flip for canvas (0 at top)
    points.add(Offset(dx, dy));
  }
  return points;
}

class SalesTrendBloc extends Bloc<SalesTrendEvent, SalesTrendState> {
   final ISalesRepository salesRepository;
  SalesTrendBloc(this.salesRepository) : super(SalesTrendLoading()) {
   
    on<SalesTrendEvent>((event, emit) async{
    if (event is SalesTrendStarted) {
      emit(SalesTrendLoading());
      try {
        // فرض بر این است که داده‌های فروش باید برای یک بازه زمانی خاص خوانده شوند
        // اینجا به طور نمونه یک بازه هفت روزه اخیر را در نظر می‌گیریم
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(days: 6));
        final endDate = now;

        // تبدیل تاریخ‌ها به فرمت مناسب (مثلاً yyyy-MM-dd)
        String formatDate(DateTime date) =>
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

        final startDateStr = formatDate(startDate);
        final endDateStr = formatDate(endDate);

        // دریافت داده‌های فروش
        final List<double> salesList = await salesRepository.readSales(startDateStr, endDateStr);

        // تبدیل مقادیر روزانه به نقاط نرمال‌شده (0..1)
        final double maxSale = salesList.isNotEmpty ? salesList.reduce((a, b) => a > b ? a : b) : 1.0;
        final List<Offset> normalizedPoints = <Offset>[];
        for (int i = 0; i < salesList.length; i++) {
          final double dx = salesList.length == 1 ? 0.0 : i / (salesList.length - 1);
          final double dy = 1 - (salesList[i] / (maxSale == 0 ? 1 : maxSale));
          normalizedPoints.add(Offset(dx, dy));
        }

        emit(SalesTrendLoaded(normalizedPoints));
      } catch (e) {
        emit(SalesTrendError(
          e is AppException ? e : AppException(),
        ));
      }
    }
      
    });
  }
}
