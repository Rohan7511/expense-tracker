import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final Box<Map> _box = Hive.box<Map>(StorageService.expenseBox);

  List<Expense> _expenses = [];
  List<Expense> get expenses => List.unmodifiable(_expenses);

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String? _filterCategoryId;
  String? get filterCategoryId => _filterCategoryId;

  ExpenseProvider() {
    _load();
  }

  void _load() {
    _expenses = _box.values
        .map((e) => Expense.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  List<Expense> get filtered {
    var list = _expenses;
    if (_filterCategoryId != null) {
      list = list.where((e) => e.categoryId == _filterCategoryId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((e) => e.items.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int countByCategory(String categoryId) =>
      _expenses.where((e) => e.categoryId == categoryId).length;

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilter(String? categoryId) {
    _filterCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> addExpense(Expense e) async {
    await _box.put(e.id, e.toMap());
    _load();
  }

  Future<void> updateExpense(Expense e) async {
    await _box.put(e.id, e.toMap());
    _load();
  }

  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
    _load();
  }

  void reload() => _load();
}