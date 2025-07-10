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

  /// 탭 순서 변경 (드래그 앤 드롭용)
  void reorderTab(String tabId, int targetIndex) {
    final currentTabs = List<TabInfo>.from(state);

    // 이동할 탭 찾기
    final sourceIndex = currentTabs.indexWhere((tab) => tab.id == tabId);
    if (sourceIndex == -1) return;

    final tabToMove = currentTabs[sourceIndex];

    // 고정 탭은 이동할 수 없음
    if (!tabToMove.isClosable) return;

    // 고정 탭 개수 계산 (HOME, SFTP)
    final fixedTabCount = currentTabs.where((tab) => !tab.isClosable).length;

    // 타겟 인덱스는 고정 탭 이후여야 함
    final adjustedTargetIndex =
        targetIndex < fixedTabCount ? fixedTabCount : targetIndex;

    // 범위 체크
    if (adjustedTargetIndex < 0 || adjustedTargetIndex > currentTabs.length) {
      return;
    }

    // 탭 이동
    currentTabs.removeAt(sourceIndex);

    // 삽입 위치 조정 (원본이 제거되었으므로)
    final insertIndex = adjustedTargetIndex > sourceIndex
        ? adjustedTargetIndex - 1
        : adjustedTargetIndex;

    currentTabs.insert(insertIndex, tabToMove);

    state = currentTabs;
  }
}
