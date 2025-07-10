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

    // 자기 자신에게 드롭하는 것도 허용 (원래 자리로 돌아가기)
    if (state.draggingTabId == targetTab.id) {
      print('🔄 Drop on self: ${targetTab.name} (return to original position)');
    } else {
      print('🎯 Update target: order $newTargetOrder (${targetTab.name})');
    }

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

    // 실제 순서 변경 적용
    if (targetOrder != null && targetOrder != draggingTab.order) {
      print('🔄 Applying order change...');
      _applyOrderChange(draggingTab.id, draggingTab.order, targetOrder);
    } else {
      print('📌 No order change needed');
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
  void _applyOrderChange(String draggingTabId, int fromOrder, int toOrder) {
    final tabListNotifier = ref.read(tabListProvider.notifier);

    print(
        '🔧 Order change: $draggingTabId from order $fromOrder to order $toOrder');

    // 새로운 order 기반 메서드 호출
    tabListNotifier.reorderTabByOrder(draggingTabId, fromOrder, toOrder);

    print('✅ Order change applied successfully');
  }

  /// 디버그 정보 출력
  void printDebugInfo() {
    print('🐛 Debug Info:\n${state.debugInfo}');
  }
}
