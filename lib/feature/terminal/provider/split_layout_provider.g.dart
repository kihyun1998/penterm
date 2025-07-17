// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_layout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentTabSplitStateHash() =>
    r'61a3fb22736e7ad8894ef23dbb114b771c809060';

/// 현재 활성 탭의 분할 상태를 반환하는 편의 Provider
///
/// Copied from [currentTabSplitState].
@ProviderFor(currentTabSplitState)
final currentTabSplitStateProvider =
    AutoDisposeProvider<SplitLayoutState>.internal(
  currentTabSplitState,
  name: r'currentTabSplitStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentTabSplitStateHash,
  dependencies: <ProviderOrFamily>[splitLayoutProvider, activeTabProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    splitLayoutProvider,
    ...?splitLayoutProvider.allTransitiveDependencies,
    activeTabProvider,
    ...?activeTabProvider.allTransitiveDependencies
  },
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentTabSplitStateRef = AutoDisposeProviderRef<SplitLayoutState>;
String _$splitLayoutHash() => r'7e37ceb137a0e7be4b883b166bc37a57901613ba';

/// See also [SplitLayout].
@ProviderFor(SplitLayout)
final splitLayoutProvider = AutoDisposeNotifierProvider<SplitLayout,
    Map<String, SplitLayoutState>>.internal(
  SplitLayout.new,
  name: r'splitLayoutProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$splitLayoutHash,
  dependencies: <ProviderOrFamily>[activeTabProvider, tabListProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    activeTabProvider,
    ...?activeTabProvider.allTransitiveDependencies,
    tabListProvider,
    ...?tabListProvider.allTransitiveDependencies
  },
);

typedef _$SplitLayout = AutoDisposeNotifier<Map<String, SplitLayoutState>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
