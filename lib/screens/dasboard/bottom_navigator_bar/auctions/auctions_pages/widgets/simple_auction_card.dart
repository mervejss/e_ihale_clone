import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../services/firestore_service.dart';
import '../../../../../../utils/colors.dart';
import '../../../../../../widgets/loading_screen.dart';
import '../../../../../../widgets/save_confirmation_dialog.dart';
import '../../../../../../widgets/save_result_dialog.dart';
import '../auctions_page_details.dart';

class SimpleAuctionCard extends StatefulWidget {
  final Map<String, dynamic> auction;

  const SimpleAuctionCard({super.key, required this.auction});

  @override
  State<SimpleAuctionCard> createState() => _SimpleAuctionCardState();
}

class _SimpleAuctionCardState extends State<SimpleAuctionCard> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  bool isFavorite = false; // Track the favorite state
  String? userId; // Nullable userId





  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startImageSlider();
    _fetchCurrentUser();
  }

  void _fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      await _checkIfFavorite(); // Burada çağır, üstte değil!
    }
  }

  Future<void> _checkIfFavorite() async {
    if (userId == null) return;

    final favorites = await FirestoreService().getFavoriteAuctions(userId!);
    setState(() {
      isFavorite = favorites.contains(widget.auction['id']);
    });
  }

  Future<void> _toggleFavorite() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce giriş yapın!')),
      );
      return;
    }

    showDialog(context: context, builder: (_) => const LoadingScreen());

    try {
      await FirestoreService().toggleFavorite(userId!, widget.auction['id'], !isFavorite)
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('İşlem zaman aşımına uğradı');
      });

      setState(() {
        isFavorite = !isFavorite;
      });

      // İlk önce loading dialogunu kapat
      Navigator.pop(context);

      // Sonra sonucu gösteren dialogu aç
      showDialog(
        context: context,
        builder: (_) => SaveResultDialog(
          isSuccess: true,
          message: isFavorite ? 'Favorilere eklendi.' : 'Favorilerden çıkarıldı.',
        ),
      );
    } catch (e) {
      debugPrint('Error: $e');

      // Hata durumunda da önce loading dialog kapatılır
      Navigator.pop(context);

      // Sonra hata mesajını gösteren dialog
      showDialog(
        context: context,
        builder: (_) => SaveResultDialog(
          isSuccess: false,
          message: 'Favori işlemi başarısız. Hata: $e',
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    List<String> imageUrls = List<String>.from(widget.auction['imageUrls'] ?? []);
    String fallbackImage = 'assets/images/urun_gorseli_hazirlaniyor_foto.jpg';
    final DateTime createdAt = (widget.auction['createdAt'] as Timestamp).toDate();
    final DateTime endAt = createdAt.add(const Duration(hours: 24));
    final DateFormat dateFormat = DateFormat('d MMMM yyyy - HH:mm', 'tr_TR');


    return Card(
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
              Positioned(
                right: 50,
                top: 50,
                bottom: 50,
                left: 50,

                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,size: 55,
                  ),
                  onPressed: _toggleFavorite,
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
                Center(
                  child: Text(
                    widget.auction['productName'] ?? 'Ürün Adı',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const Divider(color: Colors.grey),
                const SizedBox(height: 8),
                _infoRow(Icons.attach_money, 'Başlangıç Fiyatı', '₺${widget.auction['startPrice']}'),
                _infoRow(Icons.calendar_today, 'İhale Başlangıç', dateFormat.format(createdAt)),
                _infoRow(Icons.schedule, 'İhale Bitiş', dateFormat.format(endAt)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      // Detay sayfasına git
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AuctionsPageDetails(auction: widget.auction),
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
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
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
}