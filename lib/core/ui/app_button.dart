import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

class AppButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const AppButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? ref.theme.color.background,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          hoverColor: ref.theme.color.hover,
          // splashColor: ref.theme.color.splash,
          // highlightColor: ref.theme.color.highlight,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: child,
          ),
        ),
      ),
    );
  }
}
