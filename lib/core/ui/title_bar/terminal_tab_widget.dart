import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

import '../../../feature/terminal/model/enum_tab_type.dart';
import '../../../feature/terminal/model/tab_info.dart';
import '../../../feature/terminal/provider/active_tabinfo_provider.dart';
import '../../../feature/terminal/provider/tab_drag_provider.dart';
import '../../../feature/terminal/provider/tab_list_provider.dart';
import '../../../feature/terminal/provider/tab_provider.dart';
import '../../util/svg/model/enum_svg_asset.dart';
import '../app_icon_button.dart';

class TerminalTabWidget extends ConsumerStatefulWidget {
  final TabInfo tab;
  final String activeTabId;
  final GlobalKey? tabKey;

  const TerminalTabWidget({
    super.key,
    required this.tab,
    required this.activeTabId,
    this.tabKey,
  });

  @override
  ConsumerState<TerminalTabWidget> createState() => _TerminalTabWidgetState();
}

class _TerminalTabWidgetState extends ConsumerState<TerminalTabWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.activeTabId == widget.tab.id;
    final dragState = ref.watch(tabDragProvider);
    final activeTabInfo = ref.watch(activeTabInfoProvider);

    // 현재 활성 탭이 Terminal이 아니면 드래그 비활성화
    final canDrag = activeTabInfo?.type == TabType.terminal;

    // 현재 탭이 드래그 중인지 확인
    final isDragging = dragState.draggingTabId == widget.tab.id;

    // 드래그 중이면 플레이스홀더 표시
    if (isDragging) {
      return _buildPlaceholder();
    }

    // 일반 탭 위젯
    final tabWidget = _buildTabContent(isActive);

    // 드래그 가능한 경우 Draggable로 감싸기
    if (canDrag && widget.tab.isClosable) {
      return Draggable<TabInfo>(
        data: widget.tab,
        feedback: _buildDragFeedback(isActive),
        childWhenDragging: _buildPlaceholder(),
        onDragStarted: () {
          ref.read(tabDragProvider.notifier).startDrag(widget.tab.id);
        },
        onDragUpdate: (details) {
          ref
              .read(tabDragProvider.notifier)
              .updateDragPosition(details.globalPosition);
        },
        onDragEnd: (details) {
          ref.read(tabDragProvider.notifier).endDrag();
        },
        onDraggableCanceled: (velocity, offset) {
          ref.read(tabDragProvider.notifier).cancelDrag();
        },
        child: tabWidget,
      );
    }

    return tabWidget;
  }

  /// 실제 탭 내용
  Widget _buildTabContent(bool isActive) {
    return Container(
      key: widget.tabKey,
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () =>
              ref.read(activeTabProvider.notifier).setTab(widget.tab.id),
          child: Container(
            decoration: BoxDecoration(
              color: isActive
                  ? ref.color.primarySoft
                  : ref.color.surfaceVariantSoft,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              border: isActive
                  ? Border(
                      bottom: BorderSide(
                        color: ref.color.primary,
                        width: 2,
                      ),
                    )
                  : null,
            ),
            child: Stack(
              children: [
                // 기본 탭 내용 (패딩 적용)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 탭 아이콘 (터미널)
                      Icon(
                        Icons.terminal,
                        size: 14,
                        color: isActive
                            ? ref.color.primary
                            : ref.color.onBackgroundSoft,
                      ),
                      const SizedBox(width: 6),
                      // 탭 이름
                      Text(
                        widget.tab.name,
                        style: ref.font.semiBoldText12.copyWith(
                          color: isActive
                              ? ref.color.primary
                              : ref.color.onBackgroundSoft,
                        ),
                      ),
                      const SizedBox(width: 16), // X 버튼 공간 확보
                    ],
                  ),
                ),
                // 닫기 버튼 - hover 시에만 표시, 우상단에 positioned
                if (_isHovered)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 2,
                    child: Center(
                      child: AppIconButton(
                        width: 16,
                        height: 16,
                        backgroundColor: isActive
                            ? ref.color.primarySoft
                            : ref.color.surfaceVariantSoft,
                        hoverColor: ref.color.hover,
                        borderRadius: BorderRadius.circular(4),
                        onPressed: () => ref
                            .read(tabListProvider.notifier)
                            .removeTab(widget.tab.id),
                        icon: SVGAsset.windowClose,
                        iconColor: isActive
                            ? ref.color.primary
                            : ref.color.onSurfaceVariant,
                        iconSize: 8,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 드래그 피드백 (드래그 중 마우스를 따라다니는 위젯)
  Widget _buildDragFeedback(bool isActive) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
        decoration: BoxDecoration(
          color:
              isActive ? ref.color.primarySoft : ref.color.surfaceVariantSoft,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          border: isActive
              ? Border(
                  bottom: BorderSide(
                    color: ref.color.primary,
                    width: 2,
                  ),
                )
              : null,
          // 드래그 중임을 나타내는 그림자 효과
          boxShadow: [
            BoxShadow(
              color: ref.color.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 탭 아이콘 (터미널)
              Icon(
                Icons.terminal,
                size: 14,
                color:
                    isActive ? ref.color.primary : ref.color.onBackgroundSoft,
              ),
              const SizedBox(width: 6),
              // 탭 이름
              Text(
                widget.tab.name,
                style: ref.font.semiBoldText12.copyWith(
                  color:
                      isActive ? ref.color.primary : ref.color.onBackgroundSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 플레이스홀더 (드래그 중 원래 자리에 표시)
  Widget _buildPlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: ref.color.primary.withOpacity(0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 플레이스홀더 아이콘
              Icon(
                Icons.terminal,
                size: 14,
                color: ref.color.primary.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              // 플레이스홀더 텍스트
              Text(
                widget.tab.name,
                style: ref.font.semiBoldText12.copyWith(
                  color: ref.color.primary.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 16), // X 버튼 공간 확보
            ],
          ),
        ),
      ),
    );
  }
}
