import 'package:callwich/data/repository/reports_repository.dart';
import 'package:callwich/di/di.dart';
import 'package:callwich/widgets/lowStockAlesrtWidget/bloc/dashboard_low_stok_card_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../res/strings.dart';

import '../../res/dimens.dart';
import '../low_stock_banner_item.dart';
import '../skeletons/low_stock_banner_skeleton.dart';

class LowStockAlertWidget extends StatefulWidget {
  LowStockAlertWidget({super.key});

  @override
  State<LowStockAlertWidget> createState() => _LowStockAlertWidgetState();
}

class _LowStockAlertWidgetState extends State<LowStockAlertWidget> {
  late final DashboardLowStokCardBloc? dashboardLowStokCardBloc;
  @override
  void dispose() {
    dashboardLowStokCardBloc!.close();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider<DashboardLowStokCardBloc>(
      create: (context) {
        final bloc = DashboardLowStokCardBloc(
          reportsRepository: getIt<IReportsRepository>(),
        );
        bloc.add(DashboardLowStokCardStarted());
        return bloc;
      },
      child: BlocBuilder<DashboardLowStokCardBloc, DashboardLowStokCardState>(
        builder: (context, state) {
          if (state is DashboardLowStokCardSuccess) {
            // ترکیب لیست محصولات و مواد اولیه کم‌موجودی
            final entries = <_LowStockEntry>[];

            for (final p in state.lowStockProducts) {
              final subtitle = '${p.stock}  (حداقل: ${p.minStock})';
              entries.add(
                _LowStockEntry(
                  title: p.name,
                  subtitle: subtitle,
                  imageUrl: p.imageUrl,
                  icon: null,
                ),
              );
            }

            for (final i in state.lowStockIngredients) {
              final subtitle = '${i.stock} ${i.unit}  (حداقل: ${i.minStock})';
              entries.add(
                _LowStockEntry(
                  title: i.name,
                  subtitle: subtitle,
                  imageUrl: null,
                  icon: Icons.scale,
                ),
              );
            }

            if (entries.isEmpty) {
              return const SizedBox.shrink();
            }

            // لیست افقی بدون حلقه بی‌نهایت
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.medium.toDouble(),
                    vertical: AppDimens.small.toDouble(),
                  ),
                  child: Text(
                    AppStrings.lowStockAlert,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
                SizedBox(
                  height: AppDimens.large.toDouble() * 3.2, // ارتفاع بنر
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimens.medium.toDouble(),
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final item = entries[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == 0 ? 0 : AppDimens.small.toDouble(),
                        ),
                        child: SizedBox(
                          width: 320, // عرض تقریبی هر بنر
                          child: LowStockBannerItem(
                            title: item.title,
                            subtitle: item.subtitle,
                            imageUrl: item.imageUrl,
                            icon: item.icon,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is DashboardLowStokCardLoading) {
            return const LowStockBannerSkeleton();
          } else if (state is DashboardLowStokCardError) {
            return Center(
              child: IconButton(
                onPressed: () {
                  BlocProvider.of<DashboardLowStokCardBloc>(
                    context,
                  ).add(DashboardLowStokCardStarted());
                },
                icon: const Icon(Icons.refresh),
              ),
            );
          } else {
            throw Exception("state not valid");
          }
        },
      ),
    );
  }
}

class _LowStockEntry {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final IconData? icon;
  _LowStockEntry({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.icon,
  });
}
