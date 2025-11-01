import 'package:callwich/data/repository/reports_repository.dart';
import 'package:callwich/di/di.dart';
import 'package:callwich/widgets/salesCardWidget/bloc/sales_card_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../res/strings.dart';
import '../../components/extensions.dart';
import '../../res/dimens.dart';
import '../skeletons/sales_card_skeleton.dart';

class SalesCardWidget extends StatefulWidget {
  final ThemeData theme;
  
  const SalesCardWidget({super.key, required this.theme,});

  @override
  State<SalesCardWidget> createState() => _SalesCardWidgetState();
}

class _SalesCardWidgetState extends State<SalesCardWidget> {
    late final SalesCardBloc? salesCardBloc;
  @override
  void dispose() {
    salesCardBloc!.close();

    super.dispose();
  }




  @override
  void initState() {
    super.initState();

  }




  @override
  Widget build(BuildContext context) {
    return BlocProvider<SalesCardBloc>(
      create: (context) {
        final bloc = SalesCardBloc(reportsRepository: getIt<IReportsRepository>());
        bloc.add(SalesCardStartedEvent());
        return bloc;
      },
      child: BlocConsumer<SalesCardBloc, SalesCardState>(
        listener: (context, state) {
          if (state is SalesCardLoading) {}
        },
        builder: (context, state) {
          if (state is SalesCardSuccess) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.theme.shadowColor.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.todaySales,
                    style: widget.theme.textTheme.bodySmall?.copyWith(
                      color: Color(0xFF9A6C4C),
                    ),
                  ),
                  AppDimens.small.heightBox,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        state.todaySales .toFormattedNumber(),
                        style: widget.theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.theme.colorScheme.onSurface,
                        ),
                      ),
                      AppDimens.small.widthBox,
                      Text(
                        AppStrings.currency,
                        style: widget.theme.textTheme.titleMedium?.copyWith(
                          color: Color(0xFF654433),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  AppDimens.small.heightBox,
                  Row(
                    children: [
                      Icon(
                       state.isProfit? Icons.arrow_upward:Icons.arrow_downward,
                        color:state.isProfit? Colors.green[600]:widget.theme.colorScheme.error,
                        size: 12,
                      ),
                      Text(
                        state.profitOrLoss,
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color:state.isProfit? Colors.green[600]:widget.theme.colorScheme.error,
                        ),
                      ),
                      AppDimens.small.widthBox,
                      Text(
                        AppStrings.salesGrowth,
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color:state.isProfit? Colors.green[600]:widget.theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is SalesCardError) {
            return Container(
              child: Center(
                child: IconButton(
                  onPressed: () {
                    BlocProvider.of<SalesCardBloc>(
                      context,
                    ).add(SalesCardStartedEvent());
                  },
                  icon: Icon(Icons.refresh),
                ),
              ),
            );
          } else if (state is SalesCardLoading) {
            return const SalesCardSkeleton();
          } else {
            throw Exception("state not valid");
          }
        },
      ),
    );
  }
}
