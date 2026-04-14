// lib/core/l10n/language_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

final languageProvider =
    StateNotifierProvider<LanguageNotifier, AppStrings>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<AppStrings> {
  LanguageNotifier() : super(AppStrings.id) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'id';
    state = lang == 'en' ? AppStrings.en : AppStrings.id;
  }

  Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    state = lang == 'en' ? AppStrings.en : AppStrings.id;
  }

  bool get isEnglish => state == AppStrings.en;
}
