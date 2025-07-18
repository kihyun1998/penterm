import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';
import 'package:penterm/feature/terminal/model/terminal_drag_data.dart';
import 'package:penterm/feature/terminal/provider/terminal_drag_provider.dart';
import 'package:penterm/feature/terminal/ui/split_drop_zone.dart'; // 기존 SplitDropZone 재사용

/// 터미널 분할 처리 위젯 (드롭존 + 전체 화면 미리보기)
class TerminalSplitHandler extends ConsumerStatefulWidget {
  final TerminalDragData currentTab;

  const TerminalSplitHandler({super.key, required this.currentTab});

  @override
  ConsumerState<TerminalSplitHandler> createState() =>
      _TerminalSplitHandlerState();
}

class _TerminalSplitHandlerState extends ConsumerState<TerminalSplitHandler> {
  SplitDirection? _hoveredDirection;

  /// hover 상태 변경 처리
  void _onHoverChanged(SplitDirection? direction) {
    if (_hoveredDirection != direction) {
      setState(() {
        _hoveredDirection = direction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 10개 드롭존 배치
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              children: [
                // ============ 큰 분할 (4개) ============

                // 🔴 Left - 왼쪽 1/3 전체 높이
                Positioned(
                  left: 0,
                  top: 0,
                  width: width / 3,
                  height: height,
                  child: SplitDropZone(
                    direction: SplitDirection.left,
                    currentTab: widget.currentTab,
                    onHoverChanged: _onHoverChanged,
                  ),
                ),

                // 🟡 Right - 오른쪽 1/3 전체 높이
                Positioned(
                  left: width * 2 / 3,
                  top: 0,
                  width: width / 3,
                  height: height,
                  child: SplitDropZone(
                    direction: SplitDirection.right,
                    currentTab: widget.currentTab,
                    onHoverChanged: _onHoverChanged,
                  ),
                ),

                // 🟢 Top - 상단 1/3, 중앙 1/3 너비
                Positioned(
                  left: width / 3,
                  top: 0,
                  width: width / 3,
                  height: height / 3,
                  child: SplitDropZone(
                    direction: SplitDirection.top,
                    currentTab: widget.currentTab,
                    onHoverChanged: _onHoverChanged,
                  ),
                ),

                // 🔵 Bottom - 하단 1/3, 중앙 1/3 너비
                Positioned(
                  left: width / 3,
                  top: height * 2 / 3,
                  width: width / 3,
                  height: height / 3,
                  child: SplitDropZone(
                    direction: SplitDirection.bottom,
                    currentTab: widget.currentTab,
                    onHoverChanged: _onHoverChanged,
                  ),
                ),

                // ============ 작은 분할 (4개) - 중앙 영역의 모서리 ============

                // 🔴 Left-Small - 중앙 영역의 왼쪽 1/3
                Positioned(
                  left: width / 3,
                  top: height / 3,
                  width: width / 9,
                  height: height / 3,
                  child: SplitDropZone(
                    direction: SplitDirection.leftSmall,
                    currentTab: widget.currentTab,
                    onHoverChanged: _onHoverChanged,
                  ),
                ),

                // 🟡 Right-Small - 중앙 영역의 오른쪽 1/3
                Positioned(
                  left: width * 5 / 9,
                  top: height / 3,
                  width: width / 9,
                  height: height / 3,
                  child: SplitDropZone(
                    direction: SplitDirection.rightSmall,
                    currentTab: widget.currentTab,
                    onHoverChanged: _onHoverChanged,
                  ),
                ),

                // 🟢 Top-Small - 중앙 영역의 상단 1/3
                Positioned(
                  left: width * 4 / 9,
                  top: height / 3,
                  width: width / 9,
                  height: height / 9,
                  child: SplitDropZone(
                    direction: SplitDirection.topSmall,
                    currentTab: widget.currentTab,
                    onHoverChanged: _onHoverChanged,
                  ),
                ),

                // 🔵 Bottom-Small - 중앙 영역의 하단 1/3
                Positioned(
                  left: width * 4 / 9,
                  top: height * 5 / 9,
                  width: width / 9,
                  height: height / 9,
                  child: SplitDropZone(
                    direction: SplitDirection.bottomSmall,
                    currentTab: widget.currentTab,
                    onHoverChanged: _onHoverChanged,
                  ),
                ),

                // ============ 중앙 분할 (2개) - 중앙의 중앙 ============

                // 🟢 Top-Center - 중앙의 상 50%
                Positioned(
                  left: width * 4 / 9,
                  top: height * 4 / 9,
                  width: width / 9,
                  height: height / 18,
                  child: SplitDropZone(
                    direction: SplitDirection.topCenter,
                    currentTab: widget.currentTab,
                    onHoverChanged: _onHoverChanged,
                  ),
                ),

                // 🔵 Bottom-Center - 중앙의 하 50%
                Positioned(
                  left: width * 4 / 9,
                  top: height * 4 / 9 + height / 18,
                  width: width / 9,
                  height: height / 18,
                  child: SplitDropZone(
                    direction: SplitDirection.bottomCenter,
                    currentTab: widget.currentTab,
                    onHoverChanged: _onHoverChanged,
                  ),
                ),
              ],
            );
          },
        ),

        // 전체 화면 분할 미리보기 오버레이 (마우스 이벤트 무시)
        if (_hoveredDirection != null)
          IgnorePointer(
            child: _buildFullScreenPreview(_hoveredDirection!),
          ),
      ],
    );
  }

  /// 전체 화면 분할 미리보기
  Widget _buildFullScreenPreview(SplitDirection direction) {
    final dragState = ref.watch(terminalDragProvider);
    final draggingData = dragState.draggingData;

    if (draggingData == null) return const SizedBox.shrink();

    // 방향에 따라 새로운 터미널이 들어올 영역에만 오버레이 표시
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: [
            // 방향별로 해당 영역에만 오버레이 표시
            _buildDirectionOverlay(direction, width, height, draggingData),
          ],
        );
      },
    );
  }

  /// 방향별 오버레이 생성
  Widget _buildDirectionOverlay(SplitDirection direction, double width,
      double height, TerminalDragData draggingData) {
    switch (direction) {
      case SplitDirection.left:
      case SplitDirection.leftSmall:
        // 왼쪽 50%에만 오버레이
        return Positioned(
          left: 0,
          top: 0,
          width: width * 0.5,
          height: height,
          child: _buildNewTerminalOverlay(draggingData, direction),
        );

      case SplitDirection.right:
      case SplitDirection.rightSmall:
        // 오른쪽 50%에만 오버레이
        return Positioned(
          right: 0,
          top: 0,
          width: width * 0.5,
          height: height,
          child: _buildNewTerminalOverlay(draggingData, direction),
        );

      case SplitDirection.top:
      case SplitDirection.topSmall:
      case SplitDirection.topCenter:
        // 위쪽 50%에만 오버레이
        return Positioned(
          left: 0,
          top: 0,
          width: width,
          height: height * 0.5,
          child: _buildNewTerminalOverlay(draggingData, direction),
        );

      case SplitDirection.bottom:
      case SplitDirection.bottomSmall:
      case SplitDirection.bottomCenter:
        // 아래쪽 50%에만 오버레이
        return Positioned(
          left: 0,
          bottom: 0,
          width: width,
          height: height * 0.5,
          child: _buildNewTerminalOverlay(draggingData, direction),
        );
    }
  }

  /// 새로운 터미널 영역 오버레이
  Widget _buildNewTerminalOverlay(
      TerminalDragData draggingData, SplitDirection direction) {
    return Container(
      decoration: BoxDecoration(
        color: ref.theme.color.surface.withOpacity(0.9), // 어두운 오버레이
        border: Border.all(
          color: _getDirectionColor(direction),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.terminal,
              size: 48,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 12),
            Text(
              draggingData.displayName,
              style: ref.font.semiBoldText18.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getDirectionColor(direction).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getDirectionColor(direction),
                  width: 1,
                ),
              ),
              child: Text(
                'Will be placed here',
                style: ref.font.regularText12.copyWith(
                  color: _getDirectionColor(direction),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 방향별 색상
  Color _getDirectionColor(SplitDirection direction) {
    switch (direction) {
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
}
