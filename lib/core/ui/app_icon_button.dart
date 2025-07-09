// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../util/svg/model/enum_svg_asset.dart';
import '../util/svg/widget/svg_icon.dart';
import 'app_button.dart';

class AppIconButton extends ConsumerWidget {
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

  /// child
  final SVGAsset icon;
  final Color? iconColor;
  final double? iconSize;

  const AppIconButton({
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
    this.onPressed,
    required this.icon,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppButton(
      isDisabled: isDisabled,

      /// size
      width: width,
      height: height,
      borderWidth: borderWidth,

      /// spacing
      margin: margin,
      childPadding: childPadding,

      /// color
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      hoverColor: hoverColor,
      splashColor: splashColor,
      highlightColor: highlightColor,

      /// radius
      borderRadius: borderRadius,

      /// onpressed
      onPressed: onPressed,

      child: Center(
        child: SVGIcon(
          asset: icon,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}
