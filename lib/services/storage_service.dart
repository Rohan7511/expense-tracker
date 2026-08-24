import 'package:hive_flutter/hive_flutter.dart';
import '../models/category.dart';

class StorageService {
  static const String expenseBox = 'expenses';
  static const String categoryBox = 'categories';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(expenseBox);
    await Hive.openBox<Map>(categoryBox);
    await Hive.openBox(settingsBox);
    await _seedDefaults();
  }

  static Future<void> _seedDefaults() async {
    final settings = Hive.box(settingsBox);
    final seeded = settings.get('defaultsSeeded', defaultValue: false) as bool;
    if (seeded) return;

    final cats = Hive.box<Map>(categoryBox);
    final defaults = ['Canteen', 'Travel', 'Important'];
    for (var i = 0; i < defaults.length; i++) {
      final name = defaults[i];
      final id = 'default_${i}_$name';
      await cats.put(id, ExpenseCategory(id: id, name: name).toMap());
    }
    await settings.put('defaultsSeeded', true);
  }
}