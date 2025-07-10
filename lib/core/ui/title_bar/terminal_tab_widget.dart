import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';

import '../../../feature/terminal/model/tab_info.dart';
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

  @override
  Widget build(BuildContext context) {
    final isActive = widget.activeTabId == widget.tab.id;

    return Container(
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
}
