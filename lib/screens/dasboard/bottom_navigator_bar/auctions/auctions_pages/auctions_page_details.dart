import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_ihale_clone/screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/flip_card_timer.dart';
import 'package:e_ihale_clone/screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/photo_iew_age.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../utils/colors.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/section_header_widget.dart';
import '../../../../../widgets/save_result_dialog.dart';
import 'bid_page.dart';

class DisabledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final int? maxLines;

  const DisabledTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.icon,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: false,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryColor) : null,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor),
            borderRadius: BorderRadius.circular(8.0),
          ),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}

class AuctionsPageDetails extends StatefulWidget {
  final Map<String, dynamic> auction;

  const AuctionsPageDetails({super.key, required this.auction});

  @override
  State<AuctionsPageDetails> createState() => _AuctionsPageDetailsState();
}

class _AuctionsPageDetailsState extends State<AuctionsPageDetails> {
  bool isExpanded = false;
  late DateTime createdAt;
  late DateTime endAt;
  late Timer _timer;
  Duration _remainingTime = Duration.zero;

  late PageController _pageController;
  int _currentPage = 0;
  late Timer _imageTimer;

  List<Map<String, dynamic>> bids = []; // Teklifler için bir liste

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startImageSlider();

    createdAt = widget.auction['createdAt']?.toDate()?.toLocal() ?? DateTime.now();
    endAt = createdAt.add(const Duration(hours: 24));

    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemainingTime());

    _fetchBids(); // Teklifleri çek

  }

  Future<void> _fetchBids() async {
    final auctionId = widget.auction['id'];

    final QuerySnapshot bidSnapshot = await FirebaseFirestore.instance
        .collection('bids')
        .where('auctionId', isEqualTo: auctionId)
        .orderBy('createdAt', descending: false)
        .get();

    setState(() {
      bids = bidSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }
  List<Widget> _buildBidList() {
    return List<Widget>.generate(bids.length, (index) {
      final bid = bids[index];
      final formattedDate = DateFormat('dd.MM.yyyy HH:mm:ss', 'tr_TR')
          .format((bid['createdAt'] as Timestamp).toDate().toLocal());

      bool isWinningBid = _remainingTime == Duration.zero && index == bids.length - 1;

      return Column(
        children: [
          Card(
            color: Colors.white70,
            elevation: 1.5,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isWinningBid ? Colors.red : Colors.grey.shade300,
                width: isWinningBid ? 2.0 : 0.6,
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryColor,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(
                      text: 'Teklif: ',
                      style: TextStyle(fontWeight: FontWeight.bold,color: AppColors.primaryColor),
                    ),
                    TextSpan(
                      text: '${bid['bidAmount']} ₺',
                      style: const TextStyle(fontStyle: FontStyle.italic,fontSize: 18),
                    ),
                    if (isWinningBid)
                      const TextSpan(
                        text: '\n(İhaleyi Kazanan Teklif)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red,fontSize: 20),
                      ),
                  ],
                ),
              ),
              subtitle: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodySmall,
                  children: [
                    const TextSpan(
                      text: 'Tarih: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: formattedDate,
                      style: const TextStyle(fontStyle: FontStyle.italic,color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
              trailing: Icon(Icons.timeline, color: AppColors.primaryColor),
            ),
          ),

        ],
      );
    });
  }


  void _updateRemainingTime() {
    final now = DateTime.now();
    setState(() {
      _remainingTime = endAt.difference(now).isNegative ? Duration.zero : endAt.difference(now);
    });
  }
  void _startImageSlider() {
    _imageTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    DateTime createdAt = widget.auction['createdAt']?.toDate()?.toLocal() ?? DateTime.now();
    DateTime endAt = createdAt.add(const Duration(hours: 24));
    List<String> imageUrls = List<String>.from(widget.auction['imageUrls'] ?? []);
    String fallbackImage = 'assets/images/urun_gorseli_hazirlaniyor_foto.jpg';

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        title: const Text('İhale Detayları'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Ürün Görselleri'),

            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryColor, // Ana renk
                      width: 5, // Kalınlık
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhotoViewPage(
                              images: imageUrls,
                              initialIndex: _currentPage,
                            ),
                          ),
                        );
                      },
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
                  ),
                ),

                // --- OK BUTONLARI ---
                if (imageUrls.length > 1) ...[
                  // Sol ok sadece ilk foto değilse görünür
                  if (_currentPage > 0)
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

                  // Sağ ok sadece son foto değilse görünür
                  if (_currentPage < imageUrls.length - 1)
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

                  // Zoom butonu her durumda görünür
                  Positioned(
                    left: 50,
                    top: 50,
                    bottom: 50,
                    right: 50,
                    child: IconButton(
                      icon: Icon(
                        Icons.zoom_in_outlined,
                        color: Colors.white.withOpacity(0.7),
                        size: 65,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhotoViewPage(
                              images: imageUrls,
                              initialIndex: _currentPage,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Slider noktaları
                  Positioned(
                    bottom: 30,
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
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Kaçıncı foto
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        '[ ${_currentPage + 1} / ${imageUrls.length} ]',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],

              ],
            ),

            const SizedBox(height: 16),
            SectionHeader(title: 'Ürün Bilgileri'),
            DisabledTextField(
              controller: TextEditingController(text: widget.auction['productName']),
              label: 'Ürün Adı',
              icon: Icons.label,
            ),
            DisabledTextField(
              controller: TextEditingController(text: widget.auction['brand']),
              label: 'Marka',
              icon: Icons.branding_watermark,
            ),
            DisabledTextField(
              controller: TextEditingController(text: widget.auction['model']),
              label: 'Model',
              icon: Icons.device_hub,
            ),
            SectionHeader(title: 'Kategori Bilgisi'),
            DisabledTextField(
              controller: TextEditingController(text: widget.auction['category']),
              label: 'Kategori',
              icon: {
                'Telefon': Icons.phone_android,
                'Bilgisayar': Icons.computer,
                'Aksesuar': Icons.headphones,
                'Anakart': Icons.memory,
                'Teknik parça': Icons.build,
              }[widget.auction['category']]!,
            ),
            SectionHeader(title: 'Fiyat Bilgileri'),
            DisabledTextField(
              controller: TextEditingController(text: '₺${widget.auction['startPrice']}'),
              label: 'Başlangıç Fiyatı',
              icon: Icons.monetization_on,
            ),
            DisabledTextField(
              controller: TextEditingController(text: '₺${widget.auction['minBid']}'),
              label: 'Min. Artış',
              icon: Icons.add,
            ),
            DisabledTextField(
              controller: TextEditingController(text: '${widget.auction['deposit']}'),
              label: 'Kapora Bedeli',
              icon: Icons.lock,
            ),
            SectionHeader(title: 'Tarih Bilgileri'),
            DisabledTextField(
              controller: TextEditingController(
                text: DateFormat('dd.MM.yyyy HH:mm:ss', 'tr_TR').format(createdAt),
              ),
              label: 'Oluşturulma Tarihi',
              icon: Icons.access_time,
            ),
            DisabledTextField(
              controller: TextEditingController(
                text: DateFormat('dd.MM.yyyy HH:mm:ss', 'tr_TR').format(endAt),
              ),
              label: 'Bitiş Tarihi',
              icon: Icons.timer_off,
            ),
            const SizedBox(height: 16),
            Center(child: _buildCountdownTimer()), // Sayaç burada çağrılıyor

            SectionHeader(title: 'Bu İhaleye Verilen Teklifler'),
            bids.isEmpty
                ? const Center(
              child: Text(
                'Bu ihale için henüz bir teklif yok.',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : Column(children: _buildBidList(),),


            SectionHeader(title: 'Açıklama'),
            Stack(
              children: [
                DisabledTextField(
                  controller: TextEditingController(text: widget.auction['description']),
                  label: 'Açıklama',
                  icon: Icons.description,
                  maxLines: isExpanded ? null : 1,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                    color: AppColors.primaryColor,
                    onPressed: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _remainingTime == Duration.zero
                  ? Colors.grey.shade500 // Süre bittiyse buton grimsi
                  : AppColors.secondaryColor, // Normal renk
              foregroundColor: _remainingTime == Duration.zero
                  ? Colors.white70 // Süre bittiyse buton grimsi
                  : AppColors.primaryColor, // Normal renk
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: _remainingTime == Duration.zero
                ? () {
              showDialog(
                context: context,
                builder: (context) => const SaveResultDialog(
                  isSuccess: false,
                  message: 'Süre dolduğu için artık bu ihaleye teklif veremezsiniz.',
                ),
              );
            }
                : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BidPage(auction: widget.auction),
                ),
              );
            },
            child: const Text('TEKLİF VER'),
          ),
        ),
      ),


    );
  }
  Widget _buildCountdownTimer() {


    return Column(
      children: [
        FlipCardTimer(remainingTime: _remainingTime),
        if (_remainingTime == Duration.zero)
          const Text(
            'Süre doldu',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
