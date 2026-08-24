import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../services/csv_service.dart';
import 'categories_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Settings', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          Text('Appearance', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (v) => settings.setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (v) => settings.setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (v) => settings.setThemeMode(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Currency', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: const Text('Currency Symbol'),
              subtitle: Text(settings.currencySymbol),
              trailing: const Icon(Icons.edit),
              onTap: () => _editCurrency(context, settings),
            ),
          ),
          const SizedBox(height: 16),
          Text('Categories', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Manage Categories'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CategoriesScreen()),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Data', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Export to CSV'),
                  subtitle: const Text('Share or save your expenses'),
                  onTap: () async {
                    try {
                      final path = await CsvService.export();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Exported: $path')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Export failed: $e')));
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Import from CSV'),
                  subtitle:
                  const Text('Load expenses from a CSV file'),
                  onTap: () => _importCsv(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Expense Tracker',
              style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
          Text('Offline • Local storage • v1.0.0',
              style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _editCurrency(BuildContext context, SettingsProvider s) async {
    final ctrl = TextEditingController(text: s.currencySymbol);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Currency Symbol'),
        content: TextField(
          controller: ctrl,
          maxLength: 4,
          decoration: const InputDecoration(hintText: 'e.g. ₹, €'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () =>
                  Navigator.pop(context, ctrl.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await s.setCurrencySymbol(result);
    }
  }

  void _importCsv(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null || result.files.single.path == null) return;

    try {
      final count = await CsvService.import(result.files.single.path!);
      if (context.mounted) {
        context.read<ExpenseProvider>().reload();
        context.read<CategoryProvider>().reload();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imported $count expenses')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import failed: $e')));
      }
    }
  }
}