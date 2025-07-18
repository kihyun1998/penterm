import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';
import 'package:penterm/feature/terminal/provider/active_tabinfo_provider.dart';
import 'package:penterm/feature/terminal/provider/split_layout_provider.dart';
import 'package:penterm/feature/terminal/provider/tab_list_provider.dart';
import 'package:penterm/feature/terminal/provider/terminal_drag_provider.dart';

/// 드래그 상태 디버그 정보를 표시하는 위젯입니다.
class DragDebugOverlay extends ConsumerWidget {
  const DragDebugOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dragState = ref.watch(terminalDragProvider);

    if (!dragState.isDragging) return const SizedBox.shrink();

    return Positioned(
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
              } else if (line.contains('Target Index:')) {
                textColor = ref.color.neonGreen;
              } else if (line.contains('Place Index:')) {
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
    );
  }
}

/// 분할 상태 디버그 정보를 표시하는 위젯입니다.
class SplitDebugOverlay extends ConsumerWidget {
  const SplitDebugOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splitState = ref.watch(currentTabSplitStateProvider);

    if (!splitState.isSplit) return const SizedBox.shrink();

    return Positioned(
      top: 60,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: ref.color.secondary.withOpacity(0.5)),
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
              '🔄 SPLIT DEBUG',
              style: ref.font.monoBoldText10.copyWith(
                color: ref.color.secondary,
              ),
            ),
            const SizedBox(height: 4),
            ...splitState.debugInfo.split('\n').map((line) {
              if (line.trim().isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  line,
                  style: ref.font.monoRegularText10.copyWith(
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// 드래그 상태의 상세 디버그 정보를 표시하는 위젯입니다.
class DragStateDebugOverlay extends ConsumerWidget {
  const DragStateDebugOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dragState = ref.watch(terminalDragProvider);

    return Positioned(
      bottom: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: ref.color.neonBlue.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔍 DRAG STATE DEBUG',
              style: ref.font.monoBoldText10.copyWith(
                color: ref.color.neonBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'isDragging: ${dragState.isDragging}',
              style: ref.font.monoRegularText10.copyWith(
                color: dragState.isDragging ? Colors.red : Colors.green,
              ),
            ),
            Text(
              'draggingTerminalId: ${dragState.draggingTerminalId ?? 'null'}',
              style: ref.font.monoRegularText10.copyWith(
                color: Colors.white,
              ),
            ),
            Text(
              'targetIndex: ${dragState.targetIndex ?? 'null'}',
              style: ref.font.monoRegularText10.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 탭 순서 디버그 정보를 표시하는 위젯입니다.
class TabOrderDebugOverlay extends ConsumerWidget {
  const TabOrderDebugOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTabInfo = ref.watch(activeTabInfoProvider);
    final tabList = ref.watch(tabListProvider);

    return Positioned(
      bottom: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: ref.color.neonGreen.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '📋 TAB ORDER DEBUG',
              style: ref.font.monoBoldText10.copyWith(
                color: ref.color.neonGreen,
              ),
            ),
            const SizedBox(height: 4),
            ...tabList.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isActive = activeTabInfo?.id == tab.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '[$index] ${tab.name} ${isActive ? '🔥' : ''}',
                  style: ref.font.monoRegularText10.copyWith(
                    color: isActive ? ref.color.neonGreen : Colors.white,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
