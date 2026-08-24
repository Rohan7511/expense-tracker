import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/expense_tile.dart';
import '../widgets/empty_state.dart';
import 'add_expense_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().reload();
      context.read<CategoryProvider>().reload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _ExpenseListTab(),
      const StatisticsScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddExpenseScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _ExpenseListTab extends StatelessWidget {
  const _ExpenseListTab();

  @override
  Widget build(BuildContext context) {
    final exp = context.watch<ExpenseProvider>();
    final cats = context.watch<CategoryProvider>();
    final settings = context.watch<SettingsProvider>();
    final list = exp.filtered;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by item...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onChanged: exp.setSearch,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: exp.filterCategoryId == null,
                    onSelected: (_) => exp.setFilter(null),
                  ),
                ),
                ...cats.categories.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c.name),
                      selected: exp.filterCategoryId == c.id,
                      onSelected: (_) {
                        if (exp.filterCategoryId == c.id) {
                          exp.setFilter(null);
                        } else {
                          exp.setFilter(c.id);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(
              icon: Icons.receipt_long,
              title: 'No expenses found',
              subtitle: 'Tap "Add Expense" to create one.',
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final e = list[i];
                final cat = cats.findById(e.categoryId);
                return ExpenseTile(
                  expense: e,
                  categoryName: cat?.name ?? 'Unknown',
                  currencySymbol: settings.currencySymbol,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddExpenseScreen(expense: e),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}