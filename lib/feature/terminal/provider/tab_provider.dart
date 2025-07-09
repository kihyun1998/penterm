import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/enum_tab_type.dart';

part 'tab_provider.g.dart';

@riverpod
class ActiveTab extends _$ActiveTab {
  @override
  TabType build() {
    return TabType.home; // 기본값: Home 탭
  }

  /// 특정 탭으로 전환
  void setTab(TabType tabType) {
    state = tabType;
  }

  /// Home 탭으로 전환
  void goToHome() {
    state = TabType.home;
  }

  /// SFTP 탭으로 전환
  void goToSftp() {
    state = TabType.sftp;
  }

  /// 탭 토글 (Home ↔ SFTP)
  void toggleTab() {
    state = state == TabType.home ? TabType.sftp : TabType.home;
  }
}
