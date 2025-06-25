import 'package:cloud_firestore/cloud_firestore.dart';

class UserRoleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Rolü getir (giriş yapan kullanıcı için)
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data()?['rol'];
    } catch (e) {
      return null;
    }
  }

  // Rolü güncelle (örneğin admin panelinden yapılabilir)
  Future<void> updateUserRole(String uid, String newRole) async {
    await _db.collection('users').doc(uid).update({'rol': newRole});
  }
}
