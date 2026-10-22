import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

const _fallbackLocale = Locale('pt');
const _supportedLanguageCodes = {'pt', 'en'};

/// `currentUser?.locale` will take priority over the device locale once
/// AUTH-07 exists and writes `profiles.locale` — this seam ships now so
/// AUTH-07 only has to supply the value.
final localeProvider = Provider<Locale>((ref) {
  final deviceLanguageCode = PlatformDispatcher.instance.locale.languageCode;

  if (_supportedLanguageCodes.contains(deviceLanguageCode)) {
    return Locale(deviceLanguageCode);
  }

  return _fallbackLocale;
});
