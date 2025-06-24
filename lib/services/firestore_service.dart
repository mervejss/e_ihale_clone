import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Kullanıcı bilgilerini 'users' koleksiyonuna kaydet
  Future<void> saveUserDetails({
    required String uid,
    required String ad,
    required String soyad,
    required String telefon,
    required String firma,
    required String vkn,
    required String adres,
    required String email,
  }) async {
    final userDoc = _db.collection('users').doc(uid);
    await userDoc.set({
      'ad': ad,
      'soyad': soyad,
      'telefon': telefon,
      'firma': firma,
      'vkn': vkn,
      'adres': adres,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
