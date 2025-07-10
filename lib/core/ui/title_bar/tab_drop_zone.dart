import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

import '../../../feature/terminal/model/tab_info.dart';
import '../../../feature/terminal/provider/tab_drag_provider.dart';

class TabDropZone extends ConsumerStatefulWidget {
  /// 이 드롭 영역이 대표하는 탭의 order
  final int targetOrder;

  /// 이 드롭 영역이 대표하는 탭의 이름 (디버그용)
  final String targetTabName;

  /// 드롭 영역의 크기 (탭과 동일하게)
  final double width;
  final double height;

  const TabDropZone({
    super.key,
    required this.targetOrder,
    required this.targetTabName,
    this.width = 120,
    this.height = 38,
  });

  @override
  ConsumerState<TabDropZone> createState() => _TabDropZoneState();
}

class _TabDropZoneState extends ConsumerState<TabDropZone> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final dragState = ref.watch(tabDragProvider);

    // 드래그 중이 아니면 빈 공간만 차지
    if (!dragState.isDragging) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
      );
    }

    // 현재 이 영역이 타겟인지 확인
    final isTarget = dragState.targetOrder == widget.targetOrder;

    return DragTarget<TabInfo>(
      onWillAcceptWithDetails: (data) {
        // 드래그 중인 탭이 유효한지 확인
        return dragState.currentTabs.containsKey(data.data.id);
      },
      onMove: (details) {
        // 마우스가 이 영역 위에 있을 때 타겟으로 설정
        if (!_isHovered) {
          setState(() => _isHovered = true);
          print(
              '🎯 Enter drop zone: ${widget.targetTabName} (order ${widget.targetOrder})');
          ref.read(tabDragProvider.notifier).updateTarget(
                widget.targetOrder,
                dragPosition: details.offset,
              );
        }
      },
      onLeave: (data) {
        // 마우스가 이 영역을 벗어날 때
        setState(() => _isHovered = false);
        print('❌ Leave drop zone: ${widget.targetTabName}');
        // 타겟을 null로 설정하지는 않음 (다른 영역으로 이동할 수 있음)
      },
      onAcceptWithDetails: (draggedTab) {
        // 실제 드롭이 발생했을 때 - 아직 실제 이동은 하지 않음
        if (draggedTab.data.order == widget.targetOrder) {
          print(
              '🔄 Dropped on self: ${widget.targetTabName} (return to original position)');
          print('📋 No change needed - same position');
        } else {
          print(
              '🎯 Dropped on zone: ${widget.targetTabName} (order ${widget.targetOrder})');
          print(
              '📋 This will move ${draggedTab.data.name} from order ${draggedTab.data.order} to order ${widget.targetOrder}');
        }

        // 실제 이동은 하지 않고 드래그만 종료
        ref
            .read(tabDragProvider.notifier)
            .cancelDrag(); // endDrag() 대신 cancelDrag()
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
