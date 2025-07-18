import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/enum_tab_type.dart';
import '../model/tab_info.dart';
import 'tab_provider.dart';

part 'tab_list_provider.g.dart';

@Riverpod(dependencies: [ActiveTab])
class TabList extends _$TabList {
  @override
  List<TabInfo> build() {
    // 🚀 List로 초기화 - 순서는 List index가 담당
    return [
      TabInfo(
        id: TabType.home.value,
        type: TabType.home,
        name: TabType.home.displayName,
        isClosable: false,
        // order 필드 제거됨 - index 0
      ),
      TabInfo(
        id: TabType.sftp.value,
        type: TabType.sftp,
        name: TabType.sftp.displayName,
        isClosable: false,
        // order 필드 제거됨 - index 1
      ),
    ];
  }

  /// 🚀 새 터미널 탭 추가 - 매우 간단!
  void addTerminalTab() {
    final terminalCount =
        state.where((tab) => tab.type == TabType.terminal).length;

    final newTabId = 'terminal_${DateTime.now().millisecondsSinceEpoch}';

    final newTab = TabInfo(
      id: newTabId,
      type: TabType.terminal,
      name: 'Terminal ${terminalCount + 1}',
      isClosable: true,
      // order 필드 제거됨 - List.add()로 자동으로 마지막에 추가
    );

    // 🚀 단순 추가!
    state = [...state, newTab];

    // 새로 추가된 탭으로 이동
    ref.read(activeTabProvider.notifier).setTab(newTabId);
  }

  /// 🚀 탭 제거 - 자동 재정렬!
  void removeTab(String tabId) {
    final tabIndex = state.indexWhere((tab) => tab.id == tabId);

    if (tabIndex == -1) {
      return;
    }

    final tabToRemove = state[tabIndex];

    // 고정 탭은 제거할 수 없음
    if (!tabToRemove.isClosable) {
      return;
    }

    // 🚀 간단한 제거 - 순서 자동 재정렬됨!
    final newState = List<TabInfo>.from(state);
    newState.removeAt(tabIndex);
    state = newState;

    // 제거된 탭이 현재 활성 탭이었다면 Home으로 이동
    final activeTabId = ref.read(activeTabProvider);
    if (activeTabId == tabId) {
      ref.read(activeTabProvider.notifier).goToHome();
    }
  }

  /// 🆕 안전한 탭 제거 (활성 탭 변경하지 않음)
  void removeTabSafely(String tabId) {
    final tabIndex = state.indexWhere((tab) => tab.id == tabId);

    if (tabIndex == -1) {
      return;
    }

    final tabToRemove = state[tabIndex];

    // 고정 탭은 제거할 수 없음
    if (!tabToRemove.isClosable) {
      return;
    }

    // 현재 활성 탭 확인
    final activeTabId = ref.read(activeTabProvider);

    if (activeTabId == tabId) {
      return; // 분할 작업에서는 활성 탭을 제거하지 않음
    }

    // 🚀 안전하게 탭만 제거 (활성 탭 변경 없음)
    final newState = List<TabInfo>.from(state);
    newState.removeAt(tabIndex);
    state = newState;
  }

  /// 탭 이름 변경
  void renameTab(String tabId, String newName) {
    final tabIndex = state.indexWhere((tab) => tab.id == tabId);

    if (tabIndex == -1) {
      return;
    }

    final newState = List<TabInfo>.from(state);
    newState[tabIndex] = newState[tabIndex].copyWith(name: newName);
    state = newState;
  }

  /// 🚀 탭 순서 변경 (드래그 앤 드롭용)
  void reorderTab(int fromIndex, int toIndex) {
    // 인덱스 유효성 검사
    if (fromIndex < 0 ||
        fromIndex >= state.length ||
        toIndex < 0 ||
        toIndex >= state.length) {
      return;
    }

    final tabToMove = state[fromIndex];

    // 고정 탭은 이동할 수 없음
    if (!tabToMove.isClosable) {
      return;
    }

    // 🚀 혁신적으로 간단한 이동!
    final newState = List<TabInfo>.from(state);
    final tab = newState.removeAt(fromIndex);
    newState.insert(toIndex, tab);
    state = newState;
  }

  /// 🆕 ID로 탭 찾기 (헬퍼 메서드)
  TabInfo? findTabById(String tabId) {
    try {
      return state.firstWhere((tab) => tab.id == tabId);
    } catch (e) {
      return null;
    }
  }

  /// 🆕 ID로 탭 인덱스 찾기 (헬퍼 메서드)
  int findTabIndexById(String tabId) {
    return state.indexWhere((tab) => tab.id == tabId);
  }

  /// 🆕 특정 타입의 탭들 가져오기
  List<TabInfo> getTabsByType(TabType type) {
    return state.where((tab) => tab.type == type).toList();
  }

  /// 🆕 드래그 가능한 탭들만 가져오기 (closable 탭들)
  List<TabInfo> getDraggableTabs() {
    return state.where((tab) => tab.isClosable).toList();
  }

  /// 🆕 고정 탭들 가져오기 (HOME, SFTP)
  List<TabInfo> getFixedTabs() {
    return state.where((tab) => !tab.isClosable).toList();
  }
}
