import 'package:flutter/material.dart';

import 'tab_info.dart';

/// 새로운 탭 드래그 상태를 관리하는 모델
class TabDragState {
  /// 현재 드래그 가능한 탭들 (draggable tabs만)
  final Map<String, TabInfo> currentTabs;

  /// 드래그 중인 탭 ID
  final String? draggingTabId;

  /// 드롭 타겟 order (드롭될 위치의 order)
  final int? targetOrder;

  /// 예상 결과 순서 (드롭했을 때의 새로운 탭들)
  final Map<String, TabInfo> expectedResult;

  /// 드래그 중인 마우스 위치 (디버그용)
  final Offset? dragPosition;

  /// 드래그가 활성화된 상태인지
  bool get isDragging => draggingTabId != null;

  /// 드래그 중인 탭 정보
  TabInfo? get draggingTab => isDragging ? currentTabs[draggingTabId!] : null;

  /// 타겟 위치의 탭 정보 (드롭될 위치의 기존 탭)
  TabInfo? get targetTab => targetOrder != null
      ? currentTabs.values.where((tab) => tab.order == targetOrder).firstOrNull
      : null;

  const TabDragState({
    this.currentTabs = const {},
    this.draggingTabId,
    this.targetOrder,
    this.expectedResult = const {},
    this.dragPosition,
  });

  /// 초기 상태 (드래그 없음)
  static const TabDragState initial = TabDragState();

  /// 드래그 시작
  TabDragState startDrag({
    required Map<String, TabInfo> tabs,
    required String draggingId,
  }) {
    return TabDragState(
      currentTabs: tabs,
      draggingTabId: draggingId,
      targetOrder: null,
      expectedResult: tabs, // 초기에는 현재 순서와 동일
      dragPosition: null,
    );
  }

  /// 타겟 order 업데이트 및 예상 결과 계산
  TabDragState updateTarget({
    required int newTargetOrder,
    Offset? newDragPosition,
  }) {
    if (!isDragging) return this;

    final newExpectedResult = _calculateExpectedResult(
      currentTabs: currentTabs,
      draggingTabId: draggingTabId!,
      targetOrder: newTargetOrder,
    );

    return TabDragState(
      currentTabs: currentTabs,
      draggingTabId: draggingTabId,
      targetOrder: newTargetOrder,
      expectedResult: newExpectedResult,
      dragPosition: newDragPosition ?? dragPosition,
    );
  }

  /// 드래그 위치만 업데이트 (타겟 order는 유지)
  TabDragState updatePosition(Offset newPosition) {
    if (!isDragging) return this;

    return TabDragState(
      currentTabs: currentTabs,
      draggingTabId: draggingTabId,
      targetOrder: targetOrder,
      expectedResult: expectedResult,
      dragPosition: newPosition,
    );
  }

  /// 드래그 종료
  TabDragState endDrag() {
    return const TabDragState();
  }

  /// 예상 결과 계산 로직 (order 기반)
  static Map<String, TabInfo> _calculateExpectedResult({
    required Map<String, TabInfo> currentTabs,
    required String draggingTabId,
    required int targetOrder,
  }) {
    final draggingTab = currentTabs[draggingTabId];
    if (draggingTab == null) return currentTabs;

    // 현재 order로 정렬된 탭 리스트
    final sortedTabs = currentTabs.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // 드래그 중인 탭의 현재 order
    final currentDraggingOrder = draggingTab.order;

    // 자기 자신에게 드롭하는 경우
    if (currentDraggingOrder == targetOrder) {
      return currentTabs; // 변경 없음
    }

    final result = <String, TabInfo>{};

    // 모든 탭의 새로운 order 계산
    for (final tab in sortedTabs) {
      if (tab.id == draggingTabId) {
        // 드래그 중인 탭은 타겟 order로 설정
        result[tab.id] = tab.copyWith(order: targetOrder);
      } else if (currentDraggingOrder < targetOrder) {
        // 뒤로 이동하는 경우: 중간 탭들을 앞으로 이동
        if (tab.order > currentDraggingOrder && tab.order <= targetOrder) {
          result[tab.id] = tab.copyWith(order: tab.order - 1);
        } else {
          result[tab.id] = tab; // 변경 없음
        }
      } else {
        // 앞으로 이동하는 경우: 중간 탭들을 뒤로 이동
        if (tab.order >= targetOrder && tab.order < currentDraggingOrder) {
          result[tab.id] = tab.copyWith(order: tab.order + 1);
        } else {
          result[tab.id] = tab; // 변경 없음
        }
      }
    }

    return result;
  }

  /// 디버그 정보를 위한 문자열 표현
  String get debugInfo {
    if (!isDragging) return 'No drag in progress';

    // order 순으로 정렬해서 표시
    final currentOrder = currentTabs.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final expectedOrder = expectedResult.values.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    // 드래그 중인 탭의 원래 order
    final originalOrder = draggingTab?.order;

    // 타겟 탭 정보
    final targetTabInfo =
        targetTab != null ? '${targetTab!.name}(${targetTab!.order})' : 'None';

    // Place Order 계산 (자기 자신인지 확인)
    String placeOrderInfo;
    if (targetOrder == null) {
      placeOrderInfo = '${originalOrder ?? 'unknown'} (original position)';
    } else if (targetOrder == originalOrder) {
      placeOrderInfo = '$targetOrder (same as original - no change)';
    } else {
      placeOrderInfo = '$targetOrder (new position)';
    }

    return '''
Current: [${currentOrder.map((tab) => '${tab.name}(${tab.order})').join(', ')}]
Dragging: ${draggingTab?.name} (original order: $originalOrder)
Target Order: ${targetOrder ?? 'null'} (${targetOrder != null ? 'Target Tab: $targetTabInfo' : 'Outside drop zones'})
Place Order: $placeOrderInfo
Expected: [${expectedOrder.map((tab) => '${tab.name}(${tab.order})').join(', ')}]
''';
  }

  TabDragState copyWith({
    Map<String, TabInfo>? currentTabs,
    String? draggingTabId,
    int? targetOrder,
    Map<String, TabInfo>? expectedResult,
    Offset? dragPosition,
  }) {
    return TabDragState(
      currentTabs: currentTabs ?? this.currentTabs,
      draggingTabId: draggingTabId ?? this.draggingTabId,
      targetOrder: targetOrder ?? this.targetOrder,
      expectedResult: expectedResult ?? this.expectedResult,
      dragPosition: dragPosition ?? this.dragPosition,
    );
  }
}
