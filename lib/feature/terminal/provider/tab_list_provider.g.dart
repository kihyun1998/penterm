// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tabListHash() => r'fa8ac71ce4e5b81a41f0f31fde6c68b2eb145ba4';

/// See also [TabList].
@ProviderFor(TabList)
final tabListProvider =
    AutoDisposeNotifierProvider<TabList, Map<String, TabInfo>>.internal(
  TabList.new,
  name: r'tabListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tabListHash,
  dependencies: <ProviderOrFamily>[activeTabProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    activeTabProvider,
    ...?activeTabProvider.allTransitiveDependencies
  },
);

typedef _$TabList = AutoDisposeNotifier<Map<String, TabInfo>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
