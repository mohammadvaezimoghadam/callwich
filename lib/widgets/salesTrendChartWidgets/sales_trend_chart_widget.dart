import 'package:callwich/di/di.dart';
import 'package:callwich/widgets/salesTrendChartWidgets/bloc/sales_trend_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../res/strings.dart';

import 'package:callwich/data/repository/sales_repository.dart';
import '../skeletons/sales_trend_chart_skeleton.dart';

class SalesTrendChartWidget extends StatefulWidget {
  const SalesTrendChartWidget({super.key});

  @override
  State<SalesTrendChartWidget> createState() => _SalesTrendChartWidgetState();
}

class _SalesTrendChartWidgetState extends State<SalesTrendChartWidget> {
  late final SalesTrendBloc? salesTrendBloc;
  @override
  void dispose() {
    salesTrendBloc!.close();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SalesTrendBloc>(
      create: (context) {
        salesTrendBloc = SalesTrendBloc(getIt<ISalesRepository>());
        salesTrendBloc!.add(SalesTrendStarted());
        return salesTrendBloc!;
      },
      child: BlocBuilder<SalesTrendBloc, SalesTrendState>(
        builder: (context, state) {
          if (state is SalesTrendLoading) {
            return const SalesTrendChartSkeleton();
          } else if (state is SalesTrendLoaded) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.salesTrend,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B130D),
                        ),
                      ),
                      Text(
                        AppStrings.last7Days,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9A6C4C), // neutral-600
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 192,

                    child: CustomPaint(
                      size: const Size(double.infinity, 192),
                      painter: SalesChartPainter(points: state.salesData),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.monday,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A6C4C),
                        ),
                      ),
                      Text(
                        AppStrings.tuesday,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A6C4C),
                        ),
                      ),
                      Text(
                        AppStrings.wednesday,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A6C4C),
                        ),
                      ),
                      Text(
                        AppStrings.thursday,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A6C4C),
                        ),
                      ),
                      Text(
                        AppStrings.friday,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A6C4C),
                        ),
                      ),
                      Text(
                        AppStrings.saturday,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A6C4C),
                        ),
                      ),
                      Text(
                        AppStrings.sunday,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A6C4C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is SalesTrendError) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'خطا در دریافت داده‌های فروش',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class SalesChartPainter extends CustomPainter {
  final List<Offset> points;

  SalesChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFED7B2A) // primary-600
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(
                0xFFFA8B29,
              ).withOpacity(0.2), // primary-500 with opacity
              const Color(
                0xFFFA8B29,
              ).withOpacity(0), // primary-500 with 0 opacity
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // اگر لیست نقاط خالی بود، چیزی نکش
    if (points.isEmpty) {
      return;
    }

    // Convert normalized points (0..1) to actual coordinates
    final actualPoints =
        points.map((point) {
          return Offset(point.dx * size.width, point.dy * size.height);
        }).toList();

    // Draw smooth curved line using cubic Bezier curves
    path.moveTo(actualPoints[0].dx, actualPoints[0].dy);

    for (int i = 0; i < actualPoints.length - 1; i++) {
      final current = actualPoints[i];
      final next = actualPoints[i + 1];

      // Calculate control points for smooth curve
      // First control point: extends from current point
      final control1X = current.dx + (next.dx - current.dx) * 0.3;
      final control1Y = current.dy;

      // Second control point: extends toward next point
      final control2X = next.dx - (next.dx - current.dx) * 0.3;
      final control2Y = next.dy;

      path.cubicTo(
        control1X,
        control1Y,
        control2X,
        control2Y,
        next.dx,
        next.dy,
      );
    }

    // Draw fill path with curved bottom
    fillPath.moveTo(actualPoints[0].dx, size.height);
    fillPath.lineTo(actualPoints[0].dx, actualPoints[0].dy);

    for (int i = 0; i < actualPoints.length - 1; i++) {
      final current = actualPoints[i];
      final next = actualPoints[i + 1];

      // Calculate control points for smooth curve
      final control1X = current.dx + (next.dx - current.dx) * 0.3;
      final control1Y = current.dy;

      final control2X = next.dx - (next.dx - current.dx) * 0.3;
      final control2Y = next.dy;

      fillPath.cubicTo(
        control1X,
        control1Y,
        control2X,
        control2Y,
        next.dx,
        next.dy,
      );
    }

    fillPath.lineTo(actualPoints.last.dx, size.height);
    fillPath.close();

    // Draw the paths
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SalesChartPainter oldDelegate) {
    // repaint only when points change
    if (identical(points, oldDelegate.points)) return false;
    if (points.length != oldDelegate.points.length) return true;
    for (int i = 0; i < points.length; i++) {
      if (points[i] != oldDelegate.points[i]) return true;
    }
    return false;
  }
}
