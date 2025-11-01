import 'package:flutter/material.dart';

class AvailabilityStatusWidget extends StatelessWidget {
  final bool isAvailable;
  final String? customAvailableText;
  final String? customUnavailableText;
  final TextStyle? textStyle;

  const AvailabilityStatusWidget({
    Key? key,
    required this.isAvailable,
    this.customAvailableText,
    this.customUnavailableText,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF4CAF50),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(left: 8),
            ),
            Text(
              customAvailableText ?? 'موجود',
              style: textStyle ?? theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF44336),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFF44336),
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.only(left: 8),
            ),
            Text(
              customUnavailableText ?? 'ناموجود',
              style: textStyle ?? theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFFC62828),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }
} 