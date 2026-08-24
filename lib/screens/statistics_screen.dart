import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exp = context.watch<ExpenseProvider>();
    final cats = context.watch<CategoryProvider>();
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final monthStart = DateTime(now.year, now.month, 1);
    final yearStart = DateTime(now.year, 1, 1);

    double weeklyTotal = 0, monthlyTotal = 0, yearlyTotal = 0;
    for (final e in exp.expenses) {
      if (!e.date.isBefore(yearStart)) yearlyTotal += e.amount;
      if (!e.date.isBefore(monthStart)) monthlyTotal += e.amount;
      if (!e.date.isBefore(weekStartDay)) weeklyTotal += e.amount;
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Overall Totals', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _totalCard(context, 'Weekly', weeklyTotal,
                    settings.currencySymbol, theme.colorScheme.primaryContainer),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _totalCard(context, 'Monthly', monthlyTotal,
                    settings.currencySymbol, theme.colorScheme.secondaryContainer),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _totalCard(context, 'Yearly', yearlyTotal,
                    settings.currencySymbol, theme.colorScheme.tertiaryContainer),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('By Category', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          if (cats.categories.isEmpty)
            const Text('No categories.')
          else
            ...cats.categories.map((c) {
              double w = 0, m = 0, y = 0;
              for (final e in exp.expenses) {
                if (e.categoryId == c.id) {
                  if (!e.date.isBefore(yearStart)) y += e.amount;
                  if (!e.date.isBefore(monthStart)) m += e.amount;
                  if (!e.date.isBefore(weekStartDay)) w += e.amount;
                }
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor:
                            theme.colorScheme.onPrimaryContainer,
                            child: Text(c.name.isNotEmpty
                                ? c.name[0].toUpperCase()
                                : '?'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(c.name,
                                style: theme.textTheme.titleMedium),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: _miniStat(
                                  context, 'Week', w, settings.currencySymbol)),
                          Expanded(
                              child: _miniStat(
                                  context, 'Month', m, settings.currencySymbol)),
                          Expanded(
                              child: _miniStat(
                                  context, 'Year', y, settings.currencySymbol)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _totalCard(BuildContext context, String label, double amount,
      String symbol, Color color) {
    final theme = Theme.of(context);
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              Formatters.currency(amount, symbol),
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(
      BuildContext context, String label, double amount, String symbol) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Text(
          Formatters.currency(amount, symbol),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}