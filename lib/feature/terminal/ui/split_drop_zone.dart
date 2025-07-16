import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

import '../model/tab_info.dart';

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
  final TabInfo currentTab;

  const SplitDropZone({
    super.key,
    required this.direction,
    required this.currentTab,
  });

  @override
  ConsumerState<SplitDropZone> createState() => _SplitDropZoneState();
}

class _SplitDropZoneState extends ConsumerState<SplitDropZone> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<TabInfo>(
      onWillAcceptWithDetails: (data) {
        // 터미널 탭만 허용하고, 자기 자신은 제외
        return data.data.type.value == 'terminal' &&
            data.data.id != widget.currentTab.id;
      },
      onMove: (details) {
        if (!_isHovered) {
          setState(() => _isHovered = true);
          _logSplitDetection();
        }
      },
      onLeave: (data) {
        setState(() => _isHovered = false);
      },
      onAcceptWithDetails: (draggedTab) {
        // 1단계에서는 실제 분할 처리하지 않음
        print(
            '🎯 Split drop accepted: ${draggedTab.data.name} → ${widget.direction.name}');
        setState(() => _isHovered = false);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: _isHovered
                ? _getDirectionColor().withOpacity(0.3)
                : Colors.transparent,
            border: _isHovered
                ? Border.all(
                    color: _getDirectionColor(),
                    width: 2,
                  )
                : Border.all(
                    color: Colors.white.withOpacity(0.2), // 영역 구분용 경계선
                    width: 1,
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
                        size: 32,
                        color: _getDirectionColor(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_getDirectionText()} Split',
                        style: ref.font.semiBoldText14.copyWith(
                          color: _getDirectionColor(),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    _getDirectionText(),
                    style: ref.font.regularText12.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
        );
      },
    );
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
        '$emoji ${_getDirectionText()} split zone detected for ${widget.currentTab.name}');
  }
}
