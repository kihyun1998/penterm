import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

import '../model/split_layout_state.dart';
import '../model/terminal_drag_data.dart'; // 🚀 변경
import '../provider/split_layout_provider.dart';
import '../provider/tab_provider.dart';
import '../provider/terminal_drag_provider.dart'; // 🚀 변경

enum SplitDirection {
  // 큰 분할 (4개)
  top,
  bottom,
  left,
  right,

  // 작은 분할 (4개) - 중앙 영역의 모서리
  topSmall,
  bottomSmall,
  leftSmall,
  rightSmall,

  // 중앙 분할 (2개) - 중앙의 중앙
  topCenter,
  bottomCenter,
}

class SplitDropZone extends ConsumerStatefulWidget {
  /// 분할 방향
  final SplitDirection direction;

  /// 현재 활성 터미널 탭 정보
  final TerminalDragData currentTab;

  /// hover 상태 변경 콜백
  final Function(SplitDirection? direction) onHoverChanged;

  const SplitDropZone({
    super.key,
    required this.direction,
    required this.currentTab,
    required this.onHoverChanged,
  });

  @override
  ConsumerState<SplitDropZone> createState() => _SplitDropZoneState();
}

class _SplitDropZoneState extends ConsumerState<SplitDropZone> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // 🆕 현재 활성 탭 ID 가져오기
    final currentActiveTabId = ref.watch(activeTabProvider);

    return DragTarget<TerminalDragData>(
      // 🚀 변경
      onWillAcceptWithDetails: (data) {
        // 🚀 탭에서 드래그된 터미널만 허용하고, 자기 자신(현재 활성 탭)은 제외
        final isFromTab = data.data.isFromTab;
        final isTerminalTab = data.data.terminalId != currentActiveTabId;

        print(
            '🔍 Will accept? FromTab: $isFromTab, NotSelf: $isTerminalTab (${data.data.terminalId} != $currentActiveTabId)');

        return isFromTab && isTerminalTab;
      },
      onMove: (details) {
        // 🆕 허용되지 않는 드래그라면 hover 이벤트도 차단
        final currentActiveTabId = ref.read(activeTabProvider);
        final isFromTab = details.data.isFromTab;
        final isTerminalTab = details.data.terminalId != currentActiveTabId;

        if (!isFromTab || !isTerminalTab) {
          print(
              '🚫 Hover blocked: FromTab: $isFromTab, NotSelf: $isTerminalTab');
          return; // hover 이벤트 차단
        }

        if (!_isHovered) {
          setState(() => _isHovered = true);
          widget.onHoverChanged(widget.direction); // 상위에 hover 상태 알림
          _logSplitDetection();
        }
      },
      onLeave: (data) {
        if (_isHovered) {
          setState(() => _isHovered = false);
          widget.onHoverChanged(null); // hover 해제 알림
        }
      },
      onAcceptWithDetails: (draggedData) {
        // 🚀 변경
        // 🆕 실제 분할 실행
        _executeSplit(draggedData.data);

        // 🚨 드래그 상태 즉시 종료!
        ref.read(terminalDragProvider.notifier).endDrag(); // 🚀 변경

        setState(() => _isHovered = false);
        widget.onHoverChanged(null); // hover 해제
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: _isHovered
                ? _getDirectionColor().withOpacity(0.1)
                : Colors.transparent,
            border: _isHovered
                ? Border.all(
                    color: _getDirectionColor(),
                    width: 1,
                  )
                : Border.all(
                    color: Colors.white.withOpacity(0.1), // 영역 구분용 경계선
                    width: 0.5,
                  ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: _isHovered
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getDirectionIcon(),
                        size: 16,
                        color: _getDirectionColor(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDirectionText(),
                        style: ref.font.regularText10.copyWith(
                          color: _getDirectionColor(),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    _getDirectionText(),
                    style: ref.font.regularText10.copyWith(
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
        );
      },
    );
  }

  /// 🆕 실제 분할 실행
  void _executeSplit(TerminalDragData draggedData) {
    // 🚀 변경
    print(
        '🎯 Execute split: ${draggedData.displayName} → ${widget.direction.name}');

    // SplitDirection을 SplitType과 PanelPosition으로 변환
    final splitInfo = _convertToSplitInfo(widget.direction);

    print('  └─ SplitType: ${splitInfo.splitType.name}');
    print('  └─ TargetPosition: ${splitInfo.targetPosition.name}');

    // SplitLayoutProvider를 통해 실제 분할 실행
    ref.read(splitLayoutProvider.notifier).startSplit(
          terminalId: draggedData.terminalId, // 🚀 변경
          splitType: splitInfo.splitType,
          targetPosition: splitInfo.targetPosition,
        );

    print('✅ Split executed successfully');
  }

  /// 🆕 SplitDirection을 SplitType과 PanelPosition으로 변환
  _SplitInfo _convertToSplitInfo(SplitDirection direction) {
    switch (direction) {
      // 좌측 배치 -> 좌우 분할, 왼쪽 위치
      case SplitDirection.left:
      case SplitDirection.leftSmall:
        return const _SplitInfo(
          splitType: SplitType.horizontal,
          targetPosition: PanelPosition.left,
        );

      // 우측 배치 -> 좌우 분할, 오른쪽 위치
      case SplitDirection.right:
      case SplitDirection.rightSmall:
        return const _SplitInfo(
          splitType: SplitType.horizontal,
          targetPosition: PanelPosition.right,
        );

      // 상단 배치 -> 상하 분할, 위쪽 위치
      case SplitDirection.top:
      case SplitDirection.topSmall:
      case SplitDirection.topCenter:
        return const _SplitInfo(
          splitType: SplitType.vertical,
          targetPosition: PanelPosition.top,
        );

      // 하단 배치 -> 상하 분할, 아래쪽 위치
      case SplitDirection.bottom:
      case SplitDirection.bottomSmall:
      case SplitDirection.bottomCenter:
        return const _SplitInfo(
          splitType: SplitType.vertical,
          targetPosition: PanelPosition.bottom,
        );
    }
  }

  /// 방향별 색상
  Color _getDirectionColor() {
    switch (widget.direction) {
      case SplitDirection.top:
      case SplitDirection.topSmall:
      case SplitDirection.topCenter:
        return Colors.green;
      case SplitDirection.bottom:
      case SplitDirection.bottomSmall:
      case SplitDirection.bottomCenter:
        return Colors.blue;
      case SplitDirection.left:
      case SplitDirection.leftSmall:
        return Colors.red;
      case SplitDirection.right:
      case SplitDirection.rightSmall:
        return Colors.orange;
    }
  }

  /// 방향별 아이콘
  IconData _getDirectionIcon() {
    switch (widget.direction) {
      case SplitDirection.top:
      case SplitDirection.topSmall:
      case SplitDirection.topCenter:
        return Icons.vertical_align_top;
      case SplitDirection.bottom:
      case SplitDirection.bottomSmall:
      case SplitDirection.bottomCenter:
        return Icons.vertical_align_bottom;
      case SplitDirection.left:
      case SplitDirection.leftSmall:
        return Icons.align_horizontal_left;
      case SplitDirection.right:
      case SplitDirection.rightSmall:
        return Icons.align_horizontal_right;
    }
  }

  /// 방향별 텍스트
  String _getDirectionText() {
    switch (widget.direction) {
      case SplitDirection.top:
        return 'Top';
      case SplitDirection.bottom:
        return 'Bottom';
      case SplitDirection.left:
        return 'Left';
      case SplitDirection.right:
        return 'Right';
      case SplitDirection.topSmall:
        return 'Top-S';
      case SplitDirection.bottomSmall:
        return 'Bot-S';
      case SplitDirection.leftSmall:
        return 'Left-S';
      case SplitDirection.rightSmall:
        return 'Right-S';
      case SplitDirection.topCenter:
        return 'Top-C';
      case SplitDirection.bottomCenter:
        return 'Bot-C';
    }
  }

  /// 콘솔 로그 출력
  void _logSplitDetection() {
    final emoji = {
      SplitDirection.top: '🟢',
      SplitDirection.topSmall: '🟢',
      SplitDirection.topCenter: '🟢',
      SplitDirection.bottom: '🔵',
      SplitDirection.bottomSmall: '🔵',
      SplitDirection.bottomCenter: '🔵',
      SplitDirection.left: '🔴',
      SplitDirection.leftSmall: '🔴',
      SplitDirection.right: '🟡',
      SplitDirection.rightSmall: '🟡',
    }[widget.direction];

    print(
        '$emoji ${_getDirectionText()} split zone detected for ${widget.currentTab.displayName}');
  }
}

/// 🆕 SplitDirection 변환 정보를 담는 헬퍼 클래스
class _SplitInfo {
  final SplitType splitType;
  final PanelPosition targetPosition;

  const _SplitInfo({
    required this.splitType,
    required this.targetPosition,
  });
}
