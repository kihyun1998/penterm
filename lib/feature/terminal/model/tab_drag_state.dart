import 'package:flutter/material.dart';

import 'tab_info.dart';

/// 탭 드래그 상태를 관리하는 모델 (index 기반)
class TabDragState {
  /// 현재 드래그 가능한 탭들 (List 순서 그대로)
  final List<TabInfo> currentTabs;

  /// 드래그 중인 탭 ID
  final String? draggingTabId;

  /// 드롭 타겟 index (드롭될 위치의 index)
  final int? targetIndex;

  /// 예상 결과 순서 (드롭했을 때의 새로운 탭 리스트)
  final List<TabInfo> expectedResult;

  /// 드래그 중인 마우스 위치 (디버그용)
  final Offset? dragPosition;

  /// 드래그가 활성화된 상태인지
  bool get isDragging => draggingTabId != null;

  /// 드래그 중인 탭 정보
  TabInfo? get draggingTab => isDragging
      ? currentTabs.firstWhere((tab) => tab.id == draggingTabId!,
          orElse: () => throw StateError('Dragging tab not found'))
      : null;

  /// 타겟 위치의 탭 정보 (드롭될 위치의 기존 탭)
  TabInfo? get targetTab =>
      targetIndex != null && targetIndex! < currentTabs.length
          ? currentTabs[targetIndex!]
          : null;

  const TabDragState({
    this.currentTabs = const [],
    this.draggingTabId,
    this.targetIndex,
    this.expectedResult = const [],
    this.dragPosition,
  });

  /// 초기 상태 (드래그 없음)
  static const TabDragState initial = TabDragState();

  /// 드래그 시작
  TabDragState startDrag({
    required List<TabInfo> tabs,
    required String draggingId,
  }) {
    return TabDragState(
      currentTabs: tabs,
      draggingTabId: draggingId,
      targetIndex: null,
      expectedResult: tabs, // 초기에는 현재 순서와 동일
      dragPosition: null,
    );
  }

  /// 타겟 index 업데이트 및 예상 결과 계산
  TabDragState updateTarget({
    required int newTargetIndex,
    Offset? newDragPosition,
  }) {
    if (!isDragging) return this;

    // 유효한 index인지 확인
    if (newTargetIndex < 0 || newTargetIndex >= currentTabs.length) {
      return this;
    }

    final newExpectedResult = _calculateExpectedResult(
      currentTabs: currentTabs,
      draggingTabId: draggingTabId!,
      targetIndex: newTargetIndex,
    );

    return TabDragState(
      currentTabs: currentTabs,
      draggingTabId: draggingTabId,
      targetIndex: newTargetIndex,
      expectedResult: newExpectedResult,
      dragPosition: newDragPosition ?? dragPosition,
    );
  }

  /// 드래그 위치만 업데이트 (타겟 index는 유지)
  TabDragState updatePosition(Offset newPosition) {
    if (!isDragging) return this;

    return TabDragState(
      currentTabs: currentTabs,
      draggingTabId: draggingTabId,
      targetIndex: targetIndex,
      expectedResult: expectedResult,
      dragPosition: newPosition,
    );
  }

  /// 드래그 종료
  TabDragState endDrag() {
    return const TabDragState();
  }

  /// 🚀 예상 결과 계산 로직 (index 기반 - 훨씬 간단!)
  static List<TabInfo> _calculateExpectedResult({
    required List<TabInfo> currentTabs,
    required String draggingTabId,
    required int targetIndex,
  }) {
    // 드래그 중인 탭의 현재 index 찾기
    final currentDraggingIndex =
        currentTabs.indexWhere((tab) => tab.id == draggingTabId);
    if (currentDraggingIndex == -1) return currentTabs;

    // 자기 자신에게 드롭하는 경우
    if (currentDraggingIndex == targetIndex) {
      return currentTabs; // 변경 없음
    }

    // 🚀 List 이동 시뮬레이션 (매우 간단!)
    final result = List<TabInfo>.from(currentTabs);
    final draggingTab = result.removeAt(currentDraggingIndex);

    // targetIndex 조정 (앞에서 제거했을 경우)
    final adjustedTargetIndex =
        currentDraggingIndex < targetIndex ? targetIndex - 1 : targetIndex;

    result.insert(adjustedTargetIndex, draggingTab);
    return result;
  }

  /// 드래그 중인 탭의 현재 index
  int? get draggingIndex => isDragging
      ? currentTabs.indexWhere((tab) => tab.id == draggingTabId!)
      : null;

  /// 디버그 정보를 위한 문자열 표현
  String get debugInfo {
    if (!isDragging) return 'No drag in progress';

    // 드래그 중인 탭의 원래 index
    final originalIndex = draggingIndex;

    // 타겟 탭 정보
    final targetTabInfo =
        targetTab != null ? '${targetTab!.name}[$targetIndex]' : 'None';

    // Place Index 계산 (자기 자신인지 확인)
    String placeIndexInfo;
    if (targetIndex == null) {
      placeIndexInfo = '${originalIndex ?? 'unknown'} (original position)';
    } else if (targetIndex == originalIndex) {
      placeIndexInfo = '$targetIndex (same as original - no change)';
    } else {
      placeIndexInfo = '$targetIndex (new position)';
    }

    return '''
Current: [${currentTabs.asMap().entries.map((e) => '${e.value.name}[${e.key}]').join(', ')}]
Dragging: ${draggingTab?.name} (original index: $originalIndex)
Target Index: ${targetIndex ?? 'null'} (${targetIndex != null ? 'Target Tab: $targetTabInfo' : 'Outside drop zones'})
Place Index: $placeIndexInfo
Expected: [${expectedResult.asMap().entries.map((e) => '${e.value.name}[${e.key}]').join(', ')}]
''';
  }

  TabDragState copyWith({
    List<TabInfo>? currentTabs,
    String? draggingTabId,
    int? targetIndex,
    List<TabInfo>? expectedResult,
    Offset? dragPosition,
  }) {
    return TabDragState(
      currentTabs: currentTabs ?? this.currentTabs,
      draggingTabId: draggingTabId ?? this.draggingTabId,
      targetIndex: targetIndex ?? this.targetIndex,
      expectedResult: expectedResult ?? this.expectedResult,
      dragPosition: dragPosition ?? this.dragPosition,
    );
  }
}
