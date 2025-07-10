import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/tab_info.dart';
import 'tab_list_provider.dart';
import 'tab_provider.dart';

part 'active_tabinfo_provider.g.dart';

@Riverpod(dependencies: [ActiveTab, TabList])
TabInfo? activeTabInfo(Ref ref) {
  final activeTabId = ref.watch(activeTabProvider);
  final tabMap = ref.watch(tabListProvider);

  // Map에서 직접 탭 정보 반환
  return tabMap[activeTabId];
}
