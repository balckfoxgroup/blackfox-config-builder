import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  LocaleService._();

  static final LocaleService instance = LocaleService._();

  static const _prefsLocaleKey = 'locale_code';
  static const _prefsLanguageSelectedKey = 'language_selected';
  static const cycle = ['en', 'fa', 'ru', 'zh', 'de', 'uz', 'tr', 'id', 'uk', 'hi'];

  Locale _locale = const Locale('en');
  bool _languageSelected = false;

  Locale get locale => _locale;
  bool get languageSelected => _languageSelected;
  bool get isRtl => _locale.languageCode == 'fa';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _languageSelected = prefs.getBool(_prefsLanguageSelectedKey) ?? false;
    final code = prefs.getString(_prefsLocaleKey);
    if (code != null && cycle.contains(code)) {
      _locale = Locale(code);
    } else {
      _locale = const Locale('en');
    }
  }

  Future<void> setLocale(String code) async {
    if (!cycle.contains(code)) {
      return;
    }
    _locale = Locale(code);
    _languageSelected = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsLocaleKey, code);
    await prefs.setBool(_prefsLanguageSelectedKey, true);
    notifyListeners();
  }

  Future<void> cycleNext() async {
    final index = cycle.indexOf(_locale.languageCode);
    final next = cycle[(index + 1) % cycle.length];
    await setLocale(next);
  }

  String nativeLanguageName(String code) {
    switch (code) {
      case 'fa':
        return 'فارسی';
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'zh':
        return '中文';
      case 'de':
        return 'Deutsch';
      case 'uz':
        return 'Oʻzbek';
      case 'tr':
        return 'Türkçe';
      case 'id':
        return 'Bahasa Indonesia';
      case 'uk':
        return 'Українська';
      case 'hi':
        return 'हिन्दी';
      default:
        return code;
    }
  }

  String languageFlag(String code) {
    switch (code) {
      case 'fa':
        return '🇮🇷';
      case 'en':
        return '🇺🇸';
      case 'ru':
        return '🇷🇺';
      case 'zh':
        return '🇨🇳';
      case 'de':
        return '🇩🇪';
      case 'uz':
        return '🇺🇿';
      case 'tr':
        return '🇹🇷';
      case 'id':
        return '🇮🇩';
      case 'uk':
        return '🇺🇦';
      case 'hi':
        return '🇮🇳';
      default:
        return '';
    }
  }
}
