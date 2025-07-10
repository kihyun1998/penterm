import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../feature/terminal/model/tab_info.dart';
import '../../../feature/terminal/provider/tab_drag_provider.dart';
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
  // 각 터미널 탭의 GlobalKey를 저장하는 맵
  final Map<String, GlobalKey> _tabKeys = {};

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

  /// 터미널 탭의 GlobalKey를 가져오거나 생성
  GlobalKey _getTabKey(String tabId) {
    if (!_tabKeys.containsKey(tabId)) {
      _tabKeys[tabId] = GlobalKey();
    }
    return _tabKeys[tabId]!;
  }

  /// 사용하지 않는 TabKey 정리
  void _cleanupTabKeys(List<TabInfo> currentTabs) {
    final currentTabIds = currentTabs.map((tab) => tab.id).toSet();
    _tabKeys.removeWhere((key, value) => !currentTabIds.contains(key));
  }

  @override
  Widget build(BuildContext context) {
    final activeTabId = ref.watch(activeTabProvider);
    final tabList = ref.watch(tabListProvider);
    final dragState = ref.watch(tabDragProvider);
    final fixedTabs = tabList.where((tab) => !tab.isClosable).toList();
    final draggableTabs = tabList.where((tab) => tab.isClosable).toList();

    // 사용하지 않는 TabKey 정리
    _cleanupTabKeys(tabList);

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
                ...fixedTabs.map((tab) => AppIconTab(
                      text: tab.name,
                      isActive: activeTabId == tab.id,
                      onPressed: () =>
                          ref.read(activeTabProvider.notifier).setTab(tab.id),
                    )),

                // 구분선
                if (draggableTabs.isNotEmpty)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    width: 1,
                    height: double.infinity,
                    color: ref.color.border,
                  ),

                // 🖥️ 드래그 가능한 터미널 탭들
                ...draggableTabs.map((tab) => DragTarget<TabInfo>(
                      onWillAcceptWithDetails: (data) {
                        // 드래그 중인 데이터가 유효한지 확인
                        return data.data.id != tab.id;
                      },
                      onAcceptWithDetails: (draggedTab) {
                        // 드롭된 탭의 새로운 위치 계산
                        final targetIndex = tabList.indexOf(tab);
                        ref
                            .read(tabDragProvider.notifier)
                            .updateTargetIndex(targetIndex);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return TerminalTabWidget(
                          tab: tab,
                          activeTabId: activeTabId,
                          tabKey: _getTabKey(tab.id),
                        );
                      },
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
                  icon: SVGAsset.elipsisVertical,
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

          // 🎯 드래그 상태 디버그 정보 (개발 중에만)
          if (dragState.isDragging)
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                color: Colors.black54,
                child: Text(
                  'Dragging: ${dragState.draggingTabId}, Target: ${dragState.targetIndex}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
