import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../services/firestore_service.dart';
import '../../../../../utils/colors.dart';
import '../../../../../widgets/loading_screen.dart';
import '../../../../../widgets/save_result_dialog.dart';
import '../../../../../widgets/save_confirmation_dialog.dart';
import '../my_auctions_page_detail.dart';

class AuctionCard extends StatefulWidget {
  final Map<String, dynamic> auction;
  final VoidCallback onRefresh; // Yeni eklendi

  const AuctionCard({super.key, required this.auction, required this.onRefresh});

  @override
  State<AuctionCard> createState() => _AuctionCardState();
}

class _AuctionCardState extends State<AuctionCard> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startImageSlider();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startImageSlider() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= (widget.auction['imageUrls'] as List).length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _deleteAuction() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const LoadingScreen(message: 'İhale siliniyor...'),
    );

    try {
      await _firestoreService.deleteAuction(widget.auction['id']);
      Navigator.pop(context); // Loading dialog kapat

      // Başarıyla silindi mesajı göster
      await showDialog(
        context: context,
        builder: (_) => const SaveResultDialog(
          isSuccess: true,
          message: 'İhale başarıyla silindi.',
        ),
      );

      // Sayfayı yenile (geri dönmeden kal)
      widget.onRefresh();

    } catch (e) {
      Navigator.pop(context); // Loading dialog kapat
      showDialog(
        context: context,
        builder: (_) => const SaveResultDialog(
          isSuccess: false,
          message: 'İhale silinirken bir hata oluştu. Lütfen tekrar deneyiniz.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = List<String>.from(widget.auction['imageUrls'] ?? []);
    String fallbackImage = 'assets/images/urun_gorseli_hazirlaniyor_foto.jpg';
    final DateTime createdAt = (widget.auction['createdAt'] as Timestamp).toDate();
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  if ((value ?? '').length > 40)
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
            builder: (_) => MyAuctionsPageDetail(auction: widget.auction),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: imageUrls.isNotEmpty
                      ? SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: imageUrls.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  )
                      : Image.asset(
                    fallbackImage,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (imageUrls.length > 1) ...[
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.7)),
                      onPressed: () {
                        if (_currentPage > 0) {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.7)),
                      onPressed: () {
                        if (_currentPage < imageUrls.length - 1) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(imageUrls.length, (index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.auction['productName'] ?? 'Ürün Adı',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(flex: 1,),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => SaveConfirmationDialog(
                                    onSave: _deleteAuction,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text('Sil', style: TextStyle(color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  infoRow(Icons.category, 'Kategori', widget.auction['category']),
                  infoRow(Icons.precision_manufacturing, 'Marka', widget.auction['brand']),
                  infoRow(Icons.precision_manufacturing_outlined, 'Model', widget.auction['model']),
                  infoRow(Icons.description, 'Açıklama', widget.auction['description']),
                  infoRow(Icons.attach_money, 'Başlangıç Fiyatı', '₺${widget.auction['startPrice']}'),
                  infoRow(Icons.trending_up, 'Minimum Teklif', '₺${widget.auction['minBid'] ?? '-'}'),
                  infoRow(Icons.lock, 'Teminat', '${widget.auction['deposit'] ?? '-'}'),
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
                            builder: (_) => MyAuctionsPageDetail(auction: widget.auction),
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