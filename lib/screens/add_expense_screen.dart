import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  late TextEditingController _itemsCtrl;
  String? _categoryId;
  late DateTime _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amountCtrl =
        TextEditingController(text: e != null ? e.amount.toStringAsFixed(2) : '');
    _itemsCtrl = TextEditingController(text: e?.items ?? '');
    _date = e?.date ?? DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cats = context.read<CategoryProvider>().categories;
      if (cats.isNotEmpty && _categoryId == null) {
        setState(() {
          _categoryId = e?.categoryId ?? cats.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _itemsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')));
      return;
    }
    setState(() => _saving = true);

    final amount = double.parse(_amountCtrl.text.trim());
    final items = _itemsCtrl.text.trim();
    final id = widget.expense?.id ??
        '${DateTime.now().microsecondsSinceEpoch}';

    final exp = Expense(
      id: id,
      amount: amount,
      items: items,
      categoryId: _categoryId!,
      date: _date,
    );

    final provider = context.read<ExpenseProvider>();
    if (widget.expense == null) {
      await provider.addExpense(exp);
    } else {
      await provider.updateExpense(exp);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.expense == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),

          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<ExpenseProvider>().deleteExpense(widget.expense!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cats = context.watch<CategoryProvider>();
    final settings = context.watch<SettingsProvider>();
    final isEdit = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Expense' : 'Add Expense'),
        actions: [
          if (isEdit)
            IconButton(
                onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountCtrl,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: settings.currencySymbol,
                border: const OutlineInputBorder(),
              ),
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                final n = double.tryParse(v);
                if (n == null || n <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _itemsCtrl,
              decoration: const InputDecoration(
                labelText: 'Item(s)',
                hintText: 'e.g. Lunch, Taxi ride',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: cats.categories
                  .map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _categoryId = v),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('d MMM yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(isEdit ? 'Update' : 'Save'),
            ),
            const SizedBox(height: 12),
            if (isEdit)
              OutlinedButton.icon(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Expense'),
              ),
          ],
        ),
      ),
    );
  }
}