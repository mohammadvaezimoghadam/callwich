import 'package:flutter/material.dart';
import 'package:callwich/res/strings.dart';

class LoginButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final Color mainColor;
  final String label;
  final bool enabled;
  final bool loading;

  const LoginButtonWidget({
    super.key,
    required this.onPressed,
    required this.mainColor,
    this.label = AppStrings.login,
    this.enabled = true,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (enabled && !loading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: mainColor,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: loading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: theme.textTheme.labelLarge,
              ),
      ),
    );
  }
} 