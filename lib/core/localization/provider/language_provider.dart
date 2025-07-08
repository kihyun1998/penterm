import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:penterm/core/localization/generated/l10n.dart';
import 'package:penterm/core/localization/provider/locale_state_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'language_provider.g.dart';

@Riverpod(dependencies: [LocaleState])
S language(Ref ref) {
  ref.watch(localeStateProvider);
  return S.current;
}
