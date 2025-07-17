import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/tab_info.dart';
import '../model/terminal_drag_data.dart';
import '../model/terminal_drag_state.dart'; // 🚀 정확한 파일명으로 변경
import 'tab_list_provider.dart';

part 'terminal_drag_provider.g.dart';

@Riverpod(dependencies: [TabList])
class TerminalDrag extends _$TerminalDrag {
  @override
  TerminalDragState build() {
    return TerminalDragState.initial;
  }

  /// 🚀 드래그 시작 (통합 버전) - 탭에서 드래그
  void startTabDrag(String tabId) {
    final tabList = ref.read(tabListProvider);

    // 🚀 드래그 가능한 탭들만 필터링 (List 기반)
    final draggableTabs = tabList.where((tab) => tab.isClosable).toList();

    // 드래그 중인 탭이 존재하는지 확인
    final draggingTab =
        draggableTabs.where((tab) => tab.id == tabId).firstOrNull;
    if (draggingTab == null) {
      print('❌ Tab not found for drag: $tabId');
      return;
    }

    print(
        '🚀 Start tab drag: ${draggingTab.name} (index ${draggableTabs.indexOf(draggingTab)})');

    // 🚀 TerminalDragData 생성 (탭에서 시작)
    final dragData = TerminalDragData(
      terminalId: tabId,
      displayName: draggingTab.name,
      source: DragSource.tab,
    );

    state = state.startDrag(
      tabs: draggableTabs,
      dragData: dragData,
    );
  }

  /// 🆕 패널에서 드래그 시작 (추후 구현용)
  void startPanelDrag(String terminalId, String displayName) {
    final tabList = ref.read(tabListProvider);
    final draggableTabs = tabList.where((tab) => tab.isClosable).toList();

    print('🚀 Start panel drag: $displayName ($terminalId)');

    // 🚀 TerminalDragData 생성 (패널에서 시작)
    final dragData = TerminalDragData(
      terminalId: terminalId,
      displayName: displayName,
      source: DragSource.panel,
    );

    state = state.startDrag(
      tabs: draggableTabs,
      dragData: dragData,
    );
  }

  /// 🚀 타겟 index 업데이트 - 동일
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

  /// 🚀 드래그 종료 (실제 순서 변경) - source 체크 추가
  void endDrag() {
    if (!state.isDragging) {
      print('❌ Cannot end drag: not dragging');
      return;
    }

    final draggingData = state.draggingData!;
    final targetIndex = state.targetIndex;
    final draggingIndex = state.draggingIndex;

    print('✅ End drag: ${draggingData.debugInfo}');

    // expectedResult의 순서 표시 (디버그용)
    final expectedOrder = state.expectedResult
        .asMap()
        .entries
        .map((e) => '${e.value.name}[${e.key}]')
        .join(', ');
    print('📋 Expected result: $expectedOrder');

    // 🚀 source에 따른 처리 분기
    switch (draggingData.source) {
      case DragSource.tab:
        _handleTabDragEnd(draggingData, targetIndex, draggingIndex);
        break;
      case DragSource.panel:
        _handlePanelDragEnd(draggingData, targetIndex);
        break;
    }

    // 드래그 상태 초기화
    state = state.endDrag();
  }

  /// 탭 드래그 종료 처리
  void _handleTabDragEnd(
      TerminalDragData dragData, int? targetIndex, int? draggingIndex) {
    // 실제 순서 변경 적용 (기존 로직과 동일)
    if (targetIndex != null &&
        draggingIndex != null &&
        targetIndex != draggingIndex) {
      print('🔄 Applying tab index change...');
      _applyTabIndexChange(dragData.terminalId, draggingIndex, targetIndex);
    } else {
      print('📌 No tab index change needed');
    }
  }

  /// 패널 드래그 종료 처리 (추후 구현)
  void _handlePanelDragEnd(TerminalDragData dragData, int? targetIndex) {
    print('🔄 Panel drag ended: ${dragData.debugInfo}');
    // TODO: 패널 드래그 처리 로직 추가 (Phase 3-5에서 구현)
  }

  /// 드래그 취소
  void cancelDrag() {
    if (!state.isDragging) return;

    print('❌ Cancel drag: ${state.draggingData?.debugInfo}');
    state = state.endDrag();
  }

  /// 🚀 실제 탭 순서 변경 적용 (기존과 동일)
  void _applyTabIndexChange(String draggingTabId, int fromIndex, int toIndex) {
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
