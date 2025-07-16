import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

import '../core/ui/title_bar/app_title_bar.dart';
import '../feature/terminal/model/enum_tab_type.dart';
import '../feature/terminal/model/tab_info.dart';
import '../feature/terminal/provider/active_tabinfo_provider.dart';
import '../feature/terminal/provider/tab_drag_provider.dart';
import '../feature/terminal/ui/split_drop_zone.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTabInfo = ref.watch(activeTabInfoProvider);
    final dragState = ref.watch(tabDragProvider);
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // 커스텀 타이틀바
              const AppTitleBar(),

              // 메인 콘텐츠 - AnimatedSwitcher로 교체
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: activeTabInfo != null
                      ? _buildTabContent(activeTabInfo, ref)
                      : _buildDefaultContent(ref),
                ),
              ),
            ],
          ), // 🎯 드래그 상태 디버그 정보
          if (dragState.isDragging)
            Positioned(
              top: 60, // 타이틀바 아래쪽에 배치
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: ref.color.primary.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🐛 DRAG DEBUG',
                      style: ref.font.monoBoldText10.copyWith(
                        color: ref.color.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...dragState.debugInfo.split('\n').map((line) {
                      if (line.trim().isEmpty) return const SizedBox.shrink();

                      // 다른 색상으로 구분
                      Color textColor = Colors.white;
                      if (line.contains('Dragging:')) {
                        textColor = ref.color.neonPurple;
                      } else if (line.contains('Target Order:')) {
                        textColor = ref.color.neonGreen;
                      } else if (line.contains('Place Order:')) {
                        textColor = ref.color.neonBlue;
                      } else if (line.contains('Expected:')) {
                        textColor = ref.color.neonPink;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          line,
                          style: ref.font.monoRegularText10.copyWith(
                            color: textColor,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabContent(TabInfo tabInfo, WidgetRef ref) {
    switch (tabInfo.type) {
      case TabType.home:
        return Container(
          key: const ValueKey('home'),
          width: double.infinity,
          color: Colors.red,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.home,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'HOME TAB',
                  style: ref.font.boldText24.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );

      case TabType.sftp:
        return Container(
          key: const ValueKey('sftp'),
          width: double.infinity,
          color: Colors.blue,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.folder,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'SFTP TAB',
                  style: ref.font.boldText24.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );

      case TabType.terminal:
        return _buildTerminalContent(tabInfo, ref);
    }
  }

  Widget _buildTerminalContent(TabInfo tabInfo, WidgetRef ref) {
    final dragState = ref.watch(tabDragProvider);

    // 터미널 탭이 드래그 중인지 확인
    final isTerminalDragging =
        dragState.isDragging && dragState.draggingTab?.type.value == 'terminal';

    return Stack(
      key: ValueKey(tabInfo.id),
      children: [
        // 기본 터미널 컨텐츠
        Container(
          width: double.infinity,
          color: ref.theme.color.secondaryVariant,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.terminal,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  tabInfo.name,
                  style: ref.font.boldText24.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tab ID: ${tabInfo.id}',
                  style: ref.font.regularText14.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 10개 분할 드롭 영역들 (터미널 탭 드래그 중일 때만 표시)
        if (isTerminalDragging) _TerminalSplitHandler(tabInfo: tabInfo),
      ],
    );
  }

  Widget _buildDefaultContent(WidgetRef ref) {
    return Container(
      key: const ValueKey('default'),
      width: double.infinity,
      color: Colors.grey,
      child: Center(
        child: Text(
          'No Active Tab',
          style: ref.font.boldText24.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// 터미널 분할 처리 위젯 (드롭존 + 전체 화면 미리보기)
class _TerminalSplitHandler extends ConsumerStatefulWidget {
  final TabInfo tabInfo;

  const _TerminalSplitHandler({required this.tabInfo});

  @override
  ConsumerState<_TerminalSplitHandler> createState() =>
      _TerminalSplitHandlerState();
}

class _TerminalSplitHandlerState extends ConsumerState<_TerminalSplitHandler> {
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
                    currentTab: widget.tabInfo,
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
                    currentTab: widget.tabInfo,
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
                    currentTab: widget.tabInfo,
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
                    currentTab: widget.tabInfo,
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
                    currentTab: widget.tabInfo,
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
                    currentTab: widget.tabInfo,
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
                    currentTab: widget.tabInfo,
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
                    currentTab: widget.tabInfo,
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
                    currentTab: widget.tabInfo,
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
                    currentTab: widget.tabInfo,
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
    final dragState = ref.watch(tabDragProvider);
    final draggingTab = dragState.draggingTab;

    if (draggingTab == null) return const SizedBox.shrink();

    // 방향에 따라 새로운 터미널이 들어올 영역에만 오버레이 표시
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: [
            // 방향별로 해당 영역에만 오버레이 표시
            _buildDirectionOverlay(direction, width, height, draggingTab),
          ],
        );
      },
    );
  }

  /// 방향별 오버레이 생성
  Widget _buildDirectionOverlay(SplitDirection direction, double width,
      double height, TabInfo draggingTab) {
    switch (direction) {
      case SplitDirection.left:
      case SplitDirection.leftSmall:
        // 왼쪽 50%에만 오버레이
        return Positioned(
          left: 0,
          top: 0,
          width: width * 0.5,
          height: height,
          child: _buildNewTerminalOverlay(draggingTab, direction),
        );

      case SplitDirection.right:
      case SplitDirection.rightSmall:
        // 오른쪽 50%에만 오버레이
        return Positioned(
          right: 0,
          top: 0,
          width: width * 0.5,
          height: height,
          child: _buildNewTerminalOverlay(draggingTab, direction),
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
          child: _buildNewTerminalOverlay(draggingTab, direction),
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
          child: _buildNewTerminalOverlay(draggingTab, direction),
        );
    }
  }

  /// 새로운 터미널 영역 오버레이
  Widget _buildNewTerminalOverlay(
      TabInfo draggingTab, SplitDirection direction) {
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
              draggingTab.name,
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
