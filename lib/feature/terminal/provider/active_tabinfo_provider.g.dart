// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_tabinfo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeTabInfoHash() => r'ec9fe95237d09b76f2b8088cf643ddad40444d63';

/// See also [activeTabInfo].
@ProviderFor(activeTabInfo)
final activeTabInfoProvider = AutoDisposeProvider<TabInfo?>.internal(
  activeTabInfo,
  name: r'activeTabInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeTabInfoHash,
  dependencies: <ProviderOrFamily>[activeTabProvider, tabListProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    activeTabProvider,
    ...?activeTabProvider.allTransitiveDependencies,
    tabListProvider,
    ...?tabListProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveTabInfoRef = AutoDisposeProviderRef<TabInfo?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
