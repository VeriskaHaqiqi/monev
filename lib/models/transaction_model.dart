enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? note;
  final String userId;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    required this.userId,
  });

  factory TransactionModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return TransactionModel(
      id: id,
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      categoryId: json['categoryId'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] ?? 0),
      note: json['note'],
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'categoryId': categoryId,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'userId': userId,
    };
  }
}