import 'package:flutter/material.dart';

class LowStockBannerSkeleton extends StatelessWidget {
  const LowStockBannerSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _bannerSkeleton(context);
        },
      ),
    );
  }

  Widget _bannerSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _circle(size: 16),
                    const SizedBox(width: 8),
                    _bar(width: 120, height: 14),
                  ],
                ),
                const SizedBox(height: 8),
                _bar(width: 180, height: 12),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _rect(width: 72, height: 72, radius: 8),
        ],
      ),
    );
  }

  Widget _bar({required double width, required double height}) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
      );

  Widget _rect({required double width, required double height, double radius = 8}) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  Widget _circle({required double size}) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0x11000000),
          shape: BoxShape.circle,
        ),
      );
}