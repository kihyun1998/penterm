import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

import 'app_button.dart';

class AppIconTab extends ConsumerWidget {
  final String text;
  final bool isActive;
  final VoidCallback? onPressed;
  final EdgeInsets? margin;

  const AppIconTab({
    super.key,
    required this.text,
    required this.isActive,
    required this.onPressed,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      backgroundColor: isActive
          ? ref.color.primary.withOpacity(0.15)
          : ref.color.surfaceVariant.withOpacity(0.4),
      hoverColor: isActive ? ref.theme.color.primaryHover : null,
      splashColor: isActive ? ref.theme.color.primarySplash : null,
      highlightColor: isActive ? ref.theme.color.primaryHighlight : null,
      borderRadius: BorderRadius.circular(6),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      childPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onPressed: onPressed,
      child: Container(
        decoration: isActive
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: ref.color.primary,
                    width: 2,
                  ),
                ),
              )
            : null,
        child: Text(
          text,
          style: ref.font.semiBoldText12.copyWith(
            color: isActive
                ? ref.color.primary
                : ref.color.onBackground.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
