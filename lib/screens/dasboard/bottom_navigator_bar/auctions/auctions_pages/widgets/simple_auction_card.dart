import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../utils/colors.dart';
import '../../../../hamburger_menu/my_auctions_pages/my_auctions_page_detail.dart';
import '../auctions_page_details.dart';

class SimpleAuctionCard extends StatelessWidget {
  final Map<String, dynamic> auction;

  const SimpleAuctionCard({super.key, required this.auction});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = auction['imageUrl'] ?? '';
    final String fallbackImage = 'assets/images/urun_gorseli_hazirlaniyor_foto.jpg';
    final DateTime createdAt = (auction['createdAt'] as Timestamp).toDate();
    final DateTime endAt = createdAt.add(const Duration(hours: 24));
    final DateFormat dateFormat = DateFormat('EEEE, d MMMM yyyy - HH:mm', 'tr_TR');

    Widget infoRow(IconData icon, String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
                  Center(
                    child: Text(
                      auction['productName'] ?? 'Ürün Adı',
                      style: TextStyle(
                        fontSize: 25, // Larger font size
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor, // Use primary color
                      ),
                    ),
                  ),
                  const Divider(color: Colors.grey), // Divider under product name
                  const SizedBox(height: 8),


                  infoRow(Icons.attach_money, 'Başlangıç Fiyatı', '₺${auction['startPrice']}'),
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
                            builder: (_) => AuctionsPageDetails(auction: auction),
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