enum CategoryType { income, expense }

class CategoryModel {
  final String id;
  final String name;
  final CategoryType type;
  final String userId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.userId,
  });

  factory CategoryModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return CategoryModel(
      id: id,
      name: json['name'] ?? '',
      type: json['type'] == 'income'
          ? CategoryType.income
          : CategoryType.expense,
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type == CategoryType.income ? 'income' : 'expense',
      'userId': userId,
    };
  }
}