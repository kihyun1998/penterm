import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../../feature/terminal/model/terminal_drag_data.dart';
import '../../../feature/terminal/provider/split_layout_provider.dart';
import '../../../feature/terminal/provider/tab_list_provider.dart';
import '../../../feature/terminal/provider/tab_provider.dart';
import '../../../feature/terminal/provider/terminal_drag_provider.dart';
import '../../util/svg/model/enum_svg_asset.dart';
import '../app_icon_button.dart';
import '../app_icon_tab.dart';
import 'provider/is_window_maximized_provider.dart';
import 'tab_drop_zone.dart';
import 'terminal_tab_widget.dart';

class AppTitleBar extends ConsumerStatefulWidget {
  const AppTitleBar({super.key});

  @override
  ConsumerState<AppTitleBar> createState() => _AppTitleBarState();
}

class _AppTitleBarState extends ConsumerState<AppTitleBar> with WindowListener {
  bool _isPanelHovering = false; // 🚀 패널 드롭 hover 상태

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
  }

  @override
  void onWindowUnmaximize() {
    ref.read(isWindowMaximizedProvider.notifier).setMaximized(false);
  }

  @override
  Widget build(BuildContext context) {
    final activeTabId = ref.watch(activeTabProvider);
    final tabList = ref.watch(tabListProvider);
    final dragState = ref.watch(terminalDragProvider);

    // 🚀 정렬 불필요! List 자체가 이미 순서대로 정렬됨
    final fixedTabs = tabList.where((tab) => !tab.isClosable).toList();
    final draggableTabs = tabList.where((tab) => tab.isClosable).toList();

    // 🚀 패널 드래그 중인지 확인
    final isPanelDragging =
        dragState.isDragging && dragState.draggingData?.isFromPanel == true;

    return Container(
      height: 50,
      color: ref.color.background,
      child: Stack(
        children: [
          // 🎯 전체 영역 드래그 가능
          const Positioned.fill(
            child: DragToMoveArea(child: SizedBox.expand()),
          ),

          // 🚀 패널 드롭 영역 (패널 드래그 중일 때만 표시)
          if (isPanelDragging)
            Positioned.fill(
              child: _buildPanelDropZone(),
            ),

          // 🎯 탭바 + 컨트롤 버튼
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                // 🏠 고정 탭들 (HOME, SFTP) - 순서 보장됨
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

                // 🖥️ 터미널 탭들 + 드롭 영역들 - 순서 보장됨
                if (draggableTabs.isNotEmpty)
                  Stack(
                    children: [
                      // 하위 레이어: 일반 탭들
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: draggableTabs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tab = entry.value;
                          return TerminalTabWidget(
                            tab: tab,
                            activeTabId: activeTabId,
                          );
                        }).toList(),
                      ),

                      // 상위 레이어: 드롭 영역들 (탭 드래그 중일 때만 활성화)
                      if (dragState.isDragging &&
                          dragState.draggingData?.isFromTab == true)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: draggableTabs.asMap().entries.map((entry) {
                            final index = entry.key;
                            final tab = entry.value;
                            return TabDropZone(
                              targetIndex: index,
                              targetTabName: tab.name,
                            );
                          }).toList(),
                        ),
                    ],
                  ),

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

          // 🚀 패널 드롭 피드백 오버레이 (hover 시에만 표시)
          if (isPanelDragging && _isPanelHovering)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: ref.color.primary.withOpacity(0.1),
                    border: Border.all(
                      color: ref.color.primary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: ref.color.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: ref.color.primary,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ref.color.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.tab,
                            size: 20,
                            color: ref.color.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Drop here to create new tab',
                            style: ref.font.semiBoldText14.copyWith(
                              color: ref.color.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 🚀 패널 드롭 영역 구현
  Widget _buildPanelDropZone() {
    return DragTarget<TerminalDragData>(
      onWillAcceptWithDetails: (data) {
        // 패널에서 드래그된 데이터만 허용
        final isFromPanel = data.data.isFromPanel;
        print('🔍 titlebar will accept? FromPanel: $isFromPanel');
        return isFromPanel;
      },
      onMove: (details) {
        // 패널 드래그가 titlebar 위에 있을 때
        if (!_isPanelHovering) {
          setState(() => _isPanelHovering = true);
          print('🎯 Panel hovering over titlebar');
        }
      },
      onLeave: (data) {
        // 패널 드래그가 titlebar를 벗어날 때
        if (_isPanelHovering) {
          setState(() => _isPanelHovering = false);
          print('↩️ Panel left titlebar');
        }
      },
      onAcceptWithDetails: (draggedData) {
        print('🎯 Panel dropped on titlebar: ${draggedData.data.debugInfo}');

        // 🚀 핵심: unsplitToNewTab 호출!
        ref.read(splitLayoutProvider.notifier).unsplitToNewTab(
              draggedData.data.terminalId,
            );

        // 드래그 상태 종료
        ref.read(terminalDragProvider.notifier).endDrag();

        // hover 상태 해제
        setState(() => _isPanelHovering = false);

        print('✅ Panel unsplit to new tab completed');
      },
      builder: (context, candidateData, rejectedData) {
        // 투명한 드롭 영역 (시각적 피드백은 오버레이에서 처리)
        return const SizedBox.expand();
      },
    );
  }
}
