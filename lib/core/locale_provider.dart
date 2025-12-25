import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _localeKey = 'user_locale';

/// Notifier for managing app locale state
class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier() : super(null);

  /// Initialize locale from SharedPreferences
  /// Returns null if user hasn't set a preference (follow system)
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null) {
      state = Locale(savedLocale);
    }
    // If null, the app will follow system locale
  }

  /// Set locale and persist to SharedPreferences
  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  /// Clear user preference (revert to system locale)
  Future<void> clearLocale() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localeKey);
  }
}

/// Provider for locale state
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier();
});
