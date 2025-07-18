import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/split_layout_state.dart';
import 'tab_list_provider.dart';
import 'tab_provider.dart';

part 'split_layout_provider.g.dart';

@Riverpod(dependencies: [ActiveTab, TabList])
class SplitLayout extends _$SplitLayout {
  @override
  Map<String, SplitLayoutState> build() {
    // 탭별 분할 상태를 관리하는 Map
    return {};
  }

  /// 현재 활성 탭의 분할 상태 반환
  SplitLayoutState getCurrentTabSplitState() {
    final activeTabId = ref.read(activeTabProvider);
    return state[activeTabId] ?? SplitLayoutState(activeTabId: activeTabId);
  }

  /// 특정 탭의 분할 상태 업데이트
  void _updateTabSplitState(String tabId, SplitLayoutState newState) {
    state = {
      ...state,
      tabId: newState,
    };
  }

  /// 현재 활성 탭의 분할 상태 업데이트
  void _updateCurrentTabSplitState(SplitLayoutState newState) {
    final activeTabId = ref.read(activeTabProvider);
    _updateTabSplitState(activeTabId, newState);
  }

  /// 분할 시작
  /// [terminalId]: 분할할 터미널 ID (드래그된 터미널)
  /// [splitType]: 분할 방향
  /// [targetPosition]: 드래그된 터미널이 들어갈 위치
  void startSplit({
    required String terminalId,
    required SplitType splitType,
    required PanelPosition targetPosition,
  }) {
    final currentState = getCurrentTabSplitState();

    // 이미 분할된 상태라면 로그만 출력하고 리턴
    if (currentState.isSplit) {
      return;
    }

    // 현재 활성 탭 ID (기존 터미널)
    final currentActiveTabId = currentState.activeTabId;

    // 새로운 패널들 생성
    final positions = PanelPosition.forSplitType(splitType);
    final panels = <String, PanelInfo>{};

    for (int i = 0; i < positions.length; i++) {
      final position = positions[i];
      final panelId = '${currentState.activeTabId}_panel_${position.name}';

      final isTargetPanel = position == targetPosition;
      final isOppositePanel = position == targetPosition.opposite;

      // 타겟 위치: 드래그된 터미널, 반대 위치: 기존 활성 터미널
      String? assignedTerminalId;
      bool isActive = false;

      if (isTargetPanel) {
        assignedTerminalId = terminalId;
        isActive = true; // 드래그된 터미널이 활성
      } else if (isOppositePanel) {
        assignedTerminalId = currentActiveTabId; // 기존 터미널을 반대편에 배치
        isActive = false;
      }

      panels[panelId] = PanelInfo(
        id: panelId,
        terminalId: assignedTerminalId,
        position: position,
        isActive: isActive,
      );
    }

    // 새로운 분할 상태 생성
    final newState = currentState.copyWith(
      splitType: splitType,
      panels: panels,
      activePanelId: panels.values.firstWhere((panel) => panel.isActive).id,
    );

    _updateCurrentTabSplitState(newState);

    // 현재 활성 탭 이름 변경 (Split 표시)

    ref.read(tabListProvider.notifier).renameTab(currentActiveTabId, 'Split');

    // 드래그된 터미널 탭을 탭 목록에서 안전하게 제거

    ref.read(tabListProvider.notifier).removeTabSafely(terminalId);
  }
}

/// 현재 활성 탭의 분할 상태를 반환하는 편의 Provider
@Riverpod(dependencies: [SplitLayout, ActiveTab])
SplitLayoutState currentTabSplitState(Ref ref) {
  final splitLayoutState = ref.watch(splitLayoutProvider);
  final activeTabId = ref.watch(activeTabProvider);

  return splitLayoutState[activeTabId] ??
      SplitLayoutState(activeTabId: activeTabId);
}
