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

  /// 특정 탭의 분할 상태 반환
  SplitLayoutState getTabSplitState(String tabId) {
    return state[tabId] ?? SplitLayoutState(activeTabId: tabId);
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
      print('❌ Already split: ${currentState.splitType.name}');
      return;
    }

    // 현재 활성 탭 ID (기존 터미널)
    final currentActiveTabId = currentState.activeTabId;

    print(
        '🚀 Start split: $terminalId → ${splitType.name} (${targetPosition.name})');
    print('  └─ Current active tab: $currentActiveTabId');

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

      print(
          '  └─ Panel created: $panelId (${position.name}) - ${assignedTerminalId ?? 'empty'}${isActive ? ' [ACTIVE]' : ''}');
    }

    // 새로운 분할 상태 생성
    final newState = currentState.copyWith(
      splitType: splitType,
      panels: panels,
      activePanelId: panels.values.firstWhere((panel) => panel.isActive).id,
    );

    _updateCurrentTabSplitState(newState);

    // 현재 활성 탭 이름 변경 (Split 표시)
    print('✏️ Updating active tab name to show split state');
    ref
        .read(tabListProvider.notifier)
        .renameTab(currentActiveTabId, 'Terminal (Split)');

    // 드래그된 터미널 탭을 탭 목록에서 안전하게 제거
    print('🗑️ Safely removing dragged terminal tab: $terminalId');
    ref.read(tabListProvider.notifier).removeTabSafely(terminalId);

    // 🆕 제거 후 탭 상태 확인
    final remainingTabs = ref.read(tabListProvider);
    print('📋 Remaining tabs after removal:');
    for (final tab in remainingTabs.values) {
      print('  └─ ${tab.name} (${tab.id}) - closable: ${tab.isClosable}');
    }

    print('✅ Split created successfully');
    print(newState.debugInfo);
  }

  /// 분할 해제 (모든 패널을 제거하고 일반 탭으로 되돌림)
  /// [terminalId]: 분할 해제 후 남겨둘 터미널 ID (null이면 모든 터미널 제거)
  void clearSplit({String? terminalId}) {
    final currentState = getCurrentTabSplitState();

    if (!currentState.isSplit) {
      print('❌ No split to clear');
      return;
    }

    print('🔄 Clear split for tab: ${currentState.activeTabId}');

    // 분할된 패널들의 터미널 ID 수집
    final terminalIds = currentState.panels.values
        .where((panel) => panel.hasTerminal)
        .map((panel) => panel.terminalId!)
        .toList();

    print('  └─ Found terminals in split: $terminalIds');

    // 현재 활성 탭 이름 복원
    print('✏️ Restoring active tab name');
    ref
        .read(tabListProvider.notifier)
        .renameTab(currentState.activeTabId, 'Terminal');

    // 분할 해제 시 다른 터미널들을 새 탭으로 추가
    final tabListNotifier = ref.read(tabListProvider.notifier);
    for (int i = 0; i < terminalIds.length; i++) {
      final currentTerminalId = terminalIds[i];
      if (currentTerminalId != currentState.activeTabId) {
        // 현재 활성 탭이 아닌 터미널들만 다시 추가
        print('  └─ Recreating tab for terminal: $currentTerminalId');
        tabListNotifier.addTerminalTab(); // 새 탭 생성 (임시)
        // TODO: 실제로는 원래 터미널 정보로 복원해야 함
      }
    }

    if (terminalId != null) {
      print('  └─ Keeping terminal: $terminalId');
    }

    // 분할 해제된 새로운 상태
    final newState = SplitLayoutState(
      activeTabId: currentState.activeTabId,
      splitType: SplitType.none,
      panels: {},
      activePanelId: null,
    );

    _updateCurrentTabSplitState(newState);
    print('✅ Split cleared successfully');
  }

  /// 터미널을 특정 패널로 이동
  /// [terminalId]: 이동할 터미널 ID
  /// [targetPanelId]: 대상 패널 ID
  void moveTerminalToPanel({
    required String terminalId,
    required String targetPanelId,
  }) {
    final currentState = getCurrentTabSplitState();

    if (!currentState.isSplit) {
      print('❌ Cannot move terminal: not split');
      return;
    }

    final targetPanel = currentState.panels[targetPanelId];
    if (targetPanel == null) {
      print('❌ Target panel not found: $targetPanelId');
      return;
    }

    print('🔄 Move terminal: $terminalId → ${targetPanel.position.name}');

    final updatedPanels = <String, PanelInfo>{};

    for (final entry in currentState.panels.entries) {
      final panelId = entry.key;
      final panel = entry.value;

      if (panel.terminalId == terminalId) {
        // 기존 터미널이 있던 패널에서 제거
        updatedPanels[panelId] = panel.clearTerminal().deactivate();
        print('  └─ Removed from: ${panel.position.name}');
      } else if (panelId == targetPanelId) {
        // 대상 패널에 터미널 할당
        updatedPanels[panelId] = panel.assignTerminal(terminalId).activate();
        print('  └─ Added to: ${panel.position.name}');
      } else {
        // 다른 패널들은 그대로 유지 (비활성화)
        updatedPanels[panelId] = panel.deactivate();
      }
    }

    final newState = currentState.copyWith(
      panels: updatedPanels,
      activePanelId: targetPanelId,
    );

    _updateCurrentTabSplitState(newState);
    print('✅ Terminal moved successfully');
  }

  /// 활성 패널 변경
  /// [panelId]: 활성화할 패널 ID
  void setActivePanel(String panelId) {
    final currentState = getCurrentTabSplitState();

    if (!currentState.isSplit) {
      print('❌ Cannot set active panel: not split');
      return;
    }

    final targetPanel = currentState.panels[panelId];
    if (targetPanel == null) {
      print('❌ Panel not found: $panelId');
      return;
    }

    print('🎯 Set active panel: ${targetPanel.position.name}');

    // 모든 패널을 비활성화하고 타겟 패널만 활성화
    final updatedPanels = <String, PanelInfo>{};
    for (final entry in currentState.panels.entries) {
      final currentPanelId = entry.key;
      final panel = entry.value;

      updatedPanels[currentPanelId] =
          currentPanelId == panelId ? panel.activate() : panel.deactivate();
    }

    final newState = currentState.copyWith(
      panels: updatedPanels,
      activePanelId: panelId,
    );

    _updateCurrentTabSplitState(newState);
  }

  /// 분할 방향 변경
  /// [newSplitType]: 새로운 분할 방향
  /// 기존 터미널들의 위치는 첫 번째, 두 번째 순서로 재배치
  void changeSplitType(SplitType newSplitType) {
    final currentState = getCurrentTabSplitState();

    if (!currentState.isSplit) {
      print('❌ Cannot change split type: not split');
      return;
    }

    if (currentState.splitType == newSplitType) {
      print('❌ Same split type: ${newSplitType.name}');
      return;
    }

    print(
        '🔄 Change split type: ${currentState.splitType.name} → ${newSplitType.name}');

    // 기존 패널들을 순서대로 정렬
    final orderedPanels = currentState.orderedPanels;
    final newPositions = PanelPosition.forSplitType(newSplitType);

    final newPanels = <String, PanelInfo>{};
    String? newActivePanelId;

    for (int i = 0; i < newPositions.length && i < orderedPanels.length; i++) {
      final oldPanel = orderedPanels[i];
      final newPosition = newPositions[i];
      final newPanelId =
          '${currentState.activeTabId}_panel_${newPosition.name}';

      final newPanel = PanelInfo(
        id: newPanelId,
        terminalId: oldPanel.terminalId,
        position: newPosition,
        isActive: oldPanel.isActive,
      );

      newPanels[newPanelId] = newPanel;

      if (newPanel.isActive) {
        newActivePanelId = newPanelId;
      }

      print(
          '  └─ ${oldPanel.position.name} → ${newPosition.name} (${oldPanel.terminalId ?? 'empty'})');
    }

    final newState = currentState.copyWith(
      splitType: newSplitType,
      panels: newPanels,
      activePanelId: newActivePanelId,
    );

    _updateCurrentTabSplitState(newState);
    print('✅ Split type changed successfully');
    print(newState.debugInfo);
  }

  /// 특정 탭의 분할 상태 제거 (탭이 삭제될 때 호출)
  void removeTabSplit(String tabId) {
    if (state.containsKey(tabId)) {
      final newState = Map<String, SplitLayoutState>.from(state);
      newState.remove(tabId);
      state = newState;
      print('🗑️ Removed split state for tab: $tabId');
    }
  }

  /// 디버그: 현재 상태 출력
  void printCurrentState() {
    final currentState = getCurrentTabSplitState();
    print('🐛 Current Split State:');
    print(currentState.debugInfo);
  }
}

/// 현재 활성 탭의 분할 상태를 반환하는 편의 Provider
@Riverpod(dependencies: [SplitLayout, ActiveTab])
SplitLayoutState currentTabSplitState(Ref ref) {
  final splitLayoutState = ref.watch(splitLayoutProvider);
  final activeTabId = ref.watch(activeTabProvider);
  final splitLayoutNotifier = ref.read(splitLayoutProvider.notifier);

  // 현재 탭의 분할 상태 가져오기
  final currentState = splitLayoutNotifier.getCurrentTabSplitState();

  // 디버그 로그
  print('🔄 currentTabSplitState updated: $activeTabId');
  print('  └─ isSplit: ${currentState.isSplit}');
  print('  └─ splitType: ${currentState.splitType.name}');
  print('  └─ panelCount: ${currentState.panelCount}');

  return currentState;
}
