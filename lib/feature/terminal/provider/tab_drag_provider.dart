import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/tab_drag_state.dart';
import '../model/tab_info.dart';
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
    final tabMap = ref.read(tabListProvider);

    // 드래그 가능한 탭들만 필터링
    final draggableTabs = <String, TabInfo>{};
    for (final entry in tabMap.entries) {
      if (entry.value.isClosable) {
        draggableTabs[entry.key] = entry.value;
      }
    }

    // 드래그 중인 탭이 존재하는지 확인
    if (!draggableTabs.containsKey(tabId)) {
      print('❌ Tab not found for drag: $tabId');
      return;
    }

    final draggingTab = draggableTabs[tabId]!;
    print('🚀 Start drag: ${draggingTab.name} (order ${draggingTab.order})');

    state = state.startDrag(
      tabs: draggableTabs,
      draggingId: tabId,
    );
  }

  /// 타겟 order 업데이트
  void updateTarget(int newTargetOrder, {Offset? dragPosition}) {
    if (!state.isDragging) {
      print('❌ Cannot update target: not dragging');
      return;
    }

    // 존재하는 order인지 확인
    final targetTab = state.currentTabs.values
        .where((tab) => tab.order == newTargetOrder)
        .firstOrNull;

    if (targetTab == null) {
      print('❌ Target order not found: $newTargetOrder');
      return;
    }

    print('🎯 Update target: order $newTargetOrder (${targetTab.name})');

    state = state.updateTarget(
      newTargetOrder: newTargetOrder,
      newDragPosition: dragPosition,
    );
  }

  /// 드래그 위치 업데이트 (타겟 인덱스는 유지)
  void updatePosition(Offset position) {
    if (!state.isDragging) return;

    state = state.updatePosition(position);
  }

  /// 드래그 종료 (실제 순서 변경)
  void endDrag() {
    if (!state.isDragging) {
      print('❌ Cannot end drag: not dragging');
      return;
    }

    final draggingTab = state.draggingTab!;
    final targetOrder = state.targetOrder;

    print('✅ End drag: ${draggingTab.name}');

    // expectedResult의 순서 표시 (디버그용)
    final expectedOrder = state.expectedResult.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    print(
        '📋 Expected result: ${expectedOrder.map((tab) => '${tab.name}(${tab.order})').join(', ')}');

    // 실제 순서 변경 (targetOrder가 있는 경우만)
    if (targetOrder != null) {
      _applyReorder(draggingTab.id, targetOrder);
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

  /// 실제 탭 순서 변경 적용 (order 기반)
  void _applyReorder(String tabId, int targetOrder) {
    final tabListNotifier = ref.read(tabListProvider.notifier);

    // 현재 전체 탭 맵 가져오기
    final currentTabMap = ref.read(tabListProvider);
    final allTabs = currentTabMap.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // 고정 탭들의 최대 order 계산
    final fixedTabs = allTabs.where((tab) => !tab.isClosable);
    final maxFixedOrder = fixedTabs.isNotEmpty
        ? fixedTabs.map((tab) => tab.order).reduce((a, b) => a > b ? a : b)
        : -1;

    // 전체 탭 리스트에서의 실제 타겟 order 계산
    final actualTargetOrder = maxFixedOrder + 1 + targetOrder;

    print('🔄 Applying reorder: $tabId to order $actualTargetOrder');

    // 임시로 기존 reorderTab 메서드 사용 (나중에 order 기반으로 수정 필요)
    tabListNotifier.reorderTab(tabId, actualTargetOrder);
  }

  /// 디버그 정보 출력
  void printDebugInfo() {
    print('🐛 Debug Info:\n${state.debugInfo}');
  }
}
