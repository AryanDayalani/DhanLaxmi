class Expense {
  final int? id; // Will be auto-incremented
  final String category;
  final String note;
  final DateTime date; // Store as string for now (e.g., 2025-06-28)
  final double amount;

  Expense({
    this.id,
    required this.category,
    required this.note,
    required this.date,
    required this.amount,
  });

  // Convert to map for SQLite insert
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
      'amount': amount,
    };
  }

  // Create object from map (fetching from DB)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      category: map['category'],
      note: map['note'],
      date: DateTime.parse(map['date'] as String),
      amount: map['amount'],
    );
  }
}
