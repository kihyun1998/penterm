import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

import '../model/tab_info.dart';

enum SplitDirection {
  top,
  bottom,
  left,
  right,
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
        return Colors.green;
      case SplitDirection.bottom:
        return Colors.blue;
      case SplitDirection.left:
        return Colors.red;
      case SplitDirection.right:
        return Colors.orange;
    }
  }

  /// 방향별 아이콘
  IconData _getDirectionIcon() {
    switch (widget.direction) {
      case SplitDirection.top:
        return Icons.vertical_align_top;
      case SplitDirection.bottom:
        return Icons.vertical_align_bottom;
      case SplitDirection.left:
        return Icons.align_horizontal_left;
      case SplitDirection.right:
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
    }
  }

  /// 콘솔 로그 출력
  void _logSplitDetection() {
    final emoji = {
      SplitDirection.top: '🟢',
      SplitDirection.bottom: '🔵',
      SplitDirection.left: '🔴',
      SplitDirection.right: '🟡',
    }[widget.direction];

    print(
        '$emoji ${_getDirectionText()} split zone detected for ${widget.currentTab.name}');
  }
}
