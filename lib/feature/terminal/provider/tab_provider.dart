import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/enum_tab_type.dart';

part 'tab_provider.g.dart';

@riverpod
class ActiveTab extends _$ActiveTab {
  @override
  String build() {
    return TabType.home.value; // 기본값: Home 탭
  }

  /// 특정 탭으로 전환
  void setTab(String tabId) {
    state = tabId;
  }

  /// Home 탭으로 전환
  void goToHome() {
    state = TabType.home.value;
  }

  /// SFTP 탭으로 전환
  void goToSftp() {
    state = TabType.sftp.value;
  }
}
