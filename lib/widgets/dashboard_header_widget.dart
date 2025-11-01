import 'dart:ffi';

import 'package:flutter/material.dart';
import '../components/extensions.dart';
import '../res/dimens.dart';

class DashboardHeaderWidget extends StatelessWidget {
  final String title;
  final Widget? iconButton;
  final ThemeData theme;
  const DashboardHeaderWidget({
    super.key,
    required this.title,
    required this.iconButton,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:iconButton!=null? MainAxisAlignment.spaceBetween:MainAxisAlignment.center,
      children: [
        AppDimens.medium.widthBox, // Spacer for centering
        Text(title, style: theme.textTheme.titleLarge),
        if (iconButton != null)
          IconTheme(
            data: IconThemeData(color: theme.colorScheme.onSurface),
            child: iconButton!,
          ),
      ],
    );
  }}