import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/tab_drag_state.dart';
import 'tab_list_provider.dart';

part 'tab_drag_provider.g.dart';

@Riverpod(dependencies: [TabList])
class TabDrag extends _$TabDrag {
  @override
  TabDragState build() {
    return TabDragState.initial;
  }

  /// 드래그 시작
  void startDrag(String tabId) {
    final tabList = ref.read(tabListProvider);

    // 🚀 드래그 가능한 탭들만 필터링 (List 기반)
    final draggableTabs = tabList.where((tab) => tab.isClosable).toList();

    // 드래그 중인 탭이 존재하는지 확인
    final draggingTabExists = draggableTabs.any((tab) => tab.id == tabId);
    if (!draggingTabExists) {
      print('❌ Tab not found for drag: $tabId');
      return;
    }

    final draggingTab = draggableTabs.firstWhere((tab) => tab.id == tabId);
    print(
        '🚀 Start drag: ${draggingTab.name} (index ${draggableTabs.indexOf(draggingTab)})');

    state = state.startDrag(
      tabs: draggableTabs,
      draggingId: tabId,
    );
  }

  /// 🚀 타겟 index 업데이트 - order 대신 index 사용!
  void updateTarget(int newTargetIndex, {Offset? dragPosition}) {
    if (!state.isDragging) {
      print('❌ Cannot update target: not dragging');
      return;
    }

    // 🚀 유효한 index인지 확인
    if (newTargetIndex < 0 || newTargetIndex >= state.currentTabs.length) {
      print(
          '❌ Target index out of range: $newTargetIndex (max: ${state.currentTabs.length - 1})');
      return;
    }

    final targetTab = state.currentTabs[newTargetIndex];

    // 자기 자신에게 드롭하는 것도 허용 (원래 자리로 돌아가기)
    final draggingIndex = state.draggingIndex;
    if (draggingIndex == newTargetIndex) {
      print('🔄 Drop on self: ${targetTab.name} (return to original position)');
    } else {
      print('🎯 Update target: index $newTargetIndex (${targetTab.name})');
    }

    state = state.updateTarget(
      newTargetIndex: newTargetIndex,
      newDragPosition: dragPosition,
    );
  }

  /// 드래그 위치 업데이트 (타겟 index는 유지)
  void updatePosition(Offset position) {
    if (!state.isDragging) return;

    state = state.updatePosition(position);
  }

  /// 🚀 드래그 종료 (실제 순서 변경) - index 기반!
  void endDrag() {
    if (!state.isDragging) {
      print('❌ Cannot end drag: not dragging');
      return;
    }

    final draggingTab = state.draggingTab!;
    final targetIndex = state.targetIndex;
    final draggingIndex = state.draggingIndex!;

    print('✅ End drag: ${draggingTab.name}');

    // expectedResult의 순서 표시 (디버그용)
    final expectedOrder = state.expectedResult
        .asMap()
        .entries
        .map((e) => '${e.value.name}[${e.key}]')
        .join(', ');
    print('📋 Expected result: $expectedOrder');

    // 실제 순서 변경 적용
    if (targetIndex != null && targetIndex != draggingIndex) {
      print('🔄 Applying index change...');
      _applyIndexChange(draggingTab.id, draggingIndex, targetIndex);
    } else {
      print('📌 No index change needed');
    }

    // 드래그 상태 초기화
    state = state.endDrag();
  }

  /// 드래그 취소
  void cancelDrag() {
    if (!state.isDragging) return;

    print('❌ Cancel drag: ${state.draggingTab?.name}');
    state = state.endDrag();
  }

  /// 🚀 실제 탭 순서 변경 적용 (index 기반) - 혁신적으로 간단!
  void _applyIndexChange(String draggingTabId, int fromIndex, int toIndex) {
    final tabListNotifier = ref.read(tabListProvider.notifier);

    print(
        '🔧 Index change: $draggingTabId from index $fromIndex to index $toIndex');

    // 🚀 전체 탭 리스트에서의 실제 인덱스 계산
    final allTabs = ref.read(tabListProvider);
    final draggableTabs = allTabs.where((tab) => tab.isClosable).toList();

    // 드래그 가능한 탭들 중에서의 인덱스를 전체 탭 리스트의 인덱스로 변환
    final realFromIndex = allTabs.indexWhere((tab) => tab.id == draggingTabId);

    // toIndex에 해당하는 드래그 가능한 탭의 실제 인덱스 찾기
    final targetDraggableTab = draggableTabs[toIndex];
    final realToIndex =
        allTabs.indexWhere((tab) => tab.id == targetDraggableTab.id);

    if (realFromIndex == -1 || realToIndex == -1) {
      print(
          '❌ Could not find real indices: realFromIndex=$realFromIndex, realToIndex=$realToIndex');
      return;
    }

    print('🔧 Real indices: $realFromIndex → $realToIndex');

    // 🚀 TabListProvider의 간단한 reorderTab 메서드 호출!
    tabListNotifier.reorderTab(realFromIndex, realToIndex);

    print('✅ Index change applied successfully');
  }

  /// 디버그 정보 출력
  void printDebugInfo() {
    print('🐛 Debug Info:\n${state.debugInfo}');
  }
}
