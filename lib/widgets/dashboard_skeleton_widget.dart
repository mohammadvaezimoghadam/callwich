// import 'package:flutter/material.dart';
// import '../components/extensions.dart';
// import '../res/dimens.dart';

// const headerindex = 0;
// const salesCardindex = 1;
// const lowStockCardindex = 2;
// const actionBtnsindex = 3;
// const trendChartindex = 4;

// class DashboardSkeletonWidget {
//   late Animation<double> _animation;
//   final ThemeData theme;

//   late final map = {
//     headerindex: buildHeaderSkeleton(),
//     salesCardindex: buildSalesCardSkeleton(),
//     lowStockCardindex: buildLowStockAlertSkeleton(),
//     actionBtnsindex: buildActionButtonsSkeleton(),
//     trendChartindex: buildSalesTrendChartSkeleton(),
//   };

//   DashboardSkeletonWidget({required this.theme});
//   }

//   Widget buildHeaderSkeleton() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         AppDimens.medium.widthBox,
//         _buildSkeletonText(120, 32),
//         _buildSkeletonIcon(40, 40),
//       ],
//     );
//   }

//   Widget buildSalesCardSkeleton() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: theme.shadowColor.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSkeletonText(80, 16),
//           AppDimens.small.heightBox,
//           _buildSkeletonText(150, 40),
//           AppDimens.small.heightBox,
//           Row(
//             children: [
//               _buildSkeletonIcon(16, 16),
//               AppDimens.small.widthBox,
//               _buildSkeletonText(100, 16),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildLowStockAlertSkeleton(ThemeData theme) {
    
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: theme.shadowColor.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               buildSkeletonIcon(24, 24),
//               AppDimens.small.widthBox,
//               buildSkeletonText(120, 20),
//             ],
//           ),
//           AppDimens.small.heightBox,
//           buildSkeletonText(200, 16),
//           AppDimens.small.heightBox,
//           buildSkeletonText(150, 16),
//         ],
//       ),
//     );
//   }

//   Widget buildActionButtonsSkeleton() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(child: _buildButtonSkeleton()),
//             AppDimens.medium.widthBox,
//             Expanded(child: _buildButtonSkeleton()),
//           ],
//         ),
//         AppDimens.medium.heightBox,
//         _buildButtonSkeleton(isFullWidth: true),
//       ],
//     );
//   }

//   Widget buildButtonSkeleton({bool isFullWidth = false}) {
//     return Container(
//       width: isFullWidth ? double.infinity : null,
//       height: 48,
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           _buildSkeletonIcon(20, 20),
//           AppDimens.small.widthBox,
//           _buildSkeletonText(80, 16),
//         ],
//       ),
//     );
//   }

//   Widget buildSalesTrendChartSkeleton() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: theme.shadowColor.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildSkeletonText(120, 20),
//           AppDimens.medium.heightBox,
//           Container(
//             height: 200,
//             decoration: BoxDecoration(
//               color: theme.colorScheme.surface,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(
//                 color: theme.colorScheme.outline.withOpacity(0.1),
//               ),
//             ),
//             child: Center(child: _buildSkeletonIcon(48, 48)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildSkeletonText(double width, double height) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Container(
//           width: width,
//           height: height,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [
//                 theme.colorScheme.outline.withOpacity(0.1),
//                 theme.colorScheme.outline.withOpacity(0.2),
//                 theme.colorScheme.outline.withOpacity(0.1),
//               ],
//               stops: [
//                 _animation.value - 0.3,
//                 _animation.value,
//                 _animation.value + 0.3,
//               ],
//             ),
//             borderRadius: BorderRadius.circular(4),
//           ),
//         );
//       },
//     );
//   }

//   Widget buildSkeletonIcon(double width, double height) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Container(
//           width: width,
//           height: height,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [
//                 theme.colorScheme.outline.withOpacity(0.1),
//                 theme.colorScheme.outline.withOpacity(0.2),
//                 theme.colorScheme.outline.withOpacity(0.1),
//               ],
//               stops: [
//                 _animation.value - 0.3,
//                 _animation.value,
//                 _animation.value + 0.3,
//               ],
//             ),
//             borderRadius: BorderRadius.circular(width / 2),
//           ),
//         );
//       },
//     );
//   }

