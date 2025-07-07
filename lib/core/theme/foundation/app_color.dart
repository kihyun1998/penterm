// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_theme.dart';

class AppColor {
  const AppColor({
    required this.background,
    required this.text,
    required this.hint,
    required this.border,
    required this.cardBackground,
    required this.cardButton,
    required this.onCardButton,
    required this.cardActionButton,
    required this.onCardActionButton,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.hover,
    required this.splash,
    required this.highlight,
    required this.primaryHover,
    required this.primarySplash,
    required this.primaryHighlight,
  });

  /// default
  final Color background;
  final Color text;
  final Color hint;
  final Color border;

  /// card
  final Color cardBackground;
  final Color cardButton;
  final Color onCardButton;
  final Color cardActionButton;
  final Color onCardActionButton;

  /// primary & secondary
  final Color primary;
  final Color onPrimary;
  final Color secondary;

  final Color hover;
  final Color splash;
  final Color highlight;
  final Color primaryHover;
  final Color primarySplash;
  final Color primaryHighlight;

  AppColor copyWith({
    Color? background,
    Color? text,
    Color? hint,
    Color? border,
    Color? cardBackground,
    Color? cardButton,
    Color? onCardButton,
    Color? cardActionButton,
    Color? onCardActionButton,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? hover,
    Color? splash,
    Color? highlight,
    Color? primaryHover,
    Color? primarySplash,
    Color? primaryHighlight,
  }) {
    return AppColor(
      background: background ?? this.background,
      text: text ?? this.text,
      hint: hint ?? this.hint,
      border: border ?? this.border,
      cardBackground: cardBackground ?? this.cardBackground,
      cardButton: cardButton ?? this.cardButton,
      onCardButton: onCardButton ?? this.onCardButton,
      cardActionButton: cardActionButton ?? this.cardActionButton,
      onCardActionButton: onCardActionButton ?? this.onCardActionButton,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      hover: hover ?? this.hover,
      splash: splash ?? this.splash,
      highlight: highlight ?? this.highlight,
      primaryHover: primaryHover ?? this.primaryHover,
      primarySplash: primarySplash ?? this.primarySplash,
      primaryHighlight: primaryHighlight ?? this.primaryHighlight,
    );
  }
}
