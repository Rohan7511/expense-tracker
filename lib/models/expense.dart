class Expense {
  final String id;
  final double amount;
  final String items;
  final String categoryId;
  final DateTime date;

  Expense({
    required this.id,
    required this.amount,
    required this.items,
    required this.categoryId,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'items': items,
    'categoryId': categoryId,
    'date': date.toIso8601String(),
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'] as String,
    amount: (map['amount'] as num).toDouble(),
    items: map['items'] as String,
    categoryId: map['categoryId'] as String,
    date: DateTime.parse(map['date'] as String),
  );

  Expense copyWith({
    String? id,
    double? amount,
    String? items,
    String? categoryId,
    DateTime? date,
  }) =>
      Expense(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        items: items ?? this.items,
        categoryId: categoryId ?? this.categoryId,
        date: date ?? this.date,
      );
}