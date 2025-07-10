// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tabListHash() => r'354915745f559bb3838d6efd16b0254eef322613';

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
