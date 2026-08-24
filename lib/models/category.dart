class ExpenseCategory {
  final String id;
  final String name;

  ExpenseCategory({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) => ExpenseCategory(
    id: map['id'] as String,
    name: map['name'] as String,
  );
}