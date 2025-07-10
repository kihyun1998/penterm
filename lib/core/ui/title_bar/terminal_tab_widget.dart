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
    final tabMap = ref.watch(tabListProvider);

    // Map을 순서대로 정렬한 리스트 생성
    final orderedTabs = tabMap.values.toList();
    orderedTabs.sort((a, b) => a.order.compareTo(b.order));

    // 현재 활성 탭이 Terminal이 아니면 드래그 비활성화
    final canDrag = activeTabInfo?.type == TabType.terminal;

    // 현재 탭이 드래그 중인지 확인
    final isDragging = dragState.draggingTabId == widget.tab.id;

    // 현재 탭의 인덱스 계산 (순서대로 정렬된 리스트에서)
    final currentTabIndex = orderedTabs.indexOf(widget.tab);

    // 타겟 위치인지 확인 (플레이스홀더 표시할 위치)
    final isTargetPosition = dragState.isDragging &&
        dragState.targetIndex == currentTabIndex &&
        !isDragging; // 드래그 중인 탭 자신은 제외

    // 렌더링 우선순위:
    // 1. 드래그 중인 탭 -> 숨김 (빈 공간)
    // 2. 타겟 위치 탭 -> 플레이스홀더 + 실제 탭
    // 3. 일반 탭 -> 실제 탭

    if (isDragging) {
      // 드래그 중인 탭은 빈 공간으로 표시
      return _buildEmptySpace();
    }

    if (isTargetPosition) {
      // 타겟 위치에는 플레이스홀더 + 실제 탭을 나란히 표시
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPlaceholder(), // 드래그된 탭이 들어갈 자리
            _buildTabContent(isActive), // 기존 탭
          ],
        ),
      );
    }

    // 일반 탭 위젯 (애니메이션 적용)
    final tabWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: _buildTabContent(isActive),
    );

    // 드래그 가능한 경우 Draggable로 감싸기
    if (canDrag && widget.tab.isClosable) {
      return Draggable<TabInfo>(
        data: widget.tab,
        feedback: _buildDragFeedback(isActive),
        childWhenDragging: _buildEmptySpace(), // 드래그 중 빈 공간
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

  /// 빈 공간 (드래그 중인 탭이 차지하던 공간)
  Widget _buildEmptySpace() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
      width: 120, // 탭의 기본 너비와 동일하게
      height: 0, // 높이는 0으로 하여 공간만 차지
    );
  }

  /// 플레이스홀더 (드래그 중 원래 자리에 표시)
  Widget _buildPlaceholder() {
    final dragState = ref.watch(tabDragProvider);
    final tabMap = ref.watch(tabListProvider);

    String draggingTabName = 'Drop here';
    if (dragState.isDragging && dragState.draggingTabId != null) {
      final draggingTab = tabMap[dragState.draggingTabId!];
      if (draggingTab != null) {
        draggingTabName = draggingTab.name;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: ref.color.primary.withOpacity(0.7),
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          // 약간의 배경색 추가
          color: ref.color.primary.withOpacity(0.1),
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
                color: ref.color.primary.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              // 플레이스홀더 텍스트
              Text(
                draggingTabName,
                style: ref.font.semiBoldText12.copyWith(
                  color: ref.color.primary.withOpacity(0.7),
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
