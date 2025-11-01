import 'package:flutter/material.dart';
import '../components/extensions.dart';
import '../res/dimens.dart';

class ProductsListSkeletonWidget extends StatefulWidget {
  final ThemeData theme;

  const ProductsListSkeletonWidget({super.key, required this.theme});

  @override
  State<ProductsListSkeletonWidget> createState() => _ProductsListSkeletonWidgetState();
}

class _ProductsListSkeletonWidgetState extends State<ProductsListSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.medium.toDouble(),
            vertical: AppDimens.medium.toDouble(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _shimmerBox(width: 160, height: 28, radius: 6),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.medium.toDouble(),
          ),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: widget.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.theme.colorScheme.outline.withOpacity(0.15)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _shimmerCircle(20),
                AppDimens.small.widthBox,
                _shimmerBox(width: 140, height: 16, radius: 4),
              ],
            ),
          ),
        ),

        AppDimens.medium.heightBox,

        // Tabs
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.medium.toDouble(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tabSkeleton(width: 50),
              AppDimens.small.widthBox,
              _tabSkeleton(width: 50),
              AppDimens.small.widthBox,
              _tabSkeleton(width: 50),
            ],
          ),
        ),

        AppDimens.medium.heightBox,

        // Grid skeleton
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.medium.toDouble(),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: 8,
            itemBuilder: (context, index) => _productCardSkeleton(),
          ),
        ),

        AppDimens.large.heightBox,
      ],
    );
  }

  Widget _tabSkeleton({required double width }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.theme.colorScheme.outline.withOpacity(0.15)),
      ),
      child: _shimmerBox(width: width, height: 14, radius: 4),
    );
  }

  Widget _productCardSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widget.theme.shadowColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _shimmerBox(width: double.infinity, height: 110, radius: 10),
            ),
            AppDimens.small.heightBox,
            // Name line
            _shimmerBox(width: 120, height: 16, radius: 4),
            AppDimens.small.heightBox,
            // Price line
            Row(
              children: [
                _shimmerBox(width: 70, height: 14, radius: 4),
                AppDimens.small.widthBox,
                _shimmerBox(width: 28, height: 14, radius: 4),
              ],
            ),
            AppDimens.small.heightBox,
            // Stock line
            _shimmerBox(width: 90, height: 12, radius: 4),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height, double radius = 8}) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final double center = _anim.value;
        final double start = (center - 0.35).clamp(0.0, 1.0);
        final double end = (center + 0.35).clamp(0.0, 1.0);
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.theme.colorScheme.outline.withOpacity(0.14),
                widget.theme.colorScheme.outline.withOpacity(0.28),
                widget.theme.colorScheme.outline.withOpacity(0.14),
              ],
              stops: [start, center, end],
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerCircle(double size) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final double center = _anim.value;
        final double start = (center - 0.35).clamp(0.0, 1.0);
        final double end = (center + 0.35).clamp(0.0, 1.0);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.theme.colorScheme.outline.withOpacity(0.14),
                widget.theme.colorScheme.outline.withOpacity(0.28),
                widget.theme.colorScheme.outline.withOpacity(0.14),
              ],
              stops: [start, center, end],
            ),
          ),
        );
      },
    );
  }
}