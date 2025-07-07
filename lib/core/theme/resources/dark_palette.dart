import 'package:flutter/material.dart';

abstract class DarkPalette {
  static const Color background = Color(0xFF09090B);
  static const Color text = Color(0xFFFAFAFA);
  static const Color hint = Color(0xFF757575);
  static const Color border = Color(0xFF262629);

  static const Color primary = Color(0xFFFAFAFA);
  static const Color onPrimary = Color(0xFF18181B);
  static const Color secondary = Color(0xFF27272A);

  /// card
  static const Color cardBackground = Color(0xFF171717);
  static const Color cardButton = Color(0xFF262626);
  static const Color onCardButton = Color(0xFFe5e5e5);
  static const Color cardActionButton = Color(0xff212121);
  static const Color onCardActionButton = Color(0xffe2e2e2);

  static final Color hover = primary.withValues(alpha: 0.08);
  static final Color splash = primary.withValues(alpha: 0.12);
  static final Color highlight = primary.withValues(alpha: 0.16);

  static final Color primaryHover = background.withValues(alpha: 0.08);
  static final Color primarySplash = background.withValues(alpha: 0.12);
  static final Color primaryHighlight = background.withValues(alpha: 0.16);
}
