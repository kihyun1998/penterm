// import 'package:flutter/material.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../model/tab_drag_state.dart';
// import '../model/tab_info.dart';
// import 'tab_list_provider.dart';

// part 'tab_drag_provider.g.dart';

// @Riverpod(dependencies: [TabList])
// class TabDrag extends _$TabDrag {
//   @override
//   TabDragState build() {
//     return TabDragState.initial;
//   }

//   /// 드래그 시작
//   void startDrag(String tabId) {
//     state = state.copyWith(draggingTabId: tabId);
//   }

//   /// 드래그 위치 업데이트
//   void updateDragPosition(Offset position) {
//     if (!state.isDragging) return;

//     state = state.copyWith(dragPosition: position);
//   }

//   /// 드래그 타겟 인덱스 업데이트
//   void updateTargetIndex(int? targetIndex) {
//     if (!state.isDragging) return;

//     state = state.copyWith(targetIndex: targetIndex);
//   }

//   /// 드래그 종료 (성공적으로 드롭)
//   void endDrag() {
//     if (!state.isDragging) return;

//     final draggingTabId = state.draggingTabId!;
//     final targetIndex = state.targetIndex;

//     // 실제 탭 순서 변경 (targetIndex가 있는 경우만)
//     if (targetIndex != null) {
//       ref.read(tabListProvider.notifier).reorderTab(draggingTabId, targetIndex);
//     }

//     // 드래그 상태 초기화 (순서 변경 후)
//     state = state.clearDrag();
//   }

//   /// 드래그 취소
//   void cancelDrag() {
//     state = state.clearDrag();
//   }

//   /// 드래그 중 실시간 업데이트 (마우스 이동할 때마다 호출)
//   /// Map을 받아서 내부에서 List로 변환하여 처리
//   void onDragMove(
//     Offset globalPosition,
//     Map<String, TabInfo> tabMap,
//     Map<String, GlobalKey> tabKeys,
//   ) {
//     if (!state.isDragging) return;

//     // Map을 List로 변환 (순서대로 정렬)
//     final allTabs = tabMap.values.toList();
//     allTabs.sort((a, b) => a.order.compareTo(b.order));

//     final newTargetIndex =
//         calculateTargetIndex(globalPosition, allTabs, tabKeys);

//     // 타겟 인덱스가 변경되었을 때만 업데이트
//     if (newTargetIndex != state.targetIndex) {
//       state = state.copyWith(
//         dragPosition: globalPosition,
//         targetIndex: newTargetIndex,
//       );
//     } else {
//       // 타겟 인덱스는 같지만 마우스 위치는 업데이트
//       state = state.copyWith(dragPosition: globalPosition);
//     }
//   }

//   /// 마우스 위치로부터 타겟 인덱스 계산 (전체 탭 리스트 기준)
//   int? calculateTargetIndex(
//     Offset globalPosition,
//     List<TabInfo> allTabs,
//     Map<String, GlobalKey> tabKeys,
//   ) {
//     if (!state.isDragging) return null;

//     final draggableTabs = allTabs.where((tab) => tab.isClosable).toList();
//     final fixedTabCount = allTabs.where((tab) => !tab.isClosable).length;

//     // 드래그 가능한 탭들의 위치 확인
//     for (int i = 0; i < draggableTabs.length; i++) {
//       final tab = draggableTabs[i];
//       final key = tabKeys[tab.id];
//       final renderBox = key?.currentContext?.findRenderObject() as RenderBox?;

//       if (renderBox != null) {
//         final tabPosition = renderBox.localToGlobal(Offset.zero);
//         final tabSize = renderBox.size;

//         // 마우스가 이 탭 영역 위에 있는지 확인
//         if (globalPosition.dx >= tabPosition.dx &&
//             globalPosition.dx <= tabPosition.dx + tabSize.width) {
//           // 전체 탭 리스트에서의 실제 인덱스 반환
//           return fixedTabCount + i;
//         }
//       }
//     }

//     return null;
//   }
// }
