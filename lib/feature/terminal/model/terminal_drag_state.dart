import 'package:flutter/material.dart';

import 'tab_info.dart';
import 'terminal_drag_data.dart';

/// 터미널 드래그 상태를 관리하는 모델 (통합 버전)
class TerminalDragState {
  /// 현재 드래그 가능한 탭들 (List 순서 그대로)
  final List<TabInfo> currentTabs;

  /// 🚀 통합된 드래그 데이터 (탭 또는 패널에서 시작됨)
  final TerminalDragData? draggingData;

  /// 드롭 타겟 index (드롭될 위치의 index)
  final int? targetIndex;

  /// 예상 결과 순서 (드롭했을 때의 새로운 탭 리스트)
  final List<TabInfo> expectedResult;

  /// 드래그 중인 마우스 위치 (디버그용)
  final Offset? dragPosition;

  /// 드래그가 활성화된 상태인지
  bool get isDragging => draggingData != null;

  /// 드래그 중인 터미널 ID (source 무관)
  String? get draggingTerminalId =>
      isDragging ? draggingData!.terminalId : null;

  /// 드래그 중인 탭 정보 (탭에서 드래그된 경우만)
  TabInfo? get draggingTab => isDragging && draggingData!.isFromTab
      ? currentTabs.firstWhere((tab) => tab.id == draggingData!.terminalId,
          orElse: () => throw StateError('Dragging tab not found'))
      : null;

  /// 타겟 위치의 탭 정보 (드롭될 위치의 기존 탭)
  TabInfo? get targetTab =>
      targetIndex != null && targetIndex! < currentTabs.length
          ? currentTabs[targetIndex!]
          : null;

  const TerminalDragState({
    this.currentTabs = const [],
    this.draggingData,
    this.targetIndex,
    this.expectedResult = const [],
    this.dragPosition,
  });

  /// 초기 상태 (드래그 없음)
  static const TerminalDragState initial = TerminalDragState();

  /// 🚀 드래그 시작 (통합 버전)
  TerminalDragState startDrag({
    required List<TabInfo> tabs,
    required TerminalDragData dragData,
  }) {
    return TerminalDragState(
      currentTabs: tabs,
      draggingData: dragData,
      targetIndex: null,
      expectedResult: tabs, // 초기에는 현재 순서와 동일
      dragPosition: null,
    );
  }

  /// 타겟 index 업데이트 및 예상 결과 계산
  TerminalDragState updateTarget({
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
      draggingTerminalId: draggingData!.terminalId,
      targetIndex: newTargetIndex,
    );

    return TerminalDragState(
      currentTabs: currentTabs,
      draggingData: draggingData,
      targetIndex: newTargetIndex,
      expectedResult: newExpectedResult,
      dragPosition: newDragPosition ?? dragPosition,
    );
  }

  /// 드래그 위치만 업데이트 (타겟 index는 유지)
  TerminalDragState updatePosition(Offset newPosition) {
    if (!isDragging) return this;

    return TerminalDragState(
      currentTabs: currentTabs,
      draggingData: draggingData,
      targetIndex: targetIndex,
      expectedResult: expectedResult,
      dragPosition: newPosition,
    );
  }

  /// 드래그 종료
  TerminalDragState endDrag() {
    return const TerminalDragState();
  }

  /// 🚀 예상 결과 계산 로직 (터미널 ID 기반)
  static List<TabInfo> _calculateExpectedResult({
    required List<TabInfo> currentTabs,
    required String draggingTerminalId,
    required int targetIndex,
  }) {
    // 드래그 중인 탭의 현재 index 찾기
    final currentDraggingIndex =
        currentTabs.indexWhere((tab) => tab.id == draggingTerminalId);
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

  /// 드래그 중인 탭의 현재 index (탭에서 드래그된 경우만)
  int? get draggingIndex => isDragging && draggingData!.isFromTab
      ? currentTabs.indexWhere((tab) => tab.id == draggingData!.terminalId)
      : null;

  /// 🚀 디버그 정보를 위한 문자열 표현 (source 포함)
  String get debugInfo {
    if (!isDragging) return 'No drag in progress';

    final sourceInfo = draggingData!.source.name.toUpperCase();
    final originalIndex = draggingIndex;

    // 타겟 탭 정보
    final targetTabInfo =
        targetTab != null ? '${targetTab!.name}[$targetIndex]' : 'None';

    // Place Index 계산
    String placeIndexInfo;
    if (targetIndex == null) {
      placeIndexInfo = '${originalIndex ?? 'unknown'} (original position)';
    } else if (targetIndex == originalIndex) {
      placeIndexInfo = '$targetIndex (same as original - no change)';
    } else {
      placeIndexInfo = '$targetIndex (new position)';
    }

    return '''
Source: $sourceInfo (${draggingData!.debugInfo})
Current: [${currentTabs.asMap().entries.map((e) => '${e.value.name}[${e.key}]').join(', ')}]
Dragging: ${draggingData!.displayName} (original index: $originalIndex)
Target Index: ${targetIndex ?? 'null'} (${targetIndex != null ? 'Target Tab: $targetTabInfo' : 'Outside drop zones'})
Place Index: $placeIndexInfo
Expected: [${expectedResult.asMap().entries.map((e) => '${e.value.name}[${e.key}]').join(', ')}]
''';
  }

  TerminalDragState copyWith({
    List<TabInfo>? currentTabs,
    TerminalDragData? draggingData,
    int? targetIndex,
    List<TabInfo>? expectedResult,
    Offset? dragPosition,
  }) {
    return TerminalDragState(
      currentTabs: currentTabs ?? this.currentTabs,
      draggingData: draggingData ?? this.draggingData,
      targetIndex: targetIndex ?? this.targetIndex,
      expectedResult: expectedResult ?? this.expectedResult,
      dragPosition: dragPosition ?? this.dragPosition,
    );
  }
}
