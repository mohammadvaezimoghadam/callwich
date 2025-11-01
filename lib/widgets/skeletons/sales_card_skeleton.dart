import 'package:flutter/material.dart';

class SalesCardSkeleton extends StatelessWidget {
  const SalesCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(width: 80, height: 12, radius: 6),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar(width: 120, height: 28, radius: 8),
              const SizedBox(width: 8),
              _bar(width: 36, height: 18, radius: 8),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _circle(size: 16),
              const SizedBox(width: 8),
              _bar(width: 60, height: 12, radius: 6),
              const SizedBox(width: 8),
              _bar(width: 80, height: 12, radius: 6),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar({required double width, required double height, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _circle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        shape: BoxShape.circle,
      ),
    );
  }
}