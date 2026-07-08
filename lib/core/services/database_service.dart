import 'package:firebase_database/firebase_database.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // ===================== TRANSAKSI =====================

  // Tambah transaksi baru
  Future<void> addTransaction(TransactionModel transaction) async {
    final newRef = _db.child('transactions').push();
    await newRef.set(transaction.toJson());
  }

  // Ambil semua transaksi milik satu user (realtime stream)
  Stream<List<TransactionModel>> getTransactions(String userId) {
    return _db.child('transactions').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <TransactionModel>[];

      final list = data.entries
          .map((e) => TransactionModel.fromJson(e.key, e.value))
          .where((t) => t.userId == userId)
          .toList();

      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    }).asBroadcastStream(); // ← tambahkan ini
  }

  // Update transaksi
  Future<void> updateTransaction(TransactionModel transaction) async {
    await _db.child('transactions').child(transaction.id).update(transaction.toJson());
  }

  // Hapus transaksi
  Future<void> deleteTransaction(String transactionId) async {
    await _db.child('transactions').child(transactionId).remove();
  }

  // ===================== KATEGORI =====================

  Future<void> addCategory(CategoryModel category) async {
    final newRef = _db.child('categories').push();
    await newRef.set(category.toJson());
  }

  Stream<List<CategoryModel>> getCategories(String userId) {
    return _db.child('categories').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <CategoryModel>[];

      return data.entries
          .map((e) => CategoryModel.fromJson(e.key, e.value))
          .where((c) => c.userId == userId)
          .toList();
    }).asBroadcastStream(); // ← tambahkan ini
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _db.child('categories').child(category.id).update(category.toJson());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db.child('categories').child(categoryId).remove();
  }

  // Cek apakah kategori masih dipakai transaksi (buat validasi hapus kategori)
  Future<bool> isCategoryUsed(String categoryId) async {
    final snapshot = await _db.child('transactions').get();
    if (!snapshot.exists) return false;

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.values.any((t) => t['categoryId'] == categoryId);
  }
}