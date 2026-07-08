class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  // Konversi dari Map (data yang datang dari Realtime Database) ke object Dart
  factory UserModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
    );
  }

  // Konversi dari object Dart ke Map (buat disimpan ke Realtime Database)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}