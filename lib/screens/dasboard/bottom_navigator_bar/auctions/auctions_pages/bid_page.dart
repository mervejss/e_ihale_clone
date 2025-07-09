import 'dart:async';
import 'package:e_ihale_clone/screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/section_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../utils/colors.dart';
import 'package:e_ihale_clone/widgets/save_confirmation_dialog.dart';
import 'package:e_ihale_clone/widgets/save_result_dialog.dart';
import '../../../../../services/firestore_service.dart';
import 'auctions_page_details.dart';
import 'package:e_ihale_clone/screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/flip_card_timer.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/price_field_widget.dart';

class BidPage extends StatefulWidget {
  final Map<String, dynamic> auction;

  const BidPage({super.key, required this.auction});

  @override
  _BidPageState createState() => _BidPageState();
}

class _BidPageState extends State<BidPage> {
  final TextEditingController _bidWholeController = TextEditingController();
  final TextEditingController _bidFractionalController = TextEditingController(
    text: '00',
  );
  final TextEditingController _depositController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late double minBidPrice;
  late DateTime createdAt;
  late DateTime endAt;
  late Timer _timer;
  Duration _remainingTime = Duration.zero;

  List<Map<String, dynamic>> bids = [];

  @override
  void initState() {
    super.initState();

    createdAt =
        (widget.auction['createdAt'] as Timestamp?)?.toDate().toLocal() ??
        DateTime.now();
    endAt = createdAt.add(const Duration(hours: 24));

    _updateRemainingTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemainingTime(),
    );

    _fetchBids();
  }

  Future<void> _fetchBids() async {
    final auctionId = widget.auction['id'];

    final QuerySnapshot bidSnapshot = await FirebaseFirestore.instance
        .collection('bids')
        .where('auctionId', isEqualTo: auctionId)
        .orderBy('createdAt', descending: false)
        .get();

    setState(() {
      bids = bidSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _updateMinBidPrice();
    });
  }

  void _updateMinBidPrice() {
    String minIncrement = (widget.auction['minBid'] ?? '0')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    double minIncrementValue = double.tryParse(minIncrement) ?? 0.0;

    if (bids.isEmpty) {
      String startPrice = (widget.auction['startPrice'] ?? '0')
          .replaceAll('.', '')
          .replaceAll(',', '.');

      double startPriceValue = double.tryParse(startPrice) ?? 0.0;
      minBidPrice = startPriceValue + minIncrementValue;
    } else {
      double lastBid = bids.last['bidAmount'];
      minBidPrice = lastBid + minIncrementValue;
    }

    setDefaultBidPrice();
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    setState(() {
      _remainingTime = endAt.difference(now).isNegative
          ? Duration.zero
          : endAt.difference(now);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void setDefaultBidPrice() {
    int wholePart = minBidPrice.floor();
    int fractionalPart = ((minBidPrice - wholePart) * 100).round();

    _bidWholeController.text = wholePart.toString();
    _bidFractionalController.text = fractionalPart.toString().padLeft(2, '0');

    _updateDeposit();
  }

  @override
  Widget build(BuildContext context) {
    bool isAuctionActive = _remainingTime > Duration.zero;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        title: const Text('Teklif Verme Sayfası'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: isAuctionActive ? _showSaveConfirmationDialog : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Fiyat Bilgileri'),
            _buildDisabledTextField(
              '₺${widget.auction['startPrice'] ?? '0'}',
              'Başlangıç Fiyatı',
              Icons.monetization_on,
            ),
            _buildDisabledTextField(
              '₺${widget.auction['minBid'] ?? '0'}',
              'Min. Artış',
              Icons.add,
            ),
            _buildDisabledTextField(
              '${widget.auction['deposit'] ?? '0'}',
              'Kapora Bedeli',
              Icons.lock,
            ),
            SectionHeader(title: 'Tarih Bilgileri'),
            _buildDisabledTextField(
              DateFormat('dd.MM.yyyy HH:mm:ss', 'tr_TR').format(createdAt),
              'Oluşturulma Tarihi',
              Icons.access_time,
            ),
            _buildDisabledTextField(
              DateFormat('dd.MM.yyyy HH:mm:ss', 'tr_TR').format(endAt),
              'Bitiş Tarihi',
              Icons.timer_off,
            ),

            const SizedBox(height: 16),
            Center(child: _buildCountdownTimer()),

            const SizedBox(height: 16),
            SectionHeader(title: 'Bu İhaleye Verilen Teklifler'),
            bids.isEmpty
                ? const Center(
                    child: Text(
                      'Bu ihale için henüz bir teklif yok.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Column(children: _buildBidList(),),

            SectionHeader(title: 'Yeni Teklif Ver'),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  PriceField(
                    title: 'Yeni Teklif Tutarı',
                    wholeController: _bidWholeController,
                    fractionalController: _bidFractionalController,
                    icon: Icons.monetization_on,
                    onUpdate: () {},
                    isEnabled: isAuctionActive,
                  ),
                  _buildDisabledTextField(
                    _depositController.text,
                    'Kapora Bedeli (₺)',
                    Icons.lock,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBidList() {
    return List<Widget>.generate(bids.length, (index) {
      final bid = bids[index];
      final formattedDate = DateFormat('dd.MM.yyyy HH:mm:ss', 'tr_TR')
          .format((bid['createdAt'] as Timestamp).toDate().toLocal());

      return Column(
        children: [
          Card(
            color: Colors.white70,
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300, width: 0.6),
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
                      style: const TextStyle(fontStyle: FontStyle.italic,color: Colors.red),
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


  Widget _buildDisabledTextField(String text, String label, IconData icon) {
    return DisabledTextField(
      controller: TextEditingController(text: text),
      label: label,
      icon: icon,
    );
  }

  Widget _buildCountdownTimer() {
    if (_remainingTime == Duration.zero) {
      return const Text(
        'Süre doldu',
        style: TextStyle(
          fontSize: 18,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return FlipCardTimer(remainingTime: _remainingTime);
  }

  void _showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => SaveConfirmationDialog(onSave: _checkBid),
    );
  }

  void _checkBid() {
    String whole = _bidWholeController.text.replaceAll('.', '');
    String fractional = _bidFractionalController.text.padLeft(2, '0');
    double price = double.tryParse('$whole.$fractional') ?? 0.0;

    if (price < minBidPrice) {
      showDialog(
        context: context,
        builder: (context) => SaveResultDialog(
          isSuccess: false,
          message: 'Girilen teklif başlangıç fiyatının altında olamaz!',
        ),
      );
    } else {
      _saveBid(price);
    }
  }

  Future<void> _saveBid(double price) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final auctionId = widget.auction['id'];

        if (auctionId == null) {
          throw 'Auction ID is missing!';
        }

        await _firestoreService.saveBid(
          auctionId: auctionId,
          createdBy: user.uid,
          bidAmount: price,
          createdAt: DateTime.now(),
        );

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => SaveResultDialog(
              isSuccess: true,
              message: 'Teklif başarıyla kaydedildi!',
            ),
          );
          _fetchBids(); // Refresh the bid list after saving a new bid
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => SaveResultDialog(
            isSuccess: false,
            message: 'Teklif kaydedilirken bir hata oluştu: $e',
          ),
        );
      }
    }
  }

  void _updateDeposit() {
    String whole = _bidWholeController.text.replaceAll('.', '');
    String fractional = _bidFractionalController.text.padLeft(2, '0');
    double price = double.tryParse('$whole.$fractional') ?? 0.0;
    double deposit = price * 0.05;
    _depositController.text = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
    ).format(deposit);
  }
}
