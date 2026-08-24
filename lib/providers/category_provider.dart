import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

class CategoryProvider extends ChangeNotifier {
  final Box<Map> _box = Hive.box<Map>(StorageService.categoryBox);

  List<ExpenseCategory> _categories = [];
  List<ExpenseCategory> get categories => List.unmodifiable(_categories);

  CategoryProvider() {
    _load();
  }

  void _load() {
    _categories = _box.values
        .map((e) => ExpenseCategory.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    _categories.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    notifyListeners();
  }

  ExpenseCategory? findById(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final id = '${DateTime.now().microsecondsSinceEpoch}_${trimmed.hashCode}';
    await _box.put(id, ExpenseCategory(id: id, name: trimmed).toMap());
    _load();
  }

  Future<void> renameCategory(String id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    await _box.put(id, ExpenseCategory(id: id, name: trimmed).toMap());
    _load();
  }

  Future<void> deleteCategory(String id,
      {String? moveToCategoryId, required int expenseCount}) async {
    if (expenseCount > 0 && moveToCategoryId != null) {
      final expBox = Hive.box<Map>(StorageService.expenseBox);
      for (final key in expBox.keys.toList()) {
        final m = Map<String, dynamic>.from(expBox.get(key) as Map);
        if (m['categoryId'] == id) {
          m['categoryId'] = moveToCategoryId;
          await expBox.put(key, m);
        }
      }
    }
    await _box.delete(id);
    _load();
  }

  void reload() => _load();
}