import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../feature/terminal/model/enum_tab_type.dart';
import '../../../feature/terminal/provider/tab_provider.dart';
import '../../util/svg/model/enum_svg_asset.dart';
import '../app_icon_button.dart';
import '../app_icon_tab.dart';
import 'provider/is_window_maximized_provider.dart';

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
    final activeTab = ref.watch(activeTabProvider);

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
          Row(
            children: [
              // 🏠 HOME 탭
              AppIconTab(
                text: TabType.home.displayName,
                isActive: activeTab == TabType.home,
                onPressed: () =>
                    ref.read(activeTabProvider.notifier).goToHome(),
              ),

              const SizedBox(width: 4),

              // 📁 SFTP 탭
              AppIconTab(
                text: TabType.sftp.displayName,
                isActive: activeTab == TabType.sftp,
                onPressed: () =>
                    ref.read(activeTabProvider.notifier).goToSftp(),
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
                    iconColor: ref.color.onBackground,
                    iconSize: 2,
                    onPressed: () => windowManager.minimize(),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final isMaximized = ref.watch(isWindowMaximizedProvider);
                      return AppIconButton(
                        width: 30,
                        height: 30,
                        margin: const EdgeInsets.symmetric(horizontal: 5),

                        /// icon
                        icon: isMaximized
                            ? SVGAsset.windowRestore
                            : SVGAsset.windowMaximize,
                        iconColor: ref.color.onBackground,
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
                    iconColor: ref.color.onBackground,
                    iconSize: 14,
                    onPressed: () => windowManager.close(),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
