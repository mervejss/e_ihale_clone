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
      'rol': 'normal', // << rol burada atanıyor

    });
  }


  // İhale oluşturma fonksiyonu
  Future<void> createAuction({
    required String createdBy,
    required String productName,
    required String brand,
    required String model,
    required String description,
    required String startPrice,
    required String minBid,
    required String category,
    required String deposit,
    required List<String> imageUrls,
    required DateTime createdAt,
  }) async {
    final auctionDoc = _db.collection('auctions').doc();

    await auctionDoc.set({
      'createdBy': createdBy,
      'productName': productName,
      'brand': brand,
      'model': model,
      'description': description,
      'startPrice': startPrice,
      'minBid': minBid,
      'category': category,
      'deposit': deposit,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
    });
  }

  Future<List<Map<String, dynamic>>> getUserAuctions(String uid) async {
    final querySnapshot = await _db.collection('auctions')
        .where('createdBy', isEqualTo: uid)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}
