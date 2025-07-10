// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_drag_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tabDragHash() => r'970f721696f45431654194a7887fa104e7308f18';

/// See also [TabDrag].
@ProviderFor(TabDrag)
final tabDragProvider =
    AutoDisposeNotifierProvider<TabDrag, TabDragState>.internal(
  TabDrag.new,
  name: r'tabDragProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tabDragHash,
  dependencies: <ProviderOrFamily>[tabListProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    tabListProvider,
    ...?tabListProvider.allTransitiveDependencies
  },
);

typedef _$TabDrag = AutoDisposeNotifier<TabDragState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
