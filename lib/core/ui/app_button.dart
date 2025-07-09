// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

class AppButton extends ConsumerWidget {
  final bool isDisabled;

  /// size
  final double? width;
  final double? height;
  final double? borderWidth;

  /// spacing
  final EdgeInsets? margin;
  final EdgeInsets? childPadding;

  /// color
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hoverColor;
  final Color? splashColor;
  final Color? highlightColor;

  /// radius
  final BorderRadius? borderRadius;

  final VoidCallback? onPressed;
  final Widget child;

  const AppButton({
    super.key,
    this.isDisabled = false,
    this.width,
    this.height,
    this.borderWidth,
    this.margin,
    this.childPadding,
    this.backgroundColor,
    this.borderColor,
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
    this.borderRadius,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MouseRegion(
      cursor:
          isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: IgnorePointer(
        ignoring: isDisabled,
        child: Container(
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
              color: backgroundColor ?? ref.theme.color.background,
              borderRadius: borderRadius ?? BorderRadius.circular(8),
              border: borderColor != null
                  ? Border.all(width: borderWidth ?? 0, color: borderColor!)
                  : null),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              hoverColor: hoverColor ?? ref.theme.color.hover,
              splashColor: splashColor ?? ref.theme.color.splash,
              highlightColor: highlightColor ?? ref.theme.color.highlight,
              borderRadius: borderRadius ?? BorderRadius.circular(8),
              child: Padding(
                padding: childPadding ?? const EdgeInsets.all(0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
