# penterm
## Project Structure

```
penterm/
└── lib/
    ├── core/
        ├── const/
        │   ├── enum_debounce_key.dart
        │   └── enum_hive_key.dart
        ├── localization/
        │   ├── l10n/
        │   │   ├── intl_en.arb
        │   │   └── intl_ko.arb
        │   └── provider/
        │   │   ├── language_provider.dart
        │   │   └── locale_state_provider.dart
        ├── theme/
        │   ├── foundation/
        │   │   ├── app_color.dart
        │   │   ├── app_font.dart
        │   │   ├── app_mode.dart
        │   │   └── app_theme.dart
        │   ├── provider/
        │   │   └── theme_provider.dart
        │   ├── resources/
        │   │   ├── dark_palette.dart
        │   │   ├── font.dart
        │   │   └── light_palette.dart
        │   ├── dark_theme.dart
        │   └── light_theme.dart
        ├── ui/
        │   ├── title_bar/
        │   │   ├── provider/
        │   │   │   └── is_window_maximized_provider.dart
        │   │   ├── app_title_bar.dart
        │   │   └── terminal_tab_widget.dart
        │   ├── app_button.dart
        │   ├── app_icon_button.dart
        │   └── app_icon_tab.dart
        └── util/
        │   ├── debounce/
        │       ├── debounce_operation.dart
        │       └── debounce_service.dart
        │   └── svg/
        │       ├── enum/
        │           └── color_target.dart
        │       ├── model/
        │           └── enum_svg_asset.dart
        │       ├── widget/
        │           └── svg_icon.dart
        │       └── svg_util.dart
    ├── feature/
        └── terminal/
        │   ├── model/
        │       ├── enum_tab_type.dart
        │       └── tab_info.dart
        │   └── provider/
        │       ├── active_tabinfo_provider.dart
        │       ├── tab_list_provider.dart
        │       └── tab_provider.dart
    ├── page/
        ├── example_heme.dart
        └── main_page.dart
    └── main.dart
```

## lib/core/const/enum_debounce_key.dart
```dart
enum DebounceKey {
  locale('locale'),
  theme('theme'),
  ;

  final String key;
  const DebounceKey(this.key);
}

```
## lib/core/const/enum_hive_key.dart
```dart
enum HiveKey {
  boxSettings('penterm_box_settings'),
  locale('locale'),
  theme('theme'),
  ;

  final String key;

  const HiveKey(this.key);
}

```
## lib/core/localization/l10n/intl_en.arb
```arb
{
  "appTitle": "Flutter Snippets",
  "themeMode": "Theme Mode",
  "language": "Language",
  "lightTheme": "Light",
  "darkTheme": "Dark",
  "systemTheme": "System",
  "english": "English",
  "korean": "Korean",
  "welcomeMessage": "Welcome to Flutter Snippets App!",
  "description": "This is an example page with theme and language switching."
}
```
## lib/core/localization/l10n/intl_ko.arb
```arb
{
  "appTitle": "플러터 스니펫",
  "themeMode": "테마 모드",
  "language": "언어",
  "lightTheme": "라이트",
  "darkTheme": "다크",
  "systemTheme": "시스템",
  "english": "영어",
  "korean": "한국어",
  "welcomeMessage": "플러터 스니펫 앱에 오신 것을 환영합니다!",
  "description": "테마와 언어 전환이 가능한 예제 페이지입니다."
}
```
## lib/core/localization/provider/language_provider.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../generated/l10n.dart';
import 'locale_state_provider.dart';

part 'language_provider.g.dart';

@Riverpod(dependencies: [LocaleState])
S language(Ref ref) {
  ref.watch(localeStateProvider);
  return S.current;
}

```
## lib/core/localization/provider/locale_state_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../const/enum_debounce_key.dart';
import '../../const/enum_hive_key.dart';
import '../../util/debounce/debounce_service.dart';

part 'locale_state_provider.g.dart';

@Riverpod(dependencies: [], keepAlive: true)
class LocaleState extends _$LocaleState {
  Box<String>? _box;

  @override
  Locale build() {
    try {
      final box = Hive.box<String>(HiveKey.boxSettings.key);
      final savedLocale = box.get(HiveKey.locale.key);

      if (savedLocale != null) {
        return Locale(savedLocale);
      }
    } catch (e) {
      // 에러시 기본값
    }

    return const Locale('ko');
  }

  /// supported locale list
  static const supportedLocales = [
    Locale('ko'),
    Locale('en'),
  ];

  /// 로케일 변경
  /// UI는 즉시 변경되고, 저장은 debounce로 처리
  Future<void> setLocale(Locale locale) async {
    // 1. UI 즉시 업데이트 (언어 변경은 즉시 반영되어야 함)
    state = locale;

    // 2. 저장은 debounce로 처리
    _scheduleLocaleSave(locale);
  }

  /// 로케일 토글 (한국어 ↔ 영어)
  /// UI는 즉시 변경되고, 저장은 debounce로 처리
  Future<void> toggleLocale() async {
    final newLocale =
        state.languageCode == 'ko' ? const Locale('en') : const Locale('ko');

    // 1. UI 즉시 업데이트
    state = newLocale;

    // 2. 저장은 debounce로 처리
    _scheduleLocaleSave(newLocale);
  }

  /// 저장된 로케일 불러오기 (앱 시작 시 한 번만 호출)
  Future<void> loadSavedLocale() async {
    _box ??= await _openBox();
    final savedLocale = _box!.get(HiveKey.locale.key);
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
  }

  /// 현재 대기 중인 로케일 저장 작업을 즉시 실행
  ///
  /// 앱 종료 시나 긴급히 저장이 필요한 경우 사용
  /// 반환값: 저장 작업이 있었으면 true, 없었으면 false
  Future<bool> flushLocaleSave() async {
    return await DebounceService.instance
        .executeImmediately(DebounceKey.locale.key);
  }

  /// Provider 정리 시 대기 중인 저장 작업 완료
  ///
  /// 이 메서드는 Provider가 dispose될 때 자동으로 호출되지 않으므로
  /// 필요한 경우 수동으로 호출해야 함
  Future<void> dispose() async {
    await flushLocaleSave();
  }

  /// 로케일 저장 작업을 debounce 서비스에 스케줄링
  void _scheduleLocaleSave(Locale locale) {
    DebounceService.instance.schedule(
      key: DebounceKey.locale.key,
      operation: () => _saveLocale(locale),
      delay: const Duration(seconds: 1), // 로케일은 기본 500ms
    );
  }

  /// 로케일 저장 (실제 저장 로직)
  Future<void> _saveLocale(Locale locale) async {
    try {
      _box ??= await _openBox();
      await _box!.put(HiveKey.locale.key, locale.languageCode);
    } catch (e) {
      // 저장 실패 시 로그 (에러를 던지지 않음으로써 UI 동작은 계속됨)
    }
  }

  Future<Box<String>> _openBox() async {
    if (!Hive.isBoxOpen(HiveKey.boxSettings.key)) {
      return await Hive.openBox(HiveKey.boxSettings.key);
    }
    return Hive.box(HiveKey.boxSettings.key);
  }
}

```
## lib/core/theme/dark_theme.dart
```dart
import 'package:flutter/material.dart';

import 'foundation/app_theme.dart';
import 'resources/dark_palette.dart';
import 'resources/font.dart';

class DarkTheme implements AppTheme {
  static final DarkTheme _instance = DarkTheme._internal();

  factory DarkTheme() => _instance;

  late final AppColor _color;
  late final AppFont _font;

  DarkTheme._internal() {
    _color = const AppColor(
      primary: DarkPalette.primary,
      primarySoft: DarkPalette.primarySoft,
      primaryVariant: DarkPalette.primaryVariant,
      primaryHover: DarkPalette.primaryHover,
      primarySplash: DarkPalette.primarySplash,
      primaryHighlight: DarkPalette.primaryHighlight,
      secondary: DarkPalette.secondary,
      secondaryVariant: DarkPalette.secondaryVariant,
      background: DarkPalette.background,
      surface: DarkPalette.surface,
      surfaceVariant: DarkPalette.surfaceVariant,
      surfaceVariantSoft: DarkPalette.surfaceVariantSoft,
      terminalBackground: DarkPalette.terminalBackground,
      terminalSurface: DarkPalette.terminalSurface,
      terminalBorder: DarkPalette.terminalBorder,
      onPrimary: DarkPalette.onPrimary,
      onSecondary: DarkPalette.onSecondary,
      onBackground: DarkPalette.onBackground,
      onBackgroundSoft: DarkPalette.onBackgroundSoft,
      onSurface: DarkPalette.onSurface,
      onSurfaceVariant: DarkPalette.onSurfaceVariant,
      terminalText: DarkPalette.terminalText,
      terminalPrompt: DarkPalette.terminalPrompt,
      terminalCommand: DarkPalette.terminalCommand,
      terminalOutput: DarkPalette.terminalOutput,
      success: DarkPalette.success,
      successVariant: DarkPalette.successVariant,
      error: DarkPalette.error,
      errorVariant: DarkPalette.errorVariant,
      warning: DarkPalette.warning,
      info: DarkPalette.info,
      connected: DarkPalette.connected,
      disconnected: DarkPalette.disconnected,
      connecting: DarkPalette.connecting,
      hover: DarkPalette.hover,
      splash: DarkPalette.splash,
      highlight: DarkPalette.highlight,
      pressed: DarkPalette.pressed,
      disabled: DarkPalette.disabled,
      border: DarkPalette.border,
      divider: DarkPalette.divider,
      outline: DarkPalette.outline,
      neonPurple: DarkPalette.neonPurple,
      neonGreen: DarkPalette.neonGreen,
      neonPink: DarkPalette.neonPink,
      neonBlue: DarkPalette.neonBlue,
      gamingHighlight: DarkPalette.gamingHighlight,
      gamingShadow: DarkPalette.gamingShadow,
      powerGlow: DarkPalette.powerGlow,
      neonTrail: DarkPalette.neonTrail,
      energyCore: DarkPalette.energyCore,
    );

    _font = AppFont(
      font: const Pretendard(),
      monoFont: const SpaceMono(),
      textColor: _color.onBackground,
      hintColor: _color.onSurfaceVariant,
    );
  }

  @override
  AppColor get color => _color;

  @override
  AppFont get font => _font;

  @override
  AppMode get mode => AppMode.dark;

  @override
  ThemeData get themeData => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _color.background,
      );
}

```
## lib/core/theme/foundation/app_color.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'app_theme.dart';

class AppColor {
  // Primary colors
  final Color primary;
  final Color primarySoft;
  final Color primaryVariant;
  final Color primaryHover;
  final Color primarySplash;
  final Color primaryHighlight;

  final Color secondary;
  final Color secondaryVariant;

  // Background colors
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceVariantSoft;

  // Terminal specific colors
  final Color terminalBackground;
  final Color terminalSurface;
  final Color terminalBorder;

  // Text colors
  final Color onPrimary;
  final Color onSecondary;
  final Color onBackground;
  final Color onBackgroundSoft;
  final Color onSurface;
  final Color onSurfaceVariant;

  // Terminal text colors
  final Color terminalText;
  final Color terminalPrompt;
  final Color terminalCommand;
  final Color terminalOutput;

  // Status colors
  final Color success;
  final Color successVariant;
  final Color error;
  final Color errorVariant;
  final Color warning;
  final Color info;

  // Connection status
  final Color connected;
  final Color disconnected;
  final Color connecting;

  // Interactive colors
  final Color hover;
  final Color splash;
  final Color highlight;
  final Color pressed;
  final Color disabled;
  final Color border;

  // Divider and outline
  final Color divider;
  final Color outline;

  // Accent colors for neon effects
  final Color neonPurple;
  final Color neonGreen;
  final Color neonPink;
  final Color neonBlue;

  // Gaming-specific colors
  final Color gamingHighlight;
  final Color gamingShadow;
  final Color powerGlow;
  final Color neonTrail;
  final Color energyCore;

  const AppColor({
    required this.primary,
    required this.primarySoft,
    required this.primaryVariant,
    required this.primaryHover,
    required this.primarySplash,
    required this.primaryHighlight,
    required this.secondary,
    required this.secondaryVariant,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceVariantSoft,
    required this.terminalBackground,
    required this.terminalSurface,
    required this.terminalBorder,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onBackgroundSoft,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.terminalText,
    required this.terminalPrompt,
    required this.terminalCommand,
    required this.terminalOutput,
    required this.success,
    required this.successVariant,
    required this.error,
    required this.errorVariant,
    required this.warning,
    required this.info,
    required this.connected,
    required this.disconnected,
    required this.connecting,
    required this.hover,
    required this.splash,
    required this.highlight,
    required this.pressed,
    required this.disabled,
    required this.border,
    required this.divider,
    required this.outline,
    required this.neonPurple,
    required this.neonGreen,
    required this.neonPink,
    required this.neonBlue,
    required this.gamingHighlight,
    required this.gamingShadow,
    required this.powerGlow,
    required this.neonTrail,
    required this.energyCore,
  });

  AppColor copyWith({
    Color? primary,
    Color? primarySoft,
    Color? primaryVariant,
    Color? primaryHover,
    Color? primarySplash,
    Color? primaryHighlight,
    Color? secondary,
    Color? secondaryVariant,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? surfaceVariantSoft,
    Color? terminalBackground,
    Color? terminalSurface,
    Color? terminalBorder,
    Color? onPrimary,
    Color? onSecondary,
    Color? onBackground,
    Color? onBackgroundSoft,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? terminalText,
    Color? terminalPrompt,
    Color? terminalCommand,
    Color? terminalOutput,
    Color? success,
    Color? successVariant,
    Color? error,
    Color? errorVariant,
    Color? warning,
    Color? info,
    Color? connected,
    Color? disconnected,
    Color? connecting,
    Color? hover,
    Color? splash,
    Color? highlight,
    Color? pressed,
    Color? disabled,
    Color? border,
    Color? divider,
    Color? outline,
    Color? neonPurple,
    Color? neonGreen,
    Color? neonPink,
    Color? neonBlue,
    Color? gamingHighlight,
    Color? gamingShadow,
    Color? powerGlow,
    Color? neonTrail,
    Color? energyCore,
  }) {
    return AppColor(
      primary: primary ?? this.primary,
      primarySoft: primarySoft ?? this.primarySoft,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      primaryHover: primaryHover ?? this.primaryHover,
      primarySplash: primarySplash ?? this.primarySplash,
      primaryHighlight: primaryHighlight ?? this.primaryHighlight,
      secondary: secondary ?? this.secondary,
      secondaryVariant: secondaryVariant ?? this.secondaryVariant,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      surfaceVariantSoft: surfaceVariantSoft ?? this.surfaceVariantSoft,
      terminalBackground: terminalBackground ?? this.terminalBackground,
      terminalSurface: terminalSurface ?? this.terminalSurface,
      terminalBorder: terminalBorder ?? this.terminalBorder,
      onPrimary: onPrimary ?? this.onPrimary,
      onSecondary: onSecondary ?? this.onSecondary,
      onBackground: onBackground ?? this.onBackground,
      onBackgroundSoft: onBackgroundSoft ?? this.onBackgroundSoft,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      terminalText: terminalText ?? this.terminalText,
      terminalPrompt: terminalPrompt ?? this.terminalPrompt,
      terminalCommand: terminalCommand ?? this.terminalCommand,
      terminalOutput: terminalOutput ?? this.terminalOutput,
      success: success ?? this.success,
      successVariant: successVariant ?? this.successVariant,
      error: error ?? this.error,
      errorVariant: errorVariant ?? this.errorVariant,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      connected: connected ?? this.connected,
      disconnected: disconnected ?? this.disconnected,
      connecting: connecting ?? this.connecting,
      hover: hover ?? this.hover,
      splash: splash ?? this.splash,
      highlight: highlight ?? this.highlight,
      pressed: pressed ?? this.pressed,
      disabled: disabled ?? this.disabled,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      outline: outline ?? this.outline,
      neonPurple: neonPurple ?? this.neonPurple,
      neonGreen: neonGreen ?? this.neonGreen,
      neonPink: neonPink ?? this.neonPink,
      neonBlue: neonBlue ?? this.neonBlue,
      gamingHighlight: gamingHighlight ?? this.gamingHighlight,
      gamingShadow: gamingShadow ?? this.gamingShadow,
      powerGlow: powerGlow ?? this.powerGlow,
      neonTrail: neonTrail ?? this.neonTrail,
      energyCore: energyCore ?? this.energyCore,
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
## lib/core/theme/light_theme.dart
```dart
import 'package:flutter/material.dart';

import 'foundation/app_theme.dart';
import 'resources/font.dart';
import 'resources/light_palette.dart';

class LightTheme implements AppTheme {
  static final LightTheme _instance = LightTheme._internal();

  factory LightTheme() => _instance;

  late final AppColor _color;
  late final AppFont _font;

  LightTheme._internal() {
    _color = const AppColor(
      primary: LightPalette.primary,
      primarySoft: LightPalette.primarySoft,
      primaryVariant: LightPalette.primaryVariant,
      primaryHover: LightPalette.primaryHover,
      primarySplash: LightPalette.primarySplash,
      primaryHighlight: LightPalette.primaryHighlight,
      secondary: LightPalette.secondary,
      secondaryVariant: LightPalette.secondaryVariant,
      background: LightPalette.background,
      surface: LightPalette.surface,
      surfaceVariant: LightPalette.surfaceVariant,
      surfaceVariantSoft: LightPalette.surfaceVariantSoft,
      terminalBackground: LightPalette.terminalBackground,
      terminalSurface: LightPalette.terminalSurface,
      terminalBorder: LightPalette.terminalBorder,
      onPrimary: LightPalette.onPrimary,
      onSecondary: LightPalette.onSecondary,
      onBackground: LightPalette.onBackground,
      onBackgroundSoft: LightPalette.onBackgroundSoft,
      onSurface: LightPalette.onSurface,
      onSurfaceVariant: LightPalette.onSurfaceVariant,
      terminalText: LightPalette.terminalText,
      terminalPrompt: LightPalette.terminalPrompt,
      terminalCommand: LightPalette.terminalCommand,
      terminalOutput: LightPalette.terminalOutput,
      success: LightPalette.success,
      successVariant: LightPalette.successVariant,
      error: LightPalette.error,
      errorVariant: LightPalette.errorVariant,
      warning: LightPalette.warning,
      info: LightPalette.info,
      connected: LightPalette.connected,
      disconnected: LightPalette.disconnected,
      connecting: LightPalette.connecting,
      hover: LightPalette.hover,
      splash: LightPalette.splash,
      highlight: LightPalette.highlight,
      pressed: LightPalette.pressed,
      disabled: LightPalette.disabled,
      border: LightPalette.border,
      divider: LightPalette.divider,
      outline: LightPalette.outline,
      neonPurple: LightPalette.neonPurple,
      neonGreen: LightPalette.neonGreen,
      neonPink: LightPalette.neonPink,
      neonBlue: LightPalette.neonBlue,
      gamingHighlight: LightPalette.gamingHighlight,
      gamingShadow: LightPalette.gamingShadow,
      powerGlow: LightPalette.powerGlow,
      neonTrail: LightPalette.neonTrail,
      energyCore: LightPalette.energyCore,
    );

    _font = AppFont(
      font: const Pretendard(),
      monoFont: const SpaceMono(),
      textColor: _color.onBackground,
      hintColor: _color.onSurfaceVariant,
    );
  }

  @override
  AppColor get color => _color;

  @override
  AppFont get font => _font;

  @override
  AppMode get mode => AppMode.light;

  @override
  ThemeData get themeData => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: _color.background,
      );
}

```
## lib/core/theme/provider/theme_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../const/enum_debounce_key.dart';
import '../../const/enum_hive_key.dart';
import '../../util/debounce/debounce_service.dart';
import '../dark_theme.dart';
import '../foundation/app_theme.dart';
import '../light_theme.dart';

part 'theme_provider.g.dart';

@Riverpod(dependencies: [], keepAlive: true)
class Theme extends _$Theme {
  Box<String>? _box;

  @override
  AppTheme build() {
    try {
      final box = Hive.box<String>(HiveKey.boxSettings.key);
      final savedMode = box.get(HiveKey.theme.key);

      if (savedMode != null) {
        final mode = AppMode.fromJson(savedMode);
        return mode == AppMode.light ? LightTheme() : DarkTheme();
      }
    } catch (e) {
      // 에러시 기본값
    }

    return LightTheme();
  }

  /// 테마 변경 (토글)
  /// UI는 즉시 변경되고, 저장은 debounce로 처리
  Future<void> toggleTheme() async {
    final newTheme = state.mode == AppMode.light ? DarkTheme() : LightTheme();

    // 1. UI 즉시 업데이트 (사용자 경험 우선)
    state = newTheme;

    // 2. 저장은 debounce로 처리 (성능 최적화)
    _scheduleThemeSave(newTheme.mode);
  }

  /// 특정 테마로 설정
  /// UI는 즉시 변경되고, 저장은 debounce로 처리
  Future<void> setTheme(AppMode mode) async {
    final newTheme = mode == AppMode.light ? LightTheme() : DarkTheme();

    // 1. UI 즉시 업데이트
    state = newTheme;

    // 2. 저장은 debounce로 처리
    _scheduleThemeSave(mode);
  }

  /// 저장된 테마 불러오기 (앱 시작 시 한 번만 호출)
  Future<void> loadSavedTheme() async {
    _box ??= await _openBox();
    final savedMode = _box!.get(HiveKey.theme.key);

    if (savedMode != null) {
      final mode = AppMode.fromJson(savedMode);
      final newTheme = mode == AppMode.light ? LightTheme() : DarkTheme();

      state = newTheme;
    } else {}
  }

  /// 현재 대기 중인 테마 저장 작업을 즉시 실행
  Future<bool> flushThemeSave() async {
    return await DebounceService.instance
        .executeImmediately(DebounceKey.theme.key);
  }

  /// Provider 정리 시 대기 중인 저장 작업 완료
  Future<void> dispose() async {
    await flushThemeSave();
  }

  /// 테마 저장 작업을 debounce 서비스에 스케줄링
  void _scheduleThemeSave(AppMode mode) {
    DebounceService.instance.schedule(
      key: DebounceKey.theme.key,
      operation: () => _saveThemeMode(mode),
      delay: const Duration(seconds: 5), // 테마는 좀 더 빠르게 저장
    );
  }

  /// 테마 모드 저장 (실제 저장 로직)
  Future<void> _saveThemeMode(AppMode mode) async {
    try {
      _box ??= await _openBox();
      await _box!.put(HiveKey.theme.key, mode.toJson());

      // 🔍 Hive 박스 전체 내용 확인
    } catch (e) {}
  }

  /// Hive 박스 열기
  Future<Box<String>> _openBox() async {
    if (!Hive.isBoxOpen(HiveKey.boxSettings.key)) {
      final box = await Hive.openBox<String>(HiveKey.boxSettings.key);
      return box;
    }

    final box = Hive.box<String>(HiveKey.boxSettings.key);
    return box;
  }
}

extension ThemeProviderExt on WidgetRef {
  AppTheme get theme => watch(themeProvider);
  AppColor get color => theme.color;
  AppFont get font => theme.font;
  ThemeData get themeData => theme.themeData;
}

```
## lib/core/theme/resources/dark_palette.dart
```dart
import 'package:flutter/material.dart';

abstract class DarkPalette {
// Primary colors - Neon/Gaming Theme
  static const Color primary = Color(0xFF8B5CF6); // Violet-500
  static const Color primarySoft =
      Color(0x268B5CF6); // primary.withOpacity(0.15) - 활성 탭 배경
  static const Color primaryVariant = Color(0xFF7C3AED); // Violet-600
  static const Color primaryHover =
      Color(0x1A8B5CF6); // Violet-500 with 10% opacity
  static const Color primarySplash =
      Color(0x338B5CF6); // Violet-500 with 20% opacity
  static const Color primaryHighlight =
      Color(0x1A8B5CF6); // Violet-500 with 10% opacity
  static const Color secondary = Color(0xFF10B981); // Emerald-500
  static const Color secondaryVariant = Color(0xFF059669); // Emerald-600

  // Background colors
  static const Color background = Color(0xFF111827); // Gray-900
  static const Color surface = Color(0xFF1F2937); // Gray-800
  static const Color surfaceVariant = Color(0xFF374151); // Gray-700
  static const Color surfaceVariantSoft =
      Color(0x66374151); // surfaceVariant.withOpacity(0.4) - 비활성 탭 배경

  // Terminal specific colors
  static const Color terminalBackground = Color(0xFF000000); // Pure black
  static const Color terminalSurface = Color(0xFF111827); // Gray-900
  static const Color terminalBorder = Color(0xFF374151); // Gray-700

  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFFF9FAFB); // Gray-50
  static const Color onBackgroundSoft =
      Color(0xB3F9FAFB); // onBackground.withOpacity(0.7) - 부드러운 텍스트
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
  static const Color hover = Color(0x0DFFFFFF); // White 5% opacity
  static const Color splash = Color(0x1AFFFFFF); // White 10% opacity
  static const Color highlight = Color(0x14FFFFFF); // White 8% opacity
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
  static const Color primarySoft =
      Color(0x268B5CF6); // primary.withOpacity(0.15) - 활성 탭 배경
  static const Color primaryVariant = Color(0xFF7C3AED); // Violet-600
  static const Color primaryHover =
      Color(0x1A8B5CF6); // Violet-500 with 10% opacity
  static const Color primarySplash =
      Color(0x338B5CF6); // Violet-500 with 20% opacity
  static const Color primaryHighlight =
      Color(0x1A8B5CF6); // Violet-500 with 10% opacity
  static const Color secondary = Color(0xFF10B981); // Emerald-500
  static const Color secondaryVariant = Color(0xFF059669); // Emerald-600

  // Background colors - Gaming Style Light Mode
  static const Color background = Color(0xFFF8FAFC); // 약간 보라 틴트
  static const Color surface = Color(0xFFF1F5F9); // 쿨톤 표면
  static const Color surfaceVariant = Color(0xFFE2E8F0); // 더 진한 쿨톤
  static const Color surfaceVariantSoft =
      Color(0x66E2E8F0); // surfaceVariant.withOpacity(0.4) - 비활성 탭 배경

  // Terminal specific colors
  static const Color terminalBackground = Color(0xFF1F2937); // Gray-800
  static const Color terminalSurface = Color(0xFF374151); // Gray-700
  static const Color terminalBorder = Color(0xFF6B7280); // Gray-500

  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF111827); // Gray-900
  static const Color onBackgroundSoft =
      Color(0xB3111827); // onBackground.withOpacity(0.7) - 부드러운 텍스트
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
  static const Color hover = Color(0x0D000000); // Black 5% opacity
  static const Color splash = Color(0x1A000000); // Black 10% opacity
  static const Color highlight = Color(0x14000000); // Black 8% opacity
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

```
## lib/core/ui/app_button.dart
```dart
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

```
## lib/core/ui/app_icon_button.dart
```dart
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

```
## lib/core/ui/app_icon_tab.dart
```dart
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
      backgroundColor:
          isActive ? ref.color.primarySoft : ref.color.surfaceVariantSoft,
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
            color: isActive ? ref.color.primary : ref.color.onBackgroundSoft,
          ),
        ),
      ),
    );
  }
}

```
## lib/core/ui/title_bar/app_title_bar.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../feature/terminal/provider/tab_list_provider.dart';
import '../../../feature/terminal/provider/tab_provider.dart';
import '../../util/svg/model/enum_svg_asset.dart';
import '../app_icon_button.dart';
import '../app_icon_tab.dart';
import 'provider/is_window_maximized_provider.dart';
import 'terminal_tab_widget.dart';

class AppTitleBar extends ConsumerStatefulWidget {
  const AppTitleBar({super.key});

  @override
  ConsumerState<AppTitleBar> createState() => _AppTitleBarState();
}

class _AppTitleBarState extends ConsumerState<AppTitleBar> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    // 🚀 초기 윈도우 상태 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isWindowMaximizedProvider.notifier).loadInitialState();
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // ========================================================================
  // WindowListener 메서드들 - Provider에만 상태 업데이트 (setState 없음!)
  // ========================================================================

  @override
  void onWindowMaximize() {
    ref.read(isWindowMaximizedProvider.notifier).setMaximized(true);
    // 🚀 setState() 없음 - 전체 위젯 rebuild 없음!
  }

  @override
  void onWindowUnmaximize() {
    ref.read(isWindowMaximizedProvider.notifier).setMaximized(false);
    // 🚀 setState() 없음 - 전체 위젯 rebuild 없음!
  }

  @override
  Widget build(BuildContext context) {
    final activeTabId = ref.watch(activeTabProvider);
    final tabList = ref.watch(tabListProvider);

    return Container(
      height: 50,
      color: ref.color.background,
      child: Stack(
        children: [
          // 🎯 전체 영역 드래그 가능
          const Positioned.fill(
            child: DragToMoveArea(child: SizedBox.expand()),
          ),

          // 🎯 탭바 + 컨트롤 버튼
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                // 🏠 고정 탭들 (HOME, SFTP)
                ...tabList
                    .where((tab) => !tab.isClosable)
                    .map((tab) => AppIconTab(
                          text: tab.name,
                          isActive: activeTabId == tab.id,
                          onPressed: () => ref
                              .read(activeTabProvider.notifier)
                              .setTab(tab.id),
                        )),

                // 구분선
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  width: 1,
                  height: double.infinity,
                  color: ref.color.border,
                ),

                // 🖥️ 동적 탭들 (Terminal 등) - 새로운 위젯 사용
                ...tabList
                    .where((tab) => tab.isClosable)
                    .map((tab) => TerminalTabWidget(
                          tab: tab,
                          activeTabId: activeTabId,
                        )),

                // + 버튼 (탭 추가)
                AppIconButton(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  backgroundColor: Colors.transparent,
                  hoverColor: ref.color.hover,
                  borderRadius: BorderRadius.circular(4),
                  onPressed: () {
                    ref.read(tabListProvider.notifier).addTerminalTab();
                  },
                  icon: SVGAsset.plus,
                  iconColor: ref.color.onSurfaceVariant,
                  iconSize: 14,
                ),

                // ... 버튼 (오버플로우 메뉴)
                AppIconButton(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  backgroundColor: Colors.transparent,
                  hoverColor: ref.color.hover,
                  borderRadius: BorderRadius.circular(4),
                  onPressed: () {
                    print('오버플로우 메뉴 클릭');
                  },
                  icon: SVGAsset
                      .elipsisVertical, // 임시로 minimize 아이콘 사용 (... 아이콘 없음)
                  iconColor: ref.color.onSurfaceVariant,
                  iconSize: 14,
                ),

                // 🌌 중간 빈 공간
                const Spacer(),

                // 🎯 제어 버튼 영역
                Row(
                  children: [
                    AppIconButton(
                      width: 30,
                      height: 30,

                      /// icon
                      icon: SVGAsset.windowMinimize,
                      iconColor: ref.color.onSurfaceVariant,
                      iconSize: 2,
                      onPressed: () => windowManager.minimize(),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final isMaximized =
                            ref.watch(isWindowMaximizedProvider);
                        return AppIconButton(
                          width: 30,
                          height: 30,
                          margin: const EdgeInsets.symmetric(horizontal: 5),

                          /// icon
                          icon: isMaximized
                              ? SVGAsset.windowRestore
                              : SVGAsset.windowMaximize,
                          iconColor: ref.color.onSurfaceVariant,
                          iconSize: 14,
                          onPressed: () {
                            ref
                                .read(isWindowMaximizedProvider.notifier)
                                .toggleMaximize();
                          },
                        );
                      },
                    ),
                    AppIconButton(
                      width: 30,
                      height: 30,

                      /// icon
                      icon: SVGAsset.windowClose,
                      iconColor: ref.color.onSurfaceVariant,
                      iconSize: 14,
                      onPressed: () => windowManager.close(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

```
## lib/core/ui/title_bar/provider/is_window_maximized_provider.dart
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';

part 'is_window_maximized_provider.g.dart';

@riverpod
class IsWindowMaximized extends _$IsWindowMaximized {
  @override
  bool build() {
    return false; // 초기값: 비최대화
  }

  /// 윈도우 최대화 상태 업데이트
  void setMaximized(bool isMaximized) {
    state = isMaximized;
  }

  /// 윈도우 최대화 토글
  Future<void> toggleMaximize() async {
    if (state) {
      await windowManager.unmaximize();
      // onWindowUnmaximize()에서 setMaximized(false) 호출됨
    } else {
      await windowManager.maximize();
      // onWindowMaximize()에서 setMaximized(true) 호출됨
    }
  }

  /// 초기 윈도우 상태 로드
  Future<void> loadInitialState() async {
    try {
      final isMaximized = await windowManager.isMaximized();
      state = isMaximized;
    } catch (e) {
      // 에러 시 기본값 유지
      print('윈도우 최대화 상태 로드 실패: $e');
    }
  }
}

```
## lib/core/ui/title_bar/terminal_tab_widget.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

import '../../../feature/terminal/model/tab_info.dart';
import '../../../feature/terminal/provider/tab_list_provider.dart';
import '../../../feature/terminal/provider/tab_provider.dart';
import '../../util/svg/model/enum_svg_asset.dart';
import '../app_icon_button.dart';

class TerminalTabWidget extends ConsumerStatefulWidget {
  final TabInfo tab;
  final String activeTabId;

  const TerminalTabWidget({
    super.key,
    required this.tab,
    required this.activeTabId,
  });

  @override
  ConsumerState<TerminalTabWidget> createState() => _TerminalTabWidgetState();
}

class _TerminalTabWidgetState extends ConsumerState<TerminalTabWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.activeTabId == widget.tab.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () =>
              ref.read(activeTabProvider.notifier).setTab(widget.tab.id),
          child: Container(
            decoration: BoxDecoration(
              color: isActive
                  ? ref.color.primarySoft
                  : ref.color.surfaceVariantSoft,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              border: isActive
                  ? Border(
                      bottom: BorderSide(
                        color: ref.color.primary,
                        width: 2,
                      ),
                    )
                  : null,
            ),
            child: Stack(
              children: [
                // 기본 탭 내용 (패딩 적용)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 탭 아이콘 (터미널)
                      Icon(
                        Icons.terminal,
                        size: 14,
                        color: isActive
                            ? ref.color.primary
                            : ref.color.onBackgroundSoft,
                      ),
                      const SizedBox(width: 6),
                      // 탭 이름
                      Text(
                        widget.tab.name,
                        style: ref.font.semiBoldText12.copyWith(
                          color: isActive
                              ? ref.color.primary
                              : ref.color.onBackgroundSoft,
                        ),
                      ),
                      const SizedBox(width: 16), // X 버튼 공간 확보
                    ],
                  ),
                ),
                // 닫기 버튼 - hover 시에만 표시, 우상단에 positioned
                if (_isHovered)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 2,
                    child: Center(
                      child: AppIconButton(
                        width: 16,
                        height: 16,
                        backgroundColor: isActive
                            ? ref.color.primarySoft
                            : ref.color.surfaceVariantSoft,
                        hoverColor: ref.color.hover,
                        borderRadius: BorderRadius.circular(4),
                        onPressed: () => ref
                            .read(tabListProvider.notifier)
                            .removeTab(widget.tab.id),
                        icon: SVGAsset.windowClose,
                        iconColor: isActive
                            ? ref.color.primary
                            : ref.color.onSurfaceVariant,
                        iconSize: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

```
## lib/core/util/debounce/debounce_operation.dart
```dart
import 'dart:async';

/// Debounce 작업을 나타내는 클래스
class DebounceOperation {
  final String key;
  final Future<void> Function() operation;
  Timer? _timer;
  final Duration delay;

  DebounceOperation({
    required this.key,
    required this.operation,
    this.delay = const Duration(milliseconds: 500),
  });

  /// 타이머를 시작하거나 재시작
  void schedule() {
    _timer?.cancel(); // 기존 타이머가 있으면 취소
    _timer = Timer(delay, () async {
      try {
        await operation();
      } catch (e) {
        // 에러 로깅 (나중에 로깅 서비스로 교체 가능)
        print('Debounce operation failed for key "$key": $e');
      }
    });
  }

  /// 즉시 실행 (debounce 무시하고 바로 실행)
  Future<void> executeImmediately() async {
    _timer?.cancel();
    try {
      await operation();
    } catch (e) {
      print('Immediate execution failed for key "$key": $e');
      rethrow;
    }
  }

  /// 타이머 취소
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// 현재 대기 중인지 확인
  bool get isPending => _timer?.isActive ?? false;

  /// 리소스 정리
  void dispose() {
    cancel();
  }
}

```
## lib/core/util/debounce/debounce_service.dart
```dart
import 'dart:async';

import 'debounce_operation.dart';

class DebounceService {
  // 싱글톤 인스턴스
  static final DebounceService _instance = DebounceService._internal();
  static DebounceService get instance => _instance;

  DebounceService._internal();

  // 키별 debounce 작업 관리
  final Map<String, DebounceOperation> _operations = {};

  /// 기본 debounce 지연 시간
  static const Duration _defaultDelay = Duration(milliseconds: 500);

  /// Debounce 작업 등록/스케줄링
  ///
  /// [key] - 작업을 구분하는 고유 키 (예: 'theme_mode', 'locale')
  /// [operation] - 실행할 비동기 작업
  /// [delay] - debounce 지연 시간 (기본: 500ms)
  void schedule({
    required String key,
    required Future<void> Function() operation,
    Duration? delay,
  }) {
    // 기존 작업이 있으면 제거
    _operations[key]?.dispose();

    // 새로운 debounce 작업 등록
    _operations[key] = DebounceOperation(
      key: key,
      operation: operation,
      delay: delay ?? _defaultDelay,
    );

    // 타이머 시작
    _operations[key]!.schedule();
  }

  /// 특정 키의 작업을 즉시 실행
  ///
  /// [key] - 즉시 실행할 작업의 키
  /// 반환값: 성공하면 true, 해당 키의 작업이 없으면 false
  Future<bool> executeImmediately(String key) async {
    final operation = _operations[key];
    if (operation == null) {
      return false;
    }

    try {
      await operation.executeImmediately();
      _operations.remove(key); // 실행 완료 후 제거
      return true;
    } catch (e) {
      // 에러가 발생해도 작업은 제거 (재시도는 상위에서 결정)
      _operations.remove(key);
      rethrow;
    }
  }

  /// 모든 대기 중인 작업을 즉시 실행
  ///
  /// 앱 종료 시나 강제 저장이 필요할 때 사용
  /// 모든 작업이 완료될 때까지 대기
  Future<void> flushAll() async {
    if (_operations.isEmpty) {
      return;
    }

    // 현재 등록된 모든 작업의 키 복사 (실행 중 맵이 변경될 수 있음)
    final keysToFlush = _operations.keys.toList();

    // 모든 작업을 병렬로 실행
    final futures = <Future<void>>[];

    for (final key in keysToFlush) {
      final operation = _operations[key];
      if (operation != null) {
        futures.add(operation.executeImmediately().catchError((error) {
          print('Error flushing operation "$key": $error');
          // 개별 작업 실패가 전체 flush를 중단하지 않도록 함
        }));
      }
    }

    // 모든 작업 완료 대기
    await Future.wait(futures);

    // 실행 완료된 작업들 정리
    for (final key in keysToFlush) {
      _operations.remove(key);
    }
  }

  /// 특정 키의 작업 취소
  ///
  /// [key] - 취소할 작업의 키
  /// 반환값: 취소된 작업이 있으면 true, 없으면 false
  bool cancel(String key) {
    final operation = _operations.remove(key);
    if (operation != null) {
      operation.dispose();
      return true;
    }
    return false;
  }

  /// 모든 작업 취소 (저장하지 않고 단순 취소)
  void cancelAll() {
    for (final operation in _operations.values) {
      operation.dispose();
    }
    _operations.clear();
  }

  /// 현재 대기 중인 작업 수
  int get pendingCount => _operations.length;

  /// 특정 키의 작업이 대기 중인지 확인
  bool isPending(String key) {
    return _operations[key]?.isPending ?? false;
  }

  /// 현재 대기 중인 모든 키 목록
  List<String> get pendingKeys => _operations.keys.toList();

  /// 리소스 정리 (앱 종료 시 호출)
  void dispose() {
    cancelAll();
  }
}

```
## lib/core/util/svg/enum/color_target.dart
```dart
enum ColorTarget {
  auto, // 기존 스타일에 따라 자동 결정
  fill, // fill만 적용
  stroke, // stroke만 적용
  both, // fill과 stroke 둘 다 적용
}

```
## lib/core/util/svg/model/enum_svg_asset.dart
```dart
enum SVGAsset {
  theme("assets/icons/ico_theme.svg"),
  language("assets/icons/ico_language.svg"),
  plus("assets/icons/ico_plus.svg"),
  elipsisVertical("assets/icons/ico_elipsis_vertical.svg"),

  /// title bar
  windowClose('assets/icons/titlebar/ico_window_close.svg'),
  windowMinimize('assets/icons/titlebar/ico_window_minimize.svg'),
  windowMaximize('assets/icons/titlebar/ico_window_maximize.svg'),
  windowRestore('assets/icons/titlebar/ico_window_restore.svg'),
  ;

  final String path;

  const SVGAsset(this.path);
}

```
## lib/core/util/svg/svg_util.dart
```dart
import 'package:flutter/services.dart';

import 'enum/color_target.dart';
import 'model/enum_svg_asset.dart';

class SVGUtil {
  static final SVGUtil _instance = SVGUtil._internal();

  factory SVGUtil() => _instance;

  SVGUtil._internal();

  static final RegExp _svgNPathRegex = RegExp(r'<(svg|path)(\s+[^>]*?)?/?>');
  static final RegExp _widthRegex = RegExp(r'\swidth="[^"]*"');
  static final RegExp _heightRegex = RegExp(r'\sheight="[^"]*"');

  static final RegExp _fillRegex = RegExp(r'fill="(?!none")[^"]*"');
  static final RegExp _strokeRegex = RegExp(r'stroke="[^"]*"');

  static final RegExp _fillCustomRegex =
      RegExp(r'fill="(?!(none|white))"[^"]*"');
  static final RegExp _strokeCustomRegex =
      RegExp(r'stroke="(?!(none|white))"[^"]*"');

  final Map<SVGAsset, Map<String, String>> _processedSVGCache = {};

  Future<String> getSVG({
    required SVGAsset asset,
    Color? svgColor,
    double? svgSize,
    bool isCustom = false,
    ColorTarget colorTarget = ColorTarget.auto,
  }) async {
    try {
      // 1. 캐시 키 생성
      final cacheKey =
          _generateCacheKey(color: svgColor, size: svgSize, isCustom: isCustom);

      // 2. 캐시된 결과 확인
      if (_processedSVGCache[asset]?[cacheKey] != null) {
        return _processedSVGCache[asset]![cacheKey]!;
      }

      // 3. 원본 SVG 로드
      String svgString = await rootBundle.loadString(asset.path);

      // 4. 크기 적용
      if (svgSize != null) {
        svgString = _applySize(svgString);
      }

      // 5. 색상 적용
      if (svgColor != null) {
        svgString = _applyColor(
          svgString: svgString,
          color: svgColor,
          isCustom: isCustom,
          target: colorTarget,
        );
      }

      // 6. 결과 캐싱
      _processedSVGCache[asset] ??= {};
      _processedSVGCache[asset]![cacheKey] = svgString;

      return svgString;
    } catch (error, stackTrace) {
      return "";
    }
  }

  /// SVG에서 width, height 속성을 제거합니다
  String _applySize(String svgString) {
    return svgString.replaceAll(_widthRegex, '').replaceAll(_heightRegex, '');
  }

  /// SVG에 색상을 적용합니다
  String _applyColor({
    required String svgString,
    required Color color,
    bool isCustom = false,
    ColorTarget target = ColorTarget.auto,
  }) {
    final colorHex = _colorToHex(color);

    return svgString.replaceAllMapped(
      _svgNPathRegex,
      (match) {
        String tag = match.group(0)!;

        switch (target) {
          case ColorTarget.fill:
            tag = _applyFillOnly(tag, colorHex, isCustom);
            break;

          case ColorTarget.stroke:
            tag = _applyStrokeOnly(tag, colorHex, isCustom);
            break;

          case ColorTarget.both:
            tag = _applyBoth(tag, colorHex, isCustom);
            break;

          case ColorTarget.auto:
            tag = _applyAuto(tag, colorHex, isCustom);
            break;
        }

        return tag;
      },
    );
  }

// 각각의 적용 메서드들
  String _applyAuto(String tag, String colorHex, bool isCustom) {
    bool hasFill =
        isCustom ? _fillCustomRegex.hasMatch(tag) : _fillRegex.hasMatch(tag);
    bool hasStroke = isCustom
        ? _strokeCustomRegex.hasMatch(tag)
        : _strokeRegex.hasMatch(tag);

    if (hasFill) {
      // 기존 fill이 있으면 fill 변경
      return _applyFillOnly(tag, colorHex, isCustom);
    } else if (hasStroke) {
      // fill이 없고 stroke가 있으면 stroke 변경
      return _applyStrokeOnly(tag, colorHex, isCustom);
    } else {
      // 둘 다 없으면 fill 추가 (기본값)
      return _applyFillOnly(tag, colorHex, isCustom);
    }
  }

  String _applyFillOnly(String tag, String colorHex, bool isCustom) {
    if (isCustom) {
      if (_fillCustomRegex.hasMatch(tag)) {
        return tag.replaceAllMapped(
            _fillCustomRegex, (match) => 'fill="$colorHex"');
      } else if (!tag.contains('fill=')) {
        return _addAttribute(tag, 'fill', colorHex);
      }
    } else {
      if (_fillRegex.hasMatch(tag)) {
        return tag.replaceAllMapped(_fillRegex, (match) => 'fill="$colorHex"');
      } else if (!tag.contains('fill=')) {
        return _addAttribute(tag, 'fill', colorHex);
      }
    }
    return tag;
  }

  String _applyStrokeOnly(String tag, String colorHex, bool isCustom) {
    if (isCustom) {
      if (_strokeCustomRegex.hasMatch(tag)) {
        return tag.replaceAllMapped(
            _strokeCustomRegex, (match) => 'stroke="$colorHex"');
      } else if (!tag.contains('stroke=')) {
        return _addAttribute(tag, 'stroke', colorHex);
      }
    } else {
      if (_strokeRegex.hasMatch(tag)) {
        return tag.replaceAllMapped(
            _strokeRegex, (match) => 'stroke="$colorHex"');
      } else if (!tag.contains('stroke=')) {
        return _addAttribute(tag, 'stroke', colorHex);
      }
    }
    return tag;
  }

  String _applyBoth(String tag, String colorHex, bool isCustom) {
    // fill 먼저 적용
    tag = _applyFillOnly(tag, colorHex, isCustom);
    // stroke 적용
    tag = _applyStrokeOnly(tag, colorHex, isCustom);
    return tag;
  }

  /// 태그에 속성을 추가하는 헬퍼 메서드
  String _addAttribute(String tag, String attribute, String value) {
    if (tag.endsWith('/>')) {
      return tag.replaceFirst('/>', ' $attribute="$value"/>');
    } else if (tag.endsWith('>')) {
      return tag.replaceFirst('>', ' $attribute="$value">');
    }
    return tag;
  }

  /// Color 객체를 Hex 문자열로 변환합니다
  String _colorToHex(Color color) {
    final int r = (color.r * 255).toInt();
    final int g = (color.g * 255).toInt();
    final int b = (color.b * 255).toInt();
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// 캐시 키를 생성합니다
  String _generateCacheKey({
    Color? color,
    double? size,
    bool isCustom = false,
  }) {
    String colorPart = 'null';
    if (color != null) {
      colorPart = '${color.a}_${color.r}_${color.g}_${color.b}';
    }

    final sizePart = size?.toString() ?? 'null';
    final customPart = isCustom.toString();

    return '$colorPart..$sizePart..$customPart';
  }

  void clearCache() {
    _processedSVGCache.clear();
  }
}

```
## lib/core/util/svg/widget/svg_icon.dart
```dart
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/enum_svg_asset.dart';
import '../svg_util.dart';

class SVGIcon extends StatelessWidget {
  final SVGAsset asset;
  final Color? color;
  final double? size;
  final bool isCustom;

  const SVGIcon({
    super.key,
    required this.asset,
    this.color,
    this.size,
    this.isCustom = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SVGUtil().getSVG(
          asset: asset, svgColor: color, svgSize: size, isCustom: isCustom),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return SvgPicture.string(
          snapshot.data!,
          width: size,
          height: size,
        );
      },
    );
  }
}

```
## lib/feature/terminal/model/enum_tab_type.dart
```dart
enum TabType {
  home('home'),
  sftp('sftp'),
  terminal('terminal');

  const TabType(this.value);

  final String value;

  /// 탭 이름 (다국어 지원 시 여기서 처리)
  String get displayName {
    switch (this) {
      case TabType.home:
        return 'HOME';
      case TabType.sftp:
        return 'SFTP';
      case TabType.terminal:
        return 'Terminal';
    }
  }

  /// 탭 아이콘 (추후 SVG 아이콘 추가 시 사용)
  String get iconName {
    switch (this) {
      case TabType.home:
        return 'home';
      case TabType.sftp:
        return 'folder';
      case TabType.terminal:
        return 'terminal';
    }
  }

  /// JSON 직렬화
  String toJson() => value;

  /// JSON 역직렬화
  static TabType fromJson(String json) {
    return TabType.values.firstWhere(
      (type) => type.value == json,
      orElse: () => TabType.home,
    );
  }
}

```
## lib/feature/terminal/model/tab_info.dart
```dart
import 'enum_tab_type.dart';

/// 개별 탭 정보를 담는 클래스
class TabInfo {
  final String id;
  final TabType type;
  final String name;
  final bool isClosable;

  const TabInfo({
    required this.id,
    required this.type,
    required this.name,
    this.isClosable = true,
  });

  TabInfo copyWith({
    String? id,
    TabType? type,
    String? name,
    bool? isClosable,
  }) {
    return TabInfo(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      isClosable: isClosable ?? this.isClosable,
    );
  }
}

```
## lib/feature/terminal/provider/active_tabinfo_provider.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/tab_info.dart';
import 'tab_list_provider.dart';
import 'tab_provider.dart';

part 'active_tabinfo_provider.g.dart';

@riverpod
TabInfo? activeTabInfo(Ref ref) {
  final activeTabId = ref.watch(activeTabProvider);
  final tabList = ref.watch(tabListProvider);

  try {
    return tabList.firstWhere((tab) => tab.id == activeTabId);
  } catch (e) {
    return null;
  }
}

```
## lib/feature/terminal/provider/tab_list_provider.dart
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/enum_tab_type.dart';
import '../model/tab_info.dart';
import 'tab_provider.dart';

part 'tab_list_provider.g.dart';

@Riverpod(dependencies: [ActiveTab])
class TabList extends _$TabList {
  @override
  List<TabInfo> build() {
    return [
      TabInfo(
        id: TabType.home.value,
        type: TabType.home,
        name: TabType.home.displayName,
        isClosable: false,
      ),
      TabInfo(
        id: TabType.sftp.value,
        type: TabType.sftp,
        name: TabType.sftp.displayName,
        isClosable: false,
      ),
    ];
  }

  /// 새 터미널 탭 추가
  void addTerminalTab() {
    final currentTabs = state;
    final terminalCount =
        currentTabs.where((tab) => tab.type == TabType.terminal).length;

    final newTabId = 'terminal_${DateTime.now().millisecondsSinceEpoch}';
    final newTab = TabInfo(
      id: newTabId,
      type: TabType.terminal,
      name: 'Terminal ${terminalCount + 1}',
      isClosable: true,
    );

    state = [...currentTabs, newTab];

    // 새로 추가된 탭으로 이동
    ref.read(activeTabProvider.notifier).setTab(newTabId);
  }

  /// 탭 제거
  void removeTab(String tabId) {
    final currentTabs = state;
    final tabToRemove = currentTabs.firstWhere((tab) => tab.id == tabId);

    // 고정 탭은 제거할 수 없음
    if (!tabToRemove.isClosable) return;

    final newTabs = currentTabs.where((tab) => tab.id != tabId).toList();
    state = newTabs;

    // 제거된 탭이 현재 활성 탭이었다면 Home으로 이동
    final activeTabId = ref.read(activeTabProvider);
    if (activeTabId == tabId) {
      ref.read(activeTabProvider.notifier).goToHome();
    }
  }

  /// 탭 이름 변경
  void renameTab(String tabId, String newName) {
    state = state.map((tab) {
      if (tab.id == tabId) {
        return tab.copyWith(name: newName);
      }
      return tab;
    }).toList();
  }
}

```
## lib/feature/terminal/provider/tab_provider.dart
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/enum_tab_type.dart';

part 'tab_provider.g.dart';

@riverpod
class ActiveTab extends _$ActiveTab {
  @override
  String build() {
    return TabType.home.value; // 기본값: Home 탭
  }

  /// 특정 탭으로 전환
  void setTab(String tabId) {
    state = tabId;
  }

  /// Home 탭으로 전환
  void goToHome() {
    state = TabType.home.value;
  }

  /// SFTP 탭으로 전환
  void goToSftp() {
    state = TabType.sftp.value;
  }
}

```
## lib/main.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:penterm/page/main_page.dart';
import 'package:window_manager/window_manager.dart';

import 'core/const/enum_hive_key.dart';
import 'core/localization/generated/l10n.dart';
import 'core/localization/provider/locale_state_provider.dart';
import 'core/theme/provider/theme_provider.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  /// Hive 초기화
  await Hive.initFlutter();
  await Hive.openBox<String>(HiveKey.boxSettings.key);

  // 윈도우 매니저 설정
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden, // 타이틀바 숨기기
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // 앱 실행
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeStateProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Riverpod Init Project',
      theme: theme.themeData,
      locale: locale,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('ko'), // Korean
      ],
      home: const MainScreen(),
    );
  }
}

```
## lib/page/example_heme.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/provider/language_provider.dart';
import '../core/localization/provider/locale_state_provider.dart';
import '../core/theme/provider/theme_provider.dart';
import '../core/ui/title_bar/app_title_bar.dart';
import '../core/util/svg/model/enum_svg_asset.dart';
import '../core/util/svg/widget/svg_icon.dart';

class MyHome extends ConsumerWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeStateProvider);

    return Scaffold(
      body: Column(
        children: [
          // 커스텀 타이틀바
          const AppTitleBar(),

          // 메인 콘텐츠
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 타이틀
                  Text(
                    language.appTitle,
                    style: ref.font.boldText24.copyWith(
                      color: ref.color.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 환영 메시지
                  Text(
                    language.welcomeMessage,
                    style: ref.font.regularText18,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // 설명
                  Text(
                    language.description,
                    style: ref.font.regularText14.copyWith(
                      color: ref.color.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // 설정 카드
                  Container(
                    width: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: ref.color.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ref.color.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 테마 설정
                        _buildSettingRow(
                          ref,
                          title: language.themeMode,
                          subtitle: theme.mode.name == 'light'
                              ? language.lightTheme
                              : language.darkTheme,
                          onTap: () {
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                          icon: SVGIcon(
                            asset: SVGAsset.theme,
                            color: ref.color.onBackground,
                            size: 24,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // 언어 설정
                        _buildSettingRow(
                          ref,
                          title: language.language,
                          subtitle: locale.languageCode == 'ko'
                              ? language.korean
                              : language.english,
                          onTap: () {
                            ref
                                .read(localeStateProvider.notifier)
                                .toggleLocale();
                          },
                          icon: SVGIcon(
                            asset: SVGAsset.language,
                            color: ref.color.onBackground,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 현재 상태 표시
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ref.color.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Current: ${theme.mode.name} theme, ${locale.languageCode} locale',
                      style: ref.font.monoRegularText12.copyWith(
                        color: ref.color.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(
    WidgetRef ref, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Widget icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ref.font.mediumText16,
                  ),
                  Text(
                    subtitle,
                    style: ref.font.regularText14.copyWith(
                      color: ref.color.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: ref.color.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

```
## lib/page/main_page.dart
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

import '../core/ui/title_bar/app_title_bar.dart';
import '../feature/terminal/model/enum_tab_type.dart';
import '../feature/terminal/model/tab_info.dart';
import '../feature/terminal/provider/active_tabinfo_provider.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTabInfo = ref.watch(activeTabInfoProvider);

    return Scaffold(
      body: Column(
        children: [
          // 커스텀 타이틀바
          const AppTitleBar(),

          // 메인 콘텐츠 - AnimatedSwitcher로 교체
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: activeTabInfo != null
                  ? _buildTabContent(activeTabInfo, ref)
                  : _buildDefaultContent(ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(TabInfo tabInfo, WidgetRef ref) {
    switch (tabInfo.type) {
      case TabType.home:
        return Container(
          key: const ValueKey('home'),
          width: double.infinity,
          color: Colors.red,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.home,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'HOME TAB',
                  style: ref.font.boldText24.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );

      case TabType.sftp:
        return Container(
          key: const ValueKey('sftp'),
          width: double.infinity,
          color: Colors.blue,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.folder,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'SFTP TAB',
                  style: ref.font.boldText24.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );

      case TabType.terminal:
        return Container(
          key: ValueKey(tabInfo.id),
          width: double.infinity,
          color: Colors.green,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.terminal,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  tabInfo.name,
                  style: ref.font.boldText24.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tab ID: ${tabInfo.id}',
                  style: ref.font.regularText14.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildDefaultContent(WidgetRef ref) {
    return Container(
      key: const ValueKey('default'),
      width: double.infinity,
      color: Colors.grey,
      child: Center(
        child: Text(
          'No Active Tab',
          style: ref.font.boldText24.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

```
