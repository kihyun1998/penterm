import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/enum_tab_type.dart';
import '../model/tab_info.dart';
import 'tab_provider.dart';

part 'tab_list_provider.g.dart';

@Riverpod(dependencies: [ActiveTab])
class TabList extends _$TabList {
  @override
  Map<String, TabInfo> build() {
    return {
      TabType.home.value: TabInfo(
        id: TabType.home.value,
        type: TabType.home,
        name: TabType.home.displayName,
        isClosable: false,
        order: 0,
      ),
      TabType.sftp.value: TabInfo(
        id: TabType.sftp.value,
        type: TabType.sftp,
        name: TabType.sftp.displayName,
        isClosable: false,
        order: 1,
      ),
    };
  }

  /// 새 터미널 탭 추가
  void addTerminalTab() {
    final currentTabs = state;
    final terminalCount =
        currentTabs.values.where((tab) => tab.type == TabType.terminal).length;

    final newTabId = 'terminal_${DateTime.now().millisecondsSinceEpoch}';

    // 마지막 order 계산
    final maxOrder = currentTabs.values.isNotEmpty
        ? currentTabs.values
            .map((tab) => tab.order)
            .reduce((a, b) => a > b ? a : b)
        : -1;

    final newTab = TabInfo(
      id: newTabId,
      type: TabType.terminal,
      name: 'Terminal ${terminalCount + 1}',
      isClosable: true,
      order: maxOrder + 1,
    );

    state = {...currentTabs, newTabId: newTab};

    // 새로 추가된 탭으로 이동
    ref.read(activeTabProvider.notifier).setTab(newTabId);
  }

  /// 탭 제거
  void removeTab(String tabId) {
    final currentTabs = Map<String, TabInfo>.from(state);
    final tabToRemove = currentTabs[tabId];

    if (tabToRemove == null) return;

    // 고정 탭은 제거할 수 없음
    if (!tabToRemove.isClosable) return;

    currentTabs.remove(tabId);
    state = currentTabs;

    // 제거된 탭이 현재 활성 탭이었다면 Home으로 이동
    final activeTabId = ref.read(activeTabProvider);
    if (activeTabId == tabId) {
      ref.read(activeTabProvider.notifier).goToHome();
    }
  }

  /// 탭 이름 변경
  void renameTab(String tabId, String newName) {
    final currentTabs = Map<String, TabInfo>.from(state);
    final tab = currentTabs[tabId];

    if (tab != null) {
      currentTabs[tabId] = tab.copyWith(name: newName);
      state = currentTabs;
    }
  }

  /// 탭 순서 변경 (드래그 앤 드롭용)
  void reorderTab(String tabId, int targetIndex) {
    final currentTabs = Map<String, TabInfo>.from(state);
    final tabToMove = currentTabs[tabId];

    if (tabToMove == null || !tabToMove.isClosable) return;

    // 고정 탭 개수 계산
    final fixedTabCount =
        currentTabs.values.where((tab) => !tab.isClosable).length;

    // 타겟 인덱스 조정 (고정 탭 이후로만 이동 가능)
    final adjustedTargetIndex =
        targetIndex < fixedTabCount ? fixedTabCount : targetIndex;

    // 전체 탭 리스트 (순서대로 정렬)
    final orderedTabs = currentTabs.values.toList();
    orderedTabs.sort((a, b) => a.order.compareTo(b.order));

    // 범위 체크
    if (adjustedTargetIndex < 0 || adjustedTargetIndex >= orderedTabs.length) {
      return;
    }

    // 새로운 order 값들 계산
    final updatedTabs = <String, TabInfo>{};

    // 기존 탭들의 order를 재정렬
    int newOrder = 0;
    for (int i = 0; i < orderedTabs.length; i++) {
      final tab = orderedTabs[i];

      if (tab.id == tabId) {
        // 드래그 중인 탭은 건너뛰기 (나중에 타겟 위치에 삽입)
        continue;
      }

      if (newOrder == adjustedTargetIndex) {
        // 타겟 위치에 드래그 중인 탭 삽입
        updatedTabs[tabId] = tabToMove.copyWith(order: newOrder);
        newOrder++;
      }

      // 기존 탭 추가
      updatedTabs[tab.id] = tab.copyWith(order: newOrder);
      newOrder++;
    }

    // 마지막 위치에 삽입하는 경우
    if (!updatedTabs.containsKey(tabId)) {
      updatedTabs[tabId] = tabToMove.copyWith(order: adjustedTargetIndex);
    }

    state = updatedTabs;
  }

  /// order 기반 탭 순서 변경 (새로운 드래그 앤 드롭용)
  void reorderTabByOrder(String tabId, int fromOrder, int toOrder) {
    final currentTabs = Map<String, TabInfo>.from(state);
    final tabToMove = currentTabs[tabId];

    if (tabToMove == null || !tabToMove.isClosable) {
      print('❌ Cannot reorder: tab not found or not closable');
      return;
    }

    print('🔧 Reordering $tabId from order $fromOrder to order $toOrder');

    // 순서대로 정렬된 탭 리스트
    final sortedTabs = currentTabs.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    final updatedTabs = <String, TabInfo>{};

    // 모든 탭의 새로운 order 계산
    for (final tab in sortedTabs) {
      if (tab.id == tabId) {
        // 드래그 중인 탭은 타겟 order로 설정
        updatedTabs[tab.id] = tab.copyWith(order: toOrder);
        print('  └─ ${tab.name}: ${tab.order} → $toOrder (moved)');
      } else if (fromOrder < toOrder) {
        // 뒤로 이동하는 경우: 중간 탭들을 앞으로 이동
        if (tab.order > fromOrder && tab.order <= toOrder) {
          final newOrder = tab.order - 1;
          updatedTabs[tab.id] = tab.copyWith(order: newOrder);
          print('  └─ ${tab.name}: ${tab.order} → $newOrder (shifted left)');
        } else {
          updatedTabs[tab.id] = tab; // 변경 없음
          print('  └─ ${tab.name}: ${tab.order} (no change)');
        }
      } else {
        // 앞으로 이동하는 경우: 중간 탭들을 뒤로 이동
        if (tab.order >= toOrder && tab.order < fromOrder) {
          final newOrder = tab.order + 1;
          updatedTabs[tab.id] = tab.copyWith(order: newOrder);
          print('  └─ ${tab.name}: ${tab.order} → $newOrder (shifted right)');
        } else {
          updatedTabs[tab.id] = tab; // 변경 없음
          print('  └─ ${tab.name}: ${tab.order} (no change)');
        }
      }
    }

    state = updatedTabs;

    // 결과 확인
    final resultTabs = updatedTabs.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    print(
        '📋 Final order: ${resultTabs.map((tab) => '${tab.name}(${tab.order})').join(', ')}');
  }
}
