import 'dart:io';
import 'package:csv/csv.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense.dart';
import '../models/category.dart';
import 'storage_service.dart';

class CsvService {
  static Future<String> export() async {
    final expBox = Hive.box<Map>(StorageService.expenseBox);
    final catBox = Hive.box<Map>(StorageService.categoryBox);

    final cats = catBox.values
        .map((e) => ExpenseCategory.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final catMap = {for (var c in cats) c.id: c.name};

    final List<List<dynamic>> rows = [
      ['id', 'amount', 'items', 'categoryId', 'categoryName', 'date']
    ];

    for (final e in expBox.values) {
      final m = Map<String, dynamic>.from(e);
      final exp = Expense.fromMap(m);
      rows.add([
        exp.id,
        exp.amount.toStringAsFixed(2),
        exp.items,
        exp.categoryId,
        catMap[exp.categoryId] ?? '',
        exp.date.toIso8601String(),
      ]);
    }

    final csv = Csv().encode(rows);
    final dir = await getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final name =
        'expense_export_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour}${now.minute}.csv';
    final file = File('${dir.path}/$name');
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: 'Expense Export');
    return file.path;
  }

  static Future<int> import(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;

    final raw = await file.readAsString();
    final rows = Csv().decode(raw);
    if (rows.length < 2) return 0;

    final expBox = Hive.box<Map>(StorageService.expenseBox);
    final catBox = Hive.box<Map>(StorageService.categoryBox);

    final cats = catBox.values
        .map((e) => ExpenseCategory.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final catNameMap = {for (var c in cats) c.name.toLowerCase(): c};

    int count = 0;
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 6) continue;

      final id = row[0]?.toString().isNotEmpty == true
          ? row[0].toString()
          : '${DateTime.now().microsecondsSinceEpoch}_$i';
      final amount = double.tryParse(row[1].toString()) ?? 0.0;
      final items = row[2]?.toString() ?? '';
      var categoryId = row[3]?.toString() ?? '';
      final categoryName = row[4]?.toString() ?? '';

      if (categoryId.isEmpty && categoryName.isNotEmpty) {
        final lower = categoryName.toLowerCase();
        if (catNameMap.containsKey(lower)) {
          categoryId = catNameMap[lower]!.id;
        } else {
          categoryId = '${DateTime.now().microsecondsSinceEpoch}_$lower';
          await catBox.put(
            categoryId,
            ExpenseCategory(id: categoryId, name: categoryName).toMap(),
          );
          catNameMap[lower] = ExpenseCategory(id: categoryId, name: categoryName);
        }
      }

      DateTime date;
      try {
        date = DateTime.parse(row[5].toString());
      } catch (_) {
        date = DateTime.now();
      }

      final exp = Expense(
        id: id,
        amount: amount,
        items: items,
        categoryId: categoryId,
        date: date,
      );
      await expBox.put(id, exp.toMap());
      count++;
    }
    return count;
  }
}