import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/tab_info.dart';
import 'tab_list_provider.dart';
import 'tab_provider.dart';

part 'active_tabinfo_provider.g.dart';

@Riverpod(dependencies: [ActiveTab, TabList])
TabInfo? activeTabInfo(Ref ref) {
  final activeTabId = ref.watch(activeTabProvider);
  final tabList = ref.watch(tabListProvider);

  // 🚀 List에서 직접 탭 정보 찾기
  try {
    return tabList.firstWhere((tab) => tab.id == activeTabId);
  } catch (e) {
    // 탭을 찾을 수 없는 경우 null 반환
    return null;
  }
}
