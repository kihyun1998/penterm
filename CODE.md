# penterm
## Project Structure

```
penterm/
├── lib/
    ├── core/
    │   └── theme/
    │   │   ├── foundation/
    │   │       ├── app_color.dart
    │   │       ├── app_font.dart
    │   │       ├── app_mode.dart
    │   │       └── app_theme.dart
    │   │   └── resources/
    │   │       ├── dark_palette.dart
    │   │       ├── font.dart
    │   │       └── light_palette.dart
    └── main.dart
└── penterm.iml
```

## lib/core/theme/foundation/app_color.dart
```dart
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

```
## lib/core/theme/foundation/app_font.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_theme.dart';

class AppFont {
  AppFont({
    required this.font,
    required this.monoFont,
    required this.textColor,
    required this.hintColor,
  });

  final Font font;
  final Font monoFont;
  final Color textColor;
  final Color hintColor;

  // ==================== Pretendard Regular ====================
  TextStyle get regularText10 => TextStyle(
      fontFamily: font.name,
      fontSize: 10,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText11 => TextStyle(
      fontFamily: font.name,
      fontSize: 11,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText12 => TextStyle(
      fontFamily: font.name,
      fontSize: 12,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText13 => TextStyle(
      fontFamily: font.name,
      fontSize: 13,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText14 => TextStyle(
      fontFamily: font.name,
      fontSize: 14,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText15 => TextStyle(
      fontFamily: font.name,
      fontSize: 15,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText16 => TextStyle(
      fontFamily: font.name,
      fontSize: 16,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText17 => TextStyle(
      fontFamily: font.name,
      fontSize: 17,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText18 => TextStyle(
      fontFamily: font.name,
      fontSize: 18,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText19 => TextStyle(
      fontFamily: font.name,
      fontSize: 19,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText20 => TextStyle(
      fontFamily: font.name,
      fontSize: 20,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText21 => TextStyle(
      fontFamily: font.name,
      fontSize: 21,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText22 => TextStyle(
      fontFamily: font.name,
      fontSize: 22,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText23 => TextStyle(
      fontFamily: font.name,
      fontSize: 23,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);
  TextStyle get regularText24 => TextStyle(
      fontFamily: font.name,
      fontSize: 24,
      fontWeight: font.regular,
      color: textColor,
      height: 1.4);

  // ==================== Pretendard Medium ====================
  TextStyle get mediumText10 => TextStyle(
      fontFamily: font.name,
      fontSize: 10,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText11 => TextStyle(
      fontFamily: font.name,
      fontSize: 11,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText12 => TextStyle(
      fontFamily: font.name,
      fontSize: 12,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText13 => TextStyle(
      fontFamily: font.name,
      fontSize: 13,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText14 => TextStyle(
      fontFamily: font.name,
      fontSize: 14,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText15 => TextStyle(
      fontFamily: font.name,
      fontSize: 15,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText16 => TextStyle(
      fontFamily: font.name,
      fontSize: 16,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText17 => TextStyle(
      fontFamily: font.name,
      fontSize: 17,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText18 => TextStyle(
      fontFamily: font.name,
      fontSize: 18,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText19 => TextStyle(
      fontFamily: font.name,
      fontSize: 19,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText20 => TextStyle(
      fontFamily: font.name,
      fontSize: 20,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText21 => TextStyle(
      fontFamily: font.name,
      fontSize: 21,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText22 => TextStyle(
      fontFamily: font.name,
      fontSize: 22,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText23 => TextStyle(
      fontFamily: font.name,
      fontSize: 23,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);
  TextStyle get mediumText24 => TextStyle(
      fontFamily: font.name,
      fontSize: 24,
      fontWeight: font.medium,
      color: textColor,
      height: 1.4);

  // ==================== Pretendard SemiBold ====================
  TextStyle get semiBoldText10 => TextStyle(
      fontFamily: font.name,
      fontSize: 10,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText11 => TextStyle(
      fontFamily: font.name,
      fontSize: 11,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText12 => TextStyle(
      fontFamily: font.name,
      fontSize: 12,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText13 => TextStyle(
      fontFamily: font.name,
      fontSize: 13,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText14 => TextStyle(
      fontFamily: font.name,
      fontSize: 14,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText15 => TextStyle(
      fontFamily: font.name,
      fontSize: 15,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText16 => TextStyle(
      fontFamily: font.name,
      fontSize: 16,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText17 => TextStyle(
      fontFamily: font.name,
      fontSize: 17,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText18 => TextStyle(
      fontFamily: font.name,
      fontSize: 18,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText19 => TextStyle(
      fontFamily: font.name,
      fontSize: 19,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText20 => TextStyle(
      fontFamily: font.name,
      fontSize: 20,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText21 => TextStyle(
      fontFamily: font.name,
      fontSize: 21,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText22 => TextStyle(
      fontFamily: font.name,
      fontSize: 22,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText23 => TextStyle(
      fontFamily: font.name,
      fontSize: 23,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);
  TextStyle get semiBoldText24 => TextStyle(
      fontFamily: font.name,
      fontSize: 24,
      fontWeight: font.semiBold,
      color: textColor,
      height: 1.4);

  // ==================== Pretendard Bold ====================
  TextStyle get boldText10 => TextStyle(
      fontFamily: font.name,
      fontSize: 10,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText11 => TextStyle(
      fontFamily: font.name,
      fontSize: 11,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText12 => TextStyle(
      fontFamily: font.name,
      fontSize: 12,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText13 => TextStyle(
      fontFamily: font.name,
      fontSize: 13,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText14 => TextStyle(
      fontFamily: font.name,
      fontSize: 14,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText15 => TextStyle(
      fontFamily: font.name,
      fontSize: 15,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText16 => TextStyle(
      fontFamily: font.name,
      fontSize: 16,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText17 => TextStyle(
      fontFamily: font.name,
      fontSize: 17,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText18 => TextStyle(
      fontFamily: font.name,
      fontSize: 18,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText19 => TextStyle(
      fontFamily: font.name,
      fontSize: 19,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText20 => TextStyle(
      fontFamily: font.name,
      fontSize: 20,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText21 => TextStyle(
      fontFamily: font.name,
      fontSize: 21,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText22 => TextStyle(
      fontFamily: font.name,
      fontSize: 22,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText23 => TextStyle(
      fontFamily: font.name,
      fontSize: 23,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);
  TextStyle get boldText24 => TextStyle(
      fontFamily: font.name,
      fontSize: 24,
      fontWeight: font.bold,
      color: textColor,
      height: 1.4);

  // ==================== Space Mono Regular ====================
  TextStyle get monoRegularText10 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 10,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText11 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 11,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText12 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 12,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText13 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 13,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText14 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 14,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText15 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 15,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText16 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 16,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText17 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 17,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText18 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 18,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText19 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 19,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText20 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 20,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText21 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 21,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText22 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 22,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText23 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 23,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);
  TextStyle get monoRegularText24 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 24,
      fontWeight: monoFont.regular,
      color: textColor,
      height: 1.3);

  // ==================== Space Mono Medium ====================
  TextStyle get monoMediumText10 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 10,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText11 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 11,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText12 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 12,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText13 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 13,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText14 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 14,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText15 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 15,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText16 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 16,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText17 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 17,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText18 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 18,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText19 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 19,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText20 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 20,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText21 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 21,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText22 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 22,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText23 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 23,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);
  TextStyle get monoMediumText24 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 24,
      fontWeight: monoFont.medium,
      color: textColor,
      height: 1.3);

  // ==================== Space Mono SemiBold ====================
  TextStyle get monoSemiBoldText10 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 10,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText11 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 11,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText12 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 12,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText13 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 13,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText14 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 14,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText15 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 15,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText16 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 16,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText17 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 17,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText18 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 18,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText19 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 19,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText20 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 20,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText21 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 21,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText22 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 22,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText23 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 23,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);
  TextStyle get monoSemiBoldText24 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 24,
      fontWeight: monoFont.semiBold,
      color: textColor,
      height: 1.3);

  // ==================== Space Mono Bold ====================
  TextStyle get monoBoldText10 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 10,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText11 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 11,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText12 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 12,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText13 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 13,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText14 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 14,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText15 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 15,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText16 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 16,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText17 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 17,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText18 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 18,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText19 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 19,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText20 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 20,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText21 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 21,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText22 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 22,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText23 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 23,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);
  TextStyle get monoBoldText24 => TextStyle(
      fontFamily: monoFont.name,
      fontSize: 24,
      fontWeight: monoFont.bold,
      color: textColor,
      height: 1.3);

  // ==================== Hint 텍스트 ====================
  TextStyle get hintText10 => TextStyle(
      fontFamily: font.name,
      fontSize: 10,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText11 => TextStyle(
      fontFamily: font.name,
      fontSize: 11,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText12 => TextStyle(
      fontFamily: font.name,
      fontSize: 12,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText13 => TextStyle(
      fontFamily: font.name,
      fontSize: 13,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText14 => TextStyle(
      fontFamily: font.name,
      fontSize: 14,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText15 => TextStyle(
      fontFamily: font.name,
      fontSize: 15,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText16 => TextStyle(
      fontFamily: font.name,
      fontSize: 16,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText17 => TextStyle(
      fontFamily: font.name,
      fontSize: 17,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText18 => TextStyle(
      fontFamily: font.name,
      fontSize: 18,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText19 => TextStyle(
      fontFamily: font.name,
      fontSize: 19,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText20 => TextStyle(
      fontFamily: font.name,
      fontSize: 20,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText21 => TextStyle(
      fontFamily: font.name,
      fontSize: 21,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText22 => TextStyle(
      fontFamily: font.name,
      fontSize: 22,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText23 => TextStyle(
      fontFamily: font.name,
      fontSize: 23,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);
  TextStyle get hintText24 => TextStyle(
      fontFamily: font.name,
      fontSize: 24,
      fontWeight: font.regular,
      color: hintColor,
      height: 1.4);

  // ==================== 유틸리티 메소드 ====================
  TextStyle withColor(TextStyle style, Color color) =>
      style.copyWith(color: color);
  TextStyle withWeight(TextStyle style, FontWeight weight) =>
      style.copyWith(fontWeight: weight);
  TextStyle withSize(TextStyle style, double size) =>
      style.copyWith(fontSize: size);
  TextStyle withHeight(TextStyle style, double height) =>
      style.copyWith(height: height);
  TextStyle withOpacity(TextStyle style, double opacity) =>
      style.copyWith(color: style.color?.withValues(alpha: opacity));

  AppFont copyWith({
    Font? font,
    Font? monoFont,
    Color? textColor,
    Color? hintColor,
  }) {
    return AppFont(
      font: font ?? this.font,
      monoFont: monoFont ?? this.monoFont,
      textColor: textColor ?? this.textColor,
      hintColor: hintColor ?? this.hintColor,
    );
  }
}

```
## lib/core/theme/foundation/app_mode.dart
```dart
part of 'app_theme.dart';

enum AppMode {
  light,
  dark;

  String toJson() => name;

  static AppMode fromJson(String json) {
    return AppMode.values.firstWhere(
      (mode) => mode.name == json,
      orElse: () => AppMode.light,
    );
  }
}

```
## lib/core/theme/foundation/app_theme.dart
```dart
import 'package:flutter/material.dart';

import '../resources/font.dart';

part 'app_color.dart';
part 'app_font.dart';
part 'app_mode.dart';

abstract class AppTheme {
  AppMode get mode;
  AppColor get color;
  AppFont get font;

  ThemeData get themeData;
}

```
## lib/core/theme/resources/dark_palette.dart
```dart
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

```
## lib/core/theme/resources/font.dart
```dart
import 'package:flutter/material.dart';

abstract class Font {
  Font({
    required this.name,
    required this.regular,
    required this.medium,
    required this.semiBold,
    required this.bold,
  });

  final String name;
  final FontWeight regular;
  final FontWeight medium;
  final FontWeight semiBold;
  final FontWeight bold;
}

class Pretendard implements Font {
  const Pretendard();

  @override
  final String name = 'Pretendard';

  @override
  final FontWeight regular = FontWeight.w400;

  @override
  final FontWeight medium = FontWeight.w500;

  @override
  final FontWeight semiBold = FontWeight.w600;

  @override
  final FontWeight bold = FontWeight.w700;
}

class SpaceMono implements Font {
  const SpaceMono();

  @override
  final String name = 'Space Mono';

  @override
  final FontWeight regular = FontWeight.w400;

  @override
  final FontWeight medium =
      FontWeight.w400; // Space Mono에는 medium이 없어서 regular 사용

  @override
  final FontWeight semiBold =
      FontWeight.w700; // Space Mono에는 semiBold가 없어서 bold 사용

  @override
  final FontWeight bold = FontWeight.w700;
}

```
## lib/core/theme/resources/light_palette.dart
```dart
import 'package:flutter/material.dart';

abstract class LightPalette {
  // Primary colors - Neon/Gaming Theme
  static const Color primary = Color(0xFF8B5CF6); // Violet-500
  static const Color primaryVariant = Color(0xFF7C3AED); // Violet-600
  static const Color secondary = Color(0xFF10B981); // Emerald-500
  static const Color secondaryVariant = Color(0xFF059669); // Emerald-600

  // Background colors - Gaming Style Light Mode
  static const Color background = Color(0xFFF8FAFC); // 약간 보라 틴트
  static const Color surface = Color(0xFFF1F5F9); // 쿨톤 표면
  static const Color surfaceVariant = Color(0xFFE2E8F0); // 더 진한 쿨톤

  // Terminal specific colors
  static const Color terminalBackground = Color(0xFF1F2937); // Gray-800
  static const Color terminalSurface = Color(0xFF374151); // Gray-700
  static const Color terminalBorder = Color(0xFF6B7280); // Gray-500

  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF111827); // Gray-900
  static const Color onSurface = Color(0xFF111827); // Gray-900
  static const Color onSurfaceVariant = Color(0xFF6B7280); // Gray-500

  // Terminal text colors
  static const Color terminalText = Color(0xFFD1D5DB); // Gray-300
  static const Color terminalPrompt = Color(0xFF10B981); // Emerald-500
  static const Color terminalCommand = Color(0xFF8B5CF6); // Violet-500
  static const Color terminalOutput = Color(0xFFD1D5DB); // Gray-300

  // Status colors
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color successVariant = Color(0xFF059669); // Emerald-600
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color errorVariant = Color(0xFFDC2626); // Red-600
  static const Color warning = Color(0xFFF59E0B); // Yellow-500
  static const Color info = Color(0xFF8B5CF6); // Violet-500

  // Connection status
  static const Color connected = Color(0xFF10B981); // Emerald-500
  static const Color disconnected = Color(0xFFEF4444); // Red-500
  static const Color connecting = Color(0xFFF59E0B); // Yellow-500

  // Interactive colors - Gaming Style
  static const Color hover = Color(0xFFE2E8F0); // 쿨톤 hover
  static const Color pressed = Color(0xFFCBD5E1); // 쿨톤 pressed
  static const Color disabled = Color(0xFF94A3B8); // 슬레이트 400
  static const Color border = Color(0xFFCBD5E1); // 슬레이트 300

  // Divider and outline - Gaming Style
  static const Color divider = Color(0xFFE2E8F0); // 슬레이트 200
  static const Color outline = Color(0xFFCBD5E1); // 슬레이트 300

  // Gaming-specific accent colors for Light Mode
  static const Color gamingAccent = Color(0xFFE879F9); // 핑크 글로우
  static const Color neonHighlight = Color(0xFFDDD6FE); // 바이올렛 하이라이트
  static const Color energyGlow = Color(0xFF34D399); // 에너지 글로우
  static const Color powerRing = Color(0xFFF0ABFC); // 퓨샤 하이라이트

  // Accent colors for neon effects - Light Mode optimized
  static const Color neonPurple = Color(0xFF8B5CF6); // Violet-500
  static const Color neonGreen = Color(0xFF10B981); // Emerald-500
  static const Color neonPink = Color(0xFFEC4899); // Pink-500
  static const Color neonBlue = Color(0xFF3B82F6); // Blue-500

  // Gaming UI enhancement colors
  static const Color glowShadow =
      Color(0x1A8B5CF6); // 10% opacity violet for shadows
  static const Color energyShadow =
      Color(0x1A10B981); // 10% opacity emerald for shadows

  // Gaming-specific colors
  static const Color gamingHighlight = Color(0xFFDDD6FE); // Violet-200
  static const Color gamingShadow = Color(0xFF581C87); // Violet-900
  static const Color powerGlow = Color(0xFF34D399); // Emerald-400
  static const Color neonTrail = Color(0xFFF472B6); // Pink-400 trail effect
  static const Color energyCore =
      Color(0xFFA855F7); // Violet-400 for energy cores
}

abstract class DarkPalette {
  // Primary colors - Neon/Gaming Theme
  static const Color primary = Color(0xFF8B5CF6); // Violet-500
  static const Color primaryVariant = Color(0xFF7C3AED); // Violet-600
  static const Color secondary = Color(0xFF10B981); // Emerald-500
  static const Color secondaryVariant = Color(0xFF059669); // Emerald-600

  // Background colors
  static const Color background = Color(0xFF111827); // Gray-900
  static const Color surface = Color(0xFF1F2937); // Gray-800
  static const Color surfaceVariant = Color(0xFF374151); // Gray-700

  // Terminal specific colors
  static const Color terminalBackground = Color(0xFF000000); // Pure black
  static const Color terminalSurface = Color(0xFF111827); // Gray-900
  static const Color terminalBorder = Color(0xFF374151); // Gray-700

  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFFF9FAFB); // Gray-50
  static const Color onSurface = Color(0xFFF9FAFB); // Gray-50
  static const Color onSurfaceVariant = Color(0xFF9CA3AF); // Gray-400

  // Terminal text colors
  static const Color terminalText = Color(0xFFD1D5DB); // Gray-300
  static const Color terminalPrompt = Color(0xFF10B981); // Emerald-500
  static const Color terminalCommand = Color(0xFF8B5CF6); // Violet-500
  static const Color terminalOutput = Color(0xFFD1D5DB); // Gray-300

  // Status colors
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color successVariant = Color(0xFF059669); // Emerald-600
  static const Color error = Color(0xFFF87171); // Red-400
  static const Color errorVariant = Color(0xFFEF4444); // Red-500
  static const Color warning = Color(0xFFFBBF24); // Yellow-400
  static const Color info = Color(0xFF8B5CF6); // Violet-500

  // Connection status
  static const Color connected = Color(0xFF10B981); // Emerald-500
  static const Color disconnected = Color(0xFFF87171); // Red-400
  static const Color connecting = Color(0xFFFBBF24); // Yellow-400

  // Interactive colors
  static const Color hover = Color(0xFF374151); // Gray-700
  static const Color pressed = Color(0xFF4B5563); // Gray-600
  static const Color disabled = Color(0xFF6B7280); // Gray-500
  static const Color border = Color(0xFF4B5563); // Gray-600

  // Divider and outline
  static const Color divider = Color(0xFF374151); // Gray-700
  static const Color outline = Color(0xFF4B5563); // Gray-600

  // Accent colors for neon effects - Dark Mode optimized
  static const Color neonPurple =
      Color(0xFFA855F7); // Violet-400 (brighter for dark mode)
  static const Color neonGreen =
      Color(0xFF34D399); // Emerald-400 (brighter for dark mode)
  static const Color neonPink =
      Color(0xFFF472B6); // Pink-400 (brighter for dark mode)
  static const Color neonBlue =
      Color(0xFF60A5FA); // Blue-400 (brighter for dark mode)

  // Gaming-specific colors
  static const Color gamingHighlight = Color(0xFFDDD6FE); // Violet-200
  static const Color gamingShadow = Color(0xFF581C87); // Violet-900
  static const Color powerGlow = Color(0xFF34D399); // Emerald-400
  static const Color neonTrail = Color(0xFFF472B6); // Pink-400 trail effect
  static const Color energyCore =
      Color(0xFFA855F7); // Violet-400 for energy cores
}

// Usage example for Gaming Style SSH Terminal:
// 
// class AppTheme {
//   static ThemeData lightGamingTheme = ThemeData(
//     primaryColor: LightPalette.primary,
//     scaffoldBackgroundColor: LightPalette.background,
//     colorScheme: ColorScheme.light(
//       primary: LightPalette.primary,
//       secondary: LightPalette.secondary,
//       surface: LightPalette.surface,
//       background: LightPalette.background,
//     ),
//   );
//
//   static ThemeData darkGamingTheme = ThemeData(
//     primaryColor: DarkPalette.primary,
//     scaffoldBackgroundColor: DarkPalette.background,
//     colorScheme: ColorScheme.dark(
//       primary: DarkPalette.primary,
//       secondary: DarkPalette.secondary,
//       surface: DarkPalette.surface,
//       background: DarkPalette.background,
//     ),
//   );
// }
//
// Gaming-style connect button:
//
// Widget gamingConnectButton(bool isDarkMode) {
//   final palette = isDarkMode ? DarkPalette : LightPalette;
//   
//   return Container(
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(8),
//       boxShadow: [
//         BoxShadow(
//           color: palette.primary.withOpacity(0.4),
//           blurRadius: 15,
//           spreadRadius: 0,
//           offset: Offset(0, 4),
//         ),
//       ],
//     ),
//     child: ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: palette.primary,
//         foregroundColor: palette.onPrimary,
//         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//       child: Text('Connect', 
//            style: TextStyle(fontWeight: FontWeight.bold)),
//       onPressed: () {
//         // Connect logic
//       },
//     ),
//   );
// }
```
## lib/main.dart
```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

```
## penterm.iml
```iml
<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4">
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://$MODULE_DIR$">
      <sourceFolder url="file://$MODULE_DIR$/lib" isTestSource="false" />
      <sourceFolder url="file://$MODULE_DIR$/test" isTestSource="true" />
      <excludeFolder url="file://$MODULE_DIR$/.dart_tool" />
      <excludeFolder url="file://$MODULE_DIR$/.idea" />
      <excludeFolder url="file://$MODULE_DIR$/build" />
    </content>
    <orderEntry type="sourceFolder" forTests="false" />
    <orderEntry type="library" name="Dart SDK" level="project" />
    <orderEntry type="library" name="Flutter Plugins" level="project" />
    <orderEntry type="library" name="Dart Packages" level="project" />
  </component>
</module>

```
