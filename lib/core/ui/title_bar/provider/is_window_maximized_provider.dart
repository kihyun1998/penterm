import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:window_manager/window_manager.dart';

part 'is_window_maximized_provider.g.dart';

@riverpod
class IsWindowMaximized extends _$IsWindowMaximized {
  @override
  bool build() {
    return false; // 초기값: 비최대화
  }

  /// 윈도우 최대화 상태 업데이트
  void setMaximized(bool isMaximized) {
    state = isMaximized;
  }

  /// 윈도우 최대화 토글
  Future<void> toggleMaximize() async {
    if (state) {
      await windowManager.unmaximize();
      // onWindowUnmaximize()에서 setMaximized(false) 호출됨
    } else {
      await windowManager.maximize();
      // onWindowMaximize()에서 setMaximized(true) 호출됨
    }
  }

  /// 초기 윈도우 상태 로드
  Future<void> loadInitialState() async {
    try {
      final isMaximized = await windowManager.isMaximized();
      state = isMaximized;
    } catch (e) {
      // 에러 시 기본값 유지
      print('윈도우 최대화 상태 로드 실패: $e');
    }
  }
}
