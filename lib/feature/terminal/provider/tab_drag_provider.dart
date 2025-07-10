import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/tab_drag_state.dart';
import 'tab_list_provider.dart';

part 'tab_drag_provider.g.dart';

@riverpod
class TabDrag extends _$TabDrag {
  @override
  TabDragState build() {
    return TabDragState.initial;
  }

  /// 드래그 시작
  void startDrag(String tabId) {
    state = state.copyWith(draggingTabId: tabId);
  }

  /// 드래그 위치 업데이트
  void updateDragPosition(Offset position) {
    if (!state.isDragging) return;

    state = state.copyWith(dragPosition: position);
  }

  /// 드래그 타겟 인덱스 업데이트
  void updateTargetIndex(int? targetIndex) {
    if (!state.isDragging) return;

    state = state.copyWith(targetIndex: targetIndex);
  }

  /// 드래그 종료 (성공적으로 드롭)
  void endDrag() {
    if (!state.isDragging) return;

    final draggingTabId = state.draggingTabId!;
    final targetIndex = state.targetIndex;

    // 드래그 상태 초기화
    state = state.clearDrag();

    // 실제 탭 순서 변경 (targetIndex가 있는 경우만)
    if (targetIndex != null) {
      ref.read(tabListProvider.notifier).reorderTab(draggingTabId, targetIndex);
    }
  }

  /// 드래그 취소
  void cancelDrag() {
    state = state.clearDrag();
  }

  /// 마우스 위치로부터 타겟 인덱스 계산
  int? calculateTargetIndex(Offset globalPosition, List<GlobalKey> tabKeys) {
    if (!state.isDragging) return null;

    // 각 탭의 글로벌 위치를 확인하여 드래그 위치와 비교
    for (int i = 0; i < tabKeys.length; i++) {
      final key = tabKeys[i];
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null) {
        final tabPosition = renderBox.localToGlobal(Offset.zero);
        final tabSize = renderBox.size;

        // 드래그 위치가 탭의 왼쪽 절반에 있으면 해당 인덱스
        // 오른쪽 절반에 있으면 다음 인덱스
        if (globalPosition.dx >= tabPosition.dx &&
            globalPosition.dx <= tabPosition.dx + tabSize.width) {
          final isLeftHalf =
              globalPosition.dx < tabPosition.dx + (tabSize.width / 2);
          return isLeftHalf ? i : i + 1;
        }
      }
    }

    return null;
  }
}
