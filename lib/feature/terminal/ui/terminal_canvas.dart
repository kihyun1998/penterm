import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';
import 'package:penterm/feature/terminal/model/enum_tab_type.dart';
import 'package:penterm/feature/terminal/model/split_layout_state.dart';
import 'package:penterm/feature/terminal/model/tab_info.dart';
import 'package:penterm/feature/terminal/model/terminal_drag_data.dart';
import 'package:penterm/feature/terminal/model/terminal_drag_state.dart';
import 'package:penterm/feature/terminal/provider/split_layout_provider.dart';
import 'package:penterm/feature/terminal/provider/terminal_drag_provider.dart';
import 'package:penterm/feature/terminal/ui/terminal_split_handler.dart';

import 'terminal_panel.dart'; // 새로 분리된 터미널 분할 핸들러

/// 앱의 메인 콘텐츠 영역을 담당하는 위젯 (터미널 캔버스)
class TerminalCanvas extends ConsumerWidget {
  final TabInfo? activeTabInfo;

  const TerminalCanvas({super.key, this.activeTabInfo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: activeTabInfo != null
          ? _buildTabContent(activeTabInfo!, ref)
          : _buildDefaultContent(ref),
    );
  }

  /// 활성 탭 정보에 따라 다른 콘텐츠를 빌드합니다.
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
        return _buildTerminalContent(tabInfo, ref);
    }
  }

  /// 터미널 탭의 콘텐츠를 빌드합니다. 분할 상태에 따라 다르게 렌더링됩니다.
  Widget _buildTerminalContent(TabInfo tabInfo, WidgetRef ref) {
    final dragState = ref.watch(terminalDragProvider);
    final splitState = ref.watch(currentTabSplitStateProvider);

    // 분할 상태에 따른 렌더링
    if (splitState.isSplit) {
      return _buildSplitTerminalContent(tabInfo, splitState, ref);
    } else {
      return _buildSingleTerminalContent(tabInfo, dragState, ref);
    }
  }

  /// 분할된 터미널 컨텐츠를 빌드합니다.
  Widget _buildSplitTerminalContent(
      TabInfo tabInfo, SplitLayoutState splitState, WidgetRef ref) {
    final orderedPanels = splitState.orderedPanels;

    return SizedBox(
      key: ValueKey('${tabInfo.id}_split_${splitState.splitType.name}'),
      width: double.infinity,
      height: double.infinity,
      child: splitState.splitType == SplitType.horizontal
          ? Row(
              children: orderedPanels
                  .map((panel) => TerminalPanel(panel: panel))
                  .toList())
          : Column(
              children: orderedPanels
                  .map((panel) => TerminalPanel(panel: panel))
                  .toList()),
    );
  }

  /// 단일 터미널 컨텐츠 (기존 로직)를 빌드합니다.
  Widget _buildSingleTerminalContent(
      TabInfo tabInfo, TerminalDragState dragState, WidgetRef ref) {
    // 현재 탭의 분할 상태 확인
    final splitState = ref.watch(currentTabSplitStateProvider);

    // 터미널 탭이 드래그 중인지 확인
    final isTerminalDragging =
        dragState.isDragging && dragState.draggingData?.isFromTab == true;

    // 이미 분할된 상태라면 드롭존 숨기기
    final shouldShowDropZones = isTerminalDragging && !splitState.isSplit;

    return Stack(
      key: ValueKey('${tabInfo.id}_single'),
      children: [
        // 기본 터미널 컨텐츠
        Container(
          width: double.infinity,
          color: ref.theme.color.secondaryVariant,
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
                // 분할 상태 표시
                if (splitState.isSplit)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: Text(
                      'Already Split (${splitState.splitType.name})',
                      style: ref.font.semiBoldText14.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 분할되지 않은 상태에서만 드롭존 표시
        if (shouldShowDropZones)
          TerminalSplitHandler(
            currentTab: TerminalDragData(
              terminalId: tabInfo.id,
              displayName: tabInfo.name,
              source: DragSource.tab,
            ),
          ),
      ],
    );
  }

  /// 활성 탭이 없을 때 기본 콘텐츠를 빌드합니다.
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
