import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // Stream buat mantau status login secara real-time
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // Registrasi akun baru
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Simpan data tambahan (nama) ke Realtime Database
      await _db.child('users').child(uid).set({
        'name': name,
        'email': email,
        'photoUrl': null,
      });

      return null; // null artinya sukses, tidak ada pesan error
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    }
  }

  // Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e.code);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Ubah kode error Firebase jadi pesan yang gampang dipahami user
  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar, silakan gunakan email lain.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah, minimal 6 karakter.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      default:
        return 'Terjadi kesalahan, silakan coba lagi.';
    }
  }
  Future<void> updateProfile({required String name, String? photoUrl}) async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{'name': name};
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    await _db.child('users').child(uid).update(updates);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;

    final snapshot = await _db.child('users').child(uid).get();
    if (!snapshot.exists) return null;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }
}