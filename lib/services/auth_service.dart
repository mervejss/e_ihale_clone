import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<User?> registerWithEmailAndPasswordExtended({
    required String email,
    required String password,
    required String ad,
    required String soyad,
    required String telefon,
    required String firma,
    required String vkn,
    required String adres,

  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Firestore'a kullanıcı detaylarını kaydet
        await _firestoreService.saveUserDetails(
          uid: user.uid,
          ad: ad,
          soyad: soyad,
          telefon: telefon,
          firma: firma,
          vkn: vkn,
          adres: adres,
          email: email,
        );
      }
      await user!.sendEmailVerification();

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Kayıt olurken bir hata oluştu.");
    }
  }

  // E-mail & şifre ile kayıt olma
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Kayıt olurken bir hata oluştu.");
    }
  }
  // E-mail & şifre ile giriş yapma
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Giriş yapılırken bir hata oluştu.");
    }
  }


}
