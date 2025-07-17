import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

import '../../../feature/terminal/model/terminal_drag_data.dart'; // 🚀 변경
import '../../../feature/terminal/provider/terminal_drag_provider.dart'; // 🚀 변경

class TabDropZone extends ConsumerStatefulWidget {
  /// 🚀 이 드롭 영역이 대표하는 탭의 index
  final int targetIndex;

  /// 이 드롭 영역이 대표하는 탭의 이름 (디버그용)
  final String targetTabName;

  /// 드롭 영역의 크기 (터미널 탭과 동일하게)
  final double width;
  final double height;

  const TabDropZone({
    super.key,
    required this.targetIndex,
    required this.targetTabName,
    this.width = 140.0,
    this.height = 38,
  });

  @override
  ConsumerState<TabDropZone> createState() => _TabDropZoneState();
}

class _TabDropZoneState extends ConsumerState<TabDropZone> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final dragState = ref.watch(terminalDragProvider); // 🚀 변경

    // 드래그 중이 아니면 빈 공간만 차지
    if (!dragState.isDragging) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
      );
    }

    // 🚀 현재 이 영역이 타겟인지 확인 (index 기반)
    final isTarget = dragState.targetIndex == widget.targetIndex;

    return DragTarget<TerminalDragData>(
      // 🚀 변경
      onWillAcceptWithDetails: (data) {
        // 🚀 탭에서 드래그된 데이터만 허용
        final isFromTab = data.data.isFromTab;
        final isValidTerminal =
            dragState.currentTabs.any((tab) => tab.id == data.data.terminalId);

        return isFromTab && isValidTerminal;
      },
      onMove: (details) {
        // 마우스가 이 영역 위에 있을 때 타겟으로 설정
        if (!_isHovered) {
          setState(() => _isHovered = true);

          ref.read(terminalDragProvider.notifier).updateTarget(
                // 🚀 변경
                widget.targetIndex,
                dragPosition: details.offset,
              );
        }
      },
      onLeave: (data) {
        // 마우스가 이 영역을 벗어날 때
        setState(() => _isHovered = false);
      },
      onAcceptWithDetails: (draggedData) {
        // 🚀 변경
        // 실제 드롭이 발생했을 때 - 이제 실제 이동 수행
        final draggedIndex = dragState.currentTabs
            .indexWhere((tab) => tab.id == draggedData.data.terminalId);

        if (draggedIndex == widget.targetIndex) {
          print(
              '🔄 Dropped on self: ${widget.targetTabName} (return to original position)');
          print('📋 No change needed - same position');
        } else {
          print(
              '🎯 Dropped on zone: ${widget.targetTabName} (index ${widget.targetIndex})');
          print(
              '📋 Moving ${draggedData.data.displayName} from index $draggedIndex to index ${widget.targetIndex}');
        }

        // 실제 이동 수행
        ref.read(terminalDragProvider.notifier).endDrag(); // 🚀 변경
        setState(() => _isHovered = false);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
          decoration: BoxDecoration(
            // 호버 또는 타겟 상태일 때 테마 색상으로 표시
            color: (_isHovered || isTarget)
                ? ref.color.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            border: (_isHovered || isTarget)
                ? Border.all(
                    color: ref.color.primary.withOpacity(0.5),
                    width: 2,
                  )
                : null,
            // Violet glow 효과
            boxShadow: (_isHovered || isTarget)
                ? [
                    BoxShadow(
                      color: ref.color.neonPurple.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: (_isHovered || isTarget)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_downward,
                        size: 12,
                        color: ref.color.primary.withOpacity(0.7),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Drop here',
                        style: ref.font.regularText10.copyWith(
                          color: ref.color.primary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}
