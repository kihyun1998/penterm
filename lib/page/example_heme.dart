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
