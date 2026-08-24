import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cats = context.watch<CategoryProvider>();
    final exp = context.watch<ExpenseProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: cats.categories.isEmpty
          ? const Center(
        child: Text('No categories. Tap + to add one.'),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: cats.categories.length,
        itemBuilder: (context, i) {
          final c = cats.categories[i];
          final count = exp.countByCategory(c.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: Text(c.name.isNotEmpty
                    ? c.name[0].toUpperCase()
                    : '?'),
              ),
              title: Text(c.name),
              subtitle: Text(count == 1 ? '1 expense' : '$count expenses'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () =>
                        _showRenameDialog(context, c.id, c.name),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _showDeleteDialog(
                        context, c.id, c.name, count),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Category'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Category name'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              await context.read<CategoryProvider>().addCategory(name);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, String id, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename Category'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'New name'),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              await context.read<CategoryProvider>().renameCategory(id, name);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, String id, String name, int count) async {
    final cats = context.read<CategoryProvider>();
    final exp = context.read<ExpenseProvider>();

    if (count == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Category'),
          content: Text('Delete "$name"? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await cats.deleteCategory(id, expenseCount: 0);
      }
      return;
    }

    final otherCats = cats.categories.where((c) => c.id != id).toList();
    if (otherCats.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Cannot Delete'),
          content: Text(
              '"$name" has $count expense(s). Create another category first to move expenses.'),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    String? moveTo = otherCats.first.id;
    final action = await showDialog<String>(
      context: context,
      builder: (_) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Delete Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('"$name" has $count expense(s).'),
                const SizedBox(height: 12),
                const Text('Move expenses to:'),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: moveTo,
                  isExpanded: true,
                  items: otherCats
                      .map((c) =>
                      DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => moveTo = v),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, 'cancel'),
                  child: const Text('Cancel')),
              FilledButton(
                onPressed: () => Navigator.pop(context, 'move'),
                child: const Text('Move & Delete'),
              ),
            ],
          );
        });
      },
    );

    if (action == 'move' && moveTo != null) {
      await cats.deleteCategory(id,
          expenseCount: count, moveToCategoryId: moveTo);
      exp.reload();
    }
  }
}