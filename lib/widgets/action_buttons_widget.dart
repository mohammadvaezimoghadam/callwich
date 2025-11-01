import 'package:flutter/material.dart';
import '../res/strings.dart';
import '../components/extensions.dart';
import '../res/dimens.dart';

class ActionButtonsWidget extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onNewSale;
  final VoidCallback onAddProduct;
  final VoidCallback onAddingredients;

  const ActionButtonsWidget({
    super.key,
    required this.theme,
    required this.onNewSale,
    required this.onAddProduct,
    required this.onAddingredients,
  });

  @override
  Widget build(BuildContext context) {
    // استفاده از theme برای رنگ‌ها و استایل‌ها
    final Color primaryColor = theme.colorScheme.primary;
    final Color onPrimary = theme.colorScheme.onPrimary;
    final Color secondaryColor = theme.colorScheme.secondary;
    final Color onSecondary = theme.colorScheme.onSecondary;
    final TextStyle buttonTextStyle =
        theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold) ??
        const TextStyle(fontWeight: FontWeight.bold);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: buildActionButton(
                icon: Icons.add_shopping_cart,
                text: AppStrings.newSale,
                isPrimary: true,
                onTap: onNewSale,
                primaryColor: primaryColor,
                onPrimary: onPrimary,
                secondaryColor: secondaryColor,
                onSecondary: onSecondary,
                textStyle: buttonTextStyle,
              ),
            ),
            AppDimens.medium.widthBox,
            Expanded(
              child: buildActionButton(
                icon: Icons.add_box,
                text: AppStrings.addProduct,
                isPrimary: false,
                onTap: onAddProduct,
                primaryColor: primaryColor,
                onPrimary: onPrimary,
                secondaryColor: secondaryColor,
                onSecondary: onSecondary,
                textStyle: buttonTextStyle,
              ),
            ),
          ],
        ),
        AppDimens.medium.heightBox,
        buildActionButton(
          icon: Icons.add_box,
          text: AppStrings.addingredients,
          isPrimary: false,
          onTap: onAddingredients,
          isFullWidth: true,
          primaryColor: primaryColor,
          onPrimary: onPrimary,
          secondaryColor: secondaryColor,
          onSecondary: onSecondary,
          textStyle: buttonTextStyle,
        ),
      ],
    );
  }

 static Widget buildActionButton({
    required IconData icon,
    required String text,
    required bool isPrimary,
    required VoidCallback onTap,
    bool isFullWidth = false,
    required Color primaryColor,
    required Color onPrimary,
    required Color secondaryColor,
    required Color onSecondary,
    required TextStyle textStyle,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? primaryColor : secondaryColor,
          foregroundColor: isPrimary ? onPrimary : onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0, // isPrimary ? 4 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isPrimary ? onPrimary : onSecondary),
            AppDimens.small.widthBox,
            Text(
              text,
              style: textStyle.copyWith(
                color: isPrimary ? onPrimary : onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
