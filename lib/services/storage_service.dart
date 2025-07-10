import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(String userId, String auctionId, File image) async {
    try {
      final ref = _storage.ref().child('users/$userId/auctions/$auctionId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}