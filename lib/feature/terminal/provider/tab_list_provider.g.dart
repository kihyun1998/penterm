// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tabListHash() => r'853aba725e63a9bc99213313112f023f29693f0d';

/// See also [TabList].
@ProviderFor(TabList)
final tabListProvider =
    AutoDisposeNotifierProvider<TabList, List<TabInfo>>.internal(
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

typedef _$TabList = AutoDisposeNotifier<List<TabInfo>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
