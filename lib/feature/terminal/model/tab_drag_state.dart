// import 'package:flutter/material.dart';

// /// 탭 드래그 상태를 관리하는 모델
// class TabDragState {
//   /// 현재 드래그 중인 탭 ID
//   final String? draggingTabId;

//   /// 드래그 중인 탭이 들어갈 예상 인덱스
//   final int? targetIndex;

//   /// 드래그 중인 마우스 위치
//   final Offset? dragPosition;

//   /// 드래그가 활성화된 상태인지
//   bool get isDragging => draggingTabId != null;

//   const TabDragState({
//     this.draggingTabId,
//     this.targetIndex,
//     this.dragPosition,
//   });

//   /// 초기 상태 (드래그 없음)
//   static const TabDragState initial = TabDragState();

//   TabDragState copyWith({
//     String? draggingTabId,
//     int? targetIndex,
//     Offset? dragPosition,
//   }) {
//     return TabDragState(
//       draggingTabId: draggingTabId ?? this.draggingTabId,
//       targetIndex: targetIndex ?? this.targetIndex,
//       dragPosition: dragPosition ?? this.dragPosition,
//     );
//   }

//   /// 드래그 초기화 (드래그 종료)
//   TabDragState clearDrag() {
//     return const TabDragState();
//   }
// }
