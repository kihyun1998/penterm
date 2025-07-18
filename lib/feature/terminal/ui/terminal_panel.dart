import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';
import 'package:penterm/feature/terminal/model/split_layout_state.dart';
import 'package:penterm/feature/terminal/model/terminal_drag_data.dart';
import 'package:penterm/feature/terminal/provider/terminal_drag_provider.dart';

/// 개별 패널 위젯
class TerminalPanel extends ConsumerWidget {
  final PanelInfo panel;

  const TerminalPanel({super.key, required this.panel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: panel.isActive ? ref.color.primary : ref.color.border,
            width: panel.isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(4),
        child: panel.hasTerminal
            ? _TerminalPanelContent(panel: panel)
            : _EmptyTerminalPanel(panel: panel),
      ),
    );
  }
}

/// 터미널이 있는 패널 (드래그 핸들 포함)
class _TerminalPanelContent extends ConsumerWidget {
  final PanelInfo panel;

  const _TerminalPanelContent({required this.panel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: ref.theme.color.secondaryVariant,
      child: Column(
        children: [
          // 패널 드래그 핸들
          _PanelDragHandle(panel: panel),

          // 터미널 컨텐츠
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.terminal,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Terminal: ${panel.terminalId}',
                    style: ref.font.semiBoldText18.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Panel: ${panel.position.name}',
                    style: ref.font.regularText14.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  if (panel.isActive)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: ref.color.primary..withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ref.color.primary, width: 1),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: ref.font.semiBoldText12.copyWith(
                          color: ref.color.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 패널 드래그 핸들
class _PanelDragHandle extends ConsumerWidget {
  final PanelInfo panel;

  const _PanelDragHandle({required this.panel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 터미널 정보 가져오기 (실제로는 탭 정보에서 이름을 찾아야 함)
    const terminalDisplayName = 'Terminal'; // 임시로 고정값, 나중에 실제 터미널 이름으로 변경

    return Draggable<TerminalDragData>(
      data: TerminalDragData(
        terminalId: panel.terminalId!,
        displayName: terminalDisplayName,
        source: DragSource.panel, // 패널에서 시작
      ),
      feedback: _PanelDragFeedback(panel: panel),
      childWhenDragging: _DragHandleUI(panel: panel, isDragging: true),
      onDragStarted: () {
        ref.read(terminalDragProvider.notifier).startPanelDrag(
              panel.terminalId!,
              terminalDisplayName,
            );
      },
      onDragUpdate: (details) {
        ref
            .read(terminalDragProvider.notifier)
            .updatePosition(details.globalPosition);
      },
      onDragEnd: (details) {
        ref.read(terminalDragProvider.notifier).endDrag();
      },
      onDraggableCanceled: (velocity, offset) {
        ref.read(terminalDragProvider.notifier).cancelDrag();
      },
      child: _DragHandleUI(panel: panel, isDragging: false),
    );
  }
}

/// 드래그 핸들 UI
class _DragHandleUI extends ConsumerWidget {
  final PanelInfo panel;
  final bool isDragging;

  const _DragHandleUI({required this.panel, required this.isDragging});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 28,
      width: double.infinity,
      decoration: BoxDecoration(
        color: panel.isActive
            ? ref.color.primary.withValues(alpha: isDragging ? 0.3 : 0.1)
            : ref.color.surface.withValues(alpha: isDragging ? 0.3 : 0.1),
        border: Border(
          bottom: BorderSide(
            color: panel.isActive ? ref.color.primary : ref.color.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          // 드래그 아이콘
          Icon(
            Icons.drag_indicator,
            size: 16,
            color:
                panel.isActive ? ref.color.primary : ref.color.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          // 터미널 정보
          Expanded(
            child: Text(
              'Terminal: ${panel.terminalId}',
              style: ref.font.semiBoldText12.copyWith(
                color: panel.isActive
                    ? ref.color.primary
                    : ref.color.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 패널 위치 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ref.color.surfaceVariant..withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              panel.position.name.toUpperCase(),
              style: ref.font.regularText10.copyWith(
                color: ref.color.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

/// 패널 드래그 피드백 위젯
class _PanelDragFeedback extends ConsumerWidget {
  final PanelInfo panel;

  const _PanelDragFeedback({required this.panel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 200,
        height: 80,
        decoration: BoxDecoration(
          color: ref.color.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ref.color.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: ref.color.primary..withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: ref.color.neonPurple..withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.terminal,
                size: 24,
                color: ref.color.primary,
              ),
              const SizedBox(height: 4),
              Text(
                'Panel Dragging',
                style: ref.font.semiBoldText12.copyWith(
                  color: ref.color.primary,
                ),
              ),
              Text(
                panel.position.name,
                style: ref.font.regularText10.copyWith(
                  color: ref.color.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 빈 패널
class _EmptyTerminalPanel extends ConsumerWidget {
  final PanelInfo panel;

  const _EmptyTerminalPanel({required this.panel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: ref.theme.color.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_box_outlined,
              size: 48,
              color: Colors.white..withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Empty Panel',
              style: ref.font.semiBoldText18.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Position: ${panel.position.name}',
              style: ref.font.regularText14.copyWith(
                color: Colors.white..withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Drag a terminal here',
              style: ref.font.regularText12.copyWith(
                color: Colors.white..withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
