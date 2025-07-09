import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/tab_info.dart';
import 'tab_list_provider.dart';
import 'tab_provider.dart';

part 'active_tabinfo_provider.g.dart';

@riverpod
TabInfo? activeTabInfo(Ref ref) {
  final activeTabId = ref.watch(activeTabProvider);
  final tabList = ref.watch(tabListProvider);

  try {
    return tabList.firstWhere((tab) => tab.id == activeTabId);
  } catch (e) {
    return null;
  }
}
