import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

import '../../../feature/terminal/model/tab_info.dart';
import '../../../feature/terminal/provider/tab_drag_provider.dart';
import '../../../feature/terminal/provider/tab_list_provider.dart';
import '../../../feature/terminal/provider/tab_provider.dart';
import '../../util/svg/model/enum_svg_asset.dart';
import '../app_icon_button.dart';

class TerminalTabWidget extends ConsumerStatefulWidget {
  final TabInfo tab;
  final String activeTabId;

  const TerminalTabWidget({
    super.key,
    required this.tab,
    required this.activeTabId,
  });

  @override
  ConsumerState<TerminalTabWidget> createState() => _TerminalTabWidgetState();
}

class _TerminalTabWidgetState extends ConsumerState<TerminalTabWidget> {
  bool _isHovered = false;

  // 🆕 고정 탭 너비
  static const double _tabWidth = 140.0;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.activeTabId == widget.tab.id;
    final dragState = ref.watch(tabDragProvider);

    // 현재 탭이 드래그 중인지 확인
    final isDragging = dragState.draggingTabId == widget.tab.id;

    // Draggable로 감싸서 드래그 가능하게 만들기
    return Draggable<TabInfo>(
      data: widget.tab,
      feedback: _buildDragFeedback(isActive),
      childWhenDragging: _buildTabContent(isActive, true), // 투명한 탭 유지
      onDragStarted: () {
        print('🚀 Drag started: ${widget.tab.name}');
        ref.read(tabDragProvider.notifier).startDrag(widget.tab.id);
      },
      onDragUpdate: (details) {
        ref
            .read(tabDragProvider.notifier)
            .updatePosition(details.globalPosition);
      },
      onDragEnd: (details) {
        print('✅ Drag ended: ${widget.tab.name}');
        final dragState = ref.read(tabDragProvider);

        if (dragState.targetOrder != null) {
          print('📋 Target found - will be handled by TabDropZone');
          // TabDropZone에서 endDrag()를 호출할 것임
        } else {
          print('📋 No target - returning to original position');
          // 드롭 영역 밖에서 끝난 경우 원래 자리로 복귀
          ref.read(tabDragProvider.notifier).cancelDrag();
        }
      },
      onDraggableCanceled: (velocity, offset) {
        print('❌ Drag canceled: ${widget.tab.name}');
        ref.read(tabDragProvider.notifier).cancelDrag();
      },
      child: _buildTabContent(isActive, isDragging),
    );
  }

  /// 실제 탭 내용
  Widget _buildTabContent(bool isActive, bool isDragging) {
    return Opacity(
      opacity: isDragging ? 0.5 : 1.0, // 드래그 중일 때 투명도 적용
      child: Container(
        // 🆕 고정 너비 적용
        width: _tabWidth,
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
                        // 🆕 탭 이름 - Expanded로 감싸고 ellipsis 처리
                        Expanded(
                          child: Text(
                            widget.tab.name,
                            style: ref.font.semiBoldText12.copyWith(
                              color: isActive
                                  ? ref.color.primary
                                  : ref.color.onBackgroundSoft,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 16), // X 버튼 공간 확보
                      ],
                    ),
                  ),
                  // 닫기 버튼 - hover 시에만 표시, 드래그 중이 아닐 때만
                  if (_isHovered && !isDragging)
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
      ),
    );
  }

  /// 드래그 피드백 (드래그 중 마우스를 따라다니는 위젯)
  Widget _buildDragFeedback(bool isActive) {
    return Material(
      color: Colors.transparent,
      child: Container(
        // 🆕 피드백도 동일한 고정 너비
        width: _tabWidth,
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
              color: ref.color.primary.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: ref.color.neonPurple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // 탭 아이콘 (터미널)
              Icon(
                Icons.terminal,
                size: 14,
                color:
                    isActive ? ref.color.primary : ref.color.onBackgroundSoft,
              ),
              const SizedBox(width: 6),
              // 🆕 탭 이름 - 피드백에서도 ellipsis 처리
              Expanded(
                child: Text(
                  widget.tab.name,
                  style: ref.font.semiBoldText12.copyWith(
                    color: isActive
                        ? ref.color.primary
                        : ref.color.onBackgroundSoft,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
