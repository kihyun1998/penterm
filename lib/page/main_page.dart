import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ui/debug_overlays.dart';
import '../core/ui/title_bar/app_title_bar.dart';
import '../feature/terminal/provider/active_tabinfo_provider.dart';
import '../feature/terminal/ui/terminal_canvas.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTabInfo = ref.watch(activeTabInfoProvider);

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // 커스텀 타이틀바
              const AppTitleBar(),

              // 메인 콘텐츠 - 터미널 캔버스 위젯으로 교체
              Expanded(
                child: TerminalCanvas(activeTabInfo: activeTabInfo),
              ),
            ],
          ),

          // 🎯 드래그 상태 디버그 정보 (별도 위젯으로 분리)
          const DragDebugOverlay(),

          // 🆕 분할 상태 디버그 정보 (별도 위젯으로 분리)
          const SplitDebugOverlay(),

          // 🆕 드래그 상태 디버그 정보 + Split 후 상태 확인 (별도 위젯으로 분리)
          const DragStateDebugOverlay(),

          // 🆕 탭 순서 디버그 정보 (별도 위젯으로 분리)
          const TabOrderDebugOverlay(),
        ],
      ),
    );
  }
}
