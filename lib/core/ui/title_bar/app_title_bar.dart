import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../feature/terminal/model/tab_info.dart';
import '../../../feature/terminal/provider/tab_list_provider.dart';
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

                // 🖥️ 동적 탭들 (Terminal 등)
                ...tabList
                    .where((tab) => tab.isClosable)
                    .map((tab) => _buildDynamicTab(tab, activeTabId)),

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

  /// 동적 탭 빌드 (닫기 버튼 포함)
  Widget _buildDynamicTab(TabInfo tab, String activeTabId) {
    final isActive = activeTabId == tab.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 탭 본체
          GestureDetector(
            onTap: () => ref.read(activeTabProvider.notifier).setTab(tab.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    tab.name,
                    style: ref.font.semiBoldText12.copyWith(
                      color: isActive
                          ? ref.color.primary
                          : ref.color.onBackgroundSoft,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // 닫기 버튼
                  GestureDetector(
                    onTap: () =>
                        ref.read(tabListProvider.notifier).removeTab(tab.id),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.transparent,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 12,
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
}
