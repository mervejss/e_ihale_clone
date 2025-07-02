// my_auctions_page_detail.dart
import 'package:flutter/material.dart';
import '../../../../utils/colors.dart';

class AuctionDetailPage extends StatelessWidget {
  final Map<String, dynamic> auction;

  const AuctionDetailPage({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    DateTime createdAt = auction['createdAt']?.toDate()?.toLocal() ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('İhale Detayları'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              auction['productName'] ?? '',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.category, 'Kategori', auction['category']),
            _buildDetailRow(Icons.business, 'Marka', auction['brand']),
            _buildDetailRow(Icons.devices, 'Model', auction['model']),
            _buildDetailRow(Icons.description, 'Açıklama', auction['description']),
            _buildDetailRow(Icons.monetization_on, 'Başlangıç Fiyatı', '₺${auction['startPrice']}'),
            _buildDetailRow(Icons.trending_up, 'Min. Artış', '₺${auction['minBid']}'),
            _buildDetailRow(Icons.security, 'Kapora Bedeli', '${auction['deposit']}'),
            _buildDetailRow(Icons.access_time, 'Oluşturulma Tarihi', createdAt.toString().split('.')[0]),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(value?.toString() ?? '', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
