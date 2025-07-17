// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'terminal_drag_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$terminalDragHash() => r'e2b1bd09163c62bf67dee0469474faa92b1668fb';

/// See also [TerminalDrag].
@ProviderFor(TerminalDrag)
final terminalDragProvider =
    AutoDisposeNotifierProvider<TerminalDrag, TerminalDragState>.internal(
  TerminalDrag.new,
  name: r'terminalDragProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$terminalDragHash,
  dependencies: <ProviderOrFamily>[tabListProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    tabListProvider,
    ...?tabListProvider.allTransitiveDependencies
  },
);

typedef _$TerminalDrag = AutoDisposeNotifier<TerminalDragState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
