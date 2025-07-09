import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/theme/provider/theme_provider.dart';
import 'package:window_manager/window_manager.dart';

import '../../util/svg/model/enum_svg_asset.dart';
import '../../util/svg/widget/svg_icon.dart';
import '../app_button.dart';
import 'provider/is_window_maximized_provider.dart';

class AppTitleBar extends ConsumerStatefulWidget {
  const AppTitleBar({super.key});

  @override
  ConsumerState<AppTitleBar> createState() => _AppTitleBarState();
}

class _AppTitleBarState extends ConsumerState<AppTitleBar> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    // 🚀 초기 윈도우 상태 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isWindowMaximizedProvider.notifier).loadInitialState();
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // ========================================================================
  // WindowListener 메서드들 - Provider에만 상태 업데이트 (setState 없음!)
  // ========================================================================

  @override
  void onWindowMaximize() {
    ref.read(isWindowMaximizedProvider.notifier).setMaximized(true);
    // 🚀 setState() 없음 - 전체 위젯 rebuild 없음!
  }

  @override
  void onWindowUnmaximize() {
    ref.read(isWindowMaximizedProvider.notifier).setMaximized(false);
    // 🚀 setState() 없음 - 전체 위젯 rebuild 없음!
  }

  @override
  Widget build(BuildContext context) {
    // ✅ build는 WindowListener 이벤트와 무관하게 안정적
    return Container(
      height: 50,
      color: ref.color.background,
      child: Row(
        children: [
          // 🎯 드래그 영역 - 윈도우 최대화와 무관하므로 rebuild 안됨
          Expanded(child: DragToMoveArea(child: Container())),

          // 🎯 제어 버튼 영역
          Row(
            children: [
              AppButton(
                child: SVGIcon(
                  asset: SVGAsset.windowMinimize,
                  color: ref.color.onBackground,
                  size: 14,
                ),
                onPressed: () => windowManager.minimize(),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final isMaximized = ref.watch(isWindowMaximizedProvider);
                  return AppButton(
                    child: SVGIcon(
                      asset: isMaximized
                          ? SVGAsset.windowRestore
                          : SVGAsset.windowMaximize,
                      color: ref.color.onBackground,
                      size: 14,
                    ),
                    onPressed: () {
                      ref
                          .read(isWindowMaximizedProvider.notifier)
                          .toggleMaximize();
                    },
                  );
                },
              ),
              AppButton(
                child: SVGIcon(
                  asset: SVGAsset.windowClose,
                  color: ref.color.onBackground,
                  size: 18,
                ),
                onPressed: () => windowManager.close(),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }
}
