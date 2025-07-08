import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../utils/colors.dart';
import '../my_auctions_page_detail.dart';

class AuctionCard extends StatelessWidget {
  final Map<String, dynamic> auction;

  const AuctionCard({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = auction['imageUrl'] ?? '';
    final String fallbackImage = 'assets/images/urun_gorseli_hazirlaniyor_foto.jpg';
    final DateTime createdAt = (auction['createdAt'] as Timestamp).toDate();
    final DateTime endAt = createdAt.add(const Duration(hours: 24));
    final DateFormat dateFormat = DateFormat('EEEE, d MMMM yyyy - HH:mm', 'tr_TR');

    Widget infoRow(IconData icon, String label, String? value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            SizedBox(
              width: 120,
              child: Text(
                '$label:',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value ?? '-',
                    maxLines: 2, // İlk 2 satırı göstermek için
                    overflow: TextOverflow.ellipsis, // Devamını ... ile göstermek için
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  if ((value ?? '').length > 40) // Metnin uzunluğuna bağlı bir kontrol
                    const Text(
                      '......... devamını oku',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AuctionDetailPage(auction: auction),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl.isNotEmpty ? imageUrl : '',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Image.asset(
                    fallbackImage,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auction['productName'] ?? 'Ürün Adı',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  infoRow(Icons.category, 'Kategori', auction['category']),
                  infoRow(Icons.precision_manufacturing, 'Marka', auction['brand']),
                  infoRow(Icons.precision_manufacturing_outlined, 'Model', auction['model']),
                  infoRow(Icons.description, 'Açıklama', auction['description']),
                  infoRow(Icons.attach_money, 'Başlangıç Fiyatı', '₺${auction['startPrice']}'),
                  infoRow(Icons.trending_up, 'Minimum Teklif', '₺${auction['minBid'] ?? '-'}'),
                  infoRow(Icons.lock, 'Teminat', '${auction['deposit'] ?? '-'}'),
                  infoRow(Icons.calendar_today, 'İhale Başlangıç', dateFormat.format(createdAt)),
                  infoRow(Icons.schedule, 'İhale Bitiş', dateFormat.format(endAt)),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AuctionDetailPage(auction: auction),
                          ),
                        );
                      },
                      icon: Icon(Icons.arrow_forward, color: AppColors.primaryColor),
                      label: Text(
                        'İhalenin Ayrıntılarına Git',
                        style: TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}