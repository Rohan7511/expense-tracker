import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../services/storage_service.dart';
import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  final Box _box = Hive.box(StorageService.settingsBox);

  static const String _themeKey = 'themeMode';
  static const String _currencyKey = 'currencySymbol';

  String get currencySymbol =>
      _box.get(_currencyKey, defaultValue: '₹') as String;

  ThemeMode get themeMode {
    final v = _box.get(_themeKey, defaultValue: 'system');
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setCurrencySymbol(String s) async {
    await _box.put(_currencyKey, s);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String v = 'system';
    if (mode == ThemeMode.light) v = 'light';
    if (mode == ThemeMode.dark) v = 'dark';
    await _box.put(_themeKey, v);
    notifyListeners();
  }
}