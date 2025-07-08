import 'dart:async';

import 'package:e_ihale_clone/screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/flip_card_timer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:e_ihale_clone/widgets/save_confirmation_dialog.dart';
import 'package:e_ihale_clone/widgets/save_result_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../../utils/colors.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/price_field_widget.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/section_header_widget.dart';
import '../../../../../services/firestore_service.dart';
import 'auctions_page_details.dart';

class BidPage extends StatefulWidget {
  final Map<String, dynamic> auction;

  const BidPage({super.key, required this.auction});

  @override
  _BidPageState createState() => _BidPageState();
}

class _BidPageState extends State<BidPage> {
  final TextEditingController _bidWholeController = TextEditingController();
  final TextEditingController _bidFractionalController = TextEditingController(text: '00');
  final TextEditingController _depositController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late double minBidPrice;

  late DateTime createdAt;
  late DateTime endAt;
  late Timer _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();

    String startPrice = (widget.auction['startPrice'] ?? '0')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    String minIncrement = (widget.auction['minBid'] ?? '0')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    double startPriceValue = double.tryParse(startPrice) ?? 0.0;
    double minIncrementValue = double.tryParse(minIncrement) ?? 0.0;
    minBidPrice = startPriceValue + minIncrementValue;

    setDefaultBidPrice();

    createdAt =
        (widget.auction['createdAt'] as Timestamp?)?.toDate().toLocal() ?? DateTime.now();
    endAt = createdAt.add(const Duration(hours: 24));

    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemainingTime());
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    setState(() {
      _remainingTime = endAt.difference(now).isNegative ? Duration.zero : endAt.difference(now);
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
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        title: const Text('Teklif Verme Sayfası'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _showSaveConfirmationDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Fiyat Bilgileri'),
            DisabledTextField(
              controller: TextEditingController(text: '₺${widget.auction['startPrice'] ?? '0'}'),
              label: 'Başlangıç Fiyatı',
              icon: Icons.monetization_on,
            ),
            DisabledTextField(
              controller: TextEditingController(text: '₺${widget.auction['minBid'] ?? '0'}'),
              label: 'Min. Artış',
              icon: Icons.add,
            ),
            DisabledTextField(
              controller: TextEditingController(text: '${widget.auction['deposit'] ?? '0'}'),
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

            // GERİ SAYIM SAYAÇ
            const SizedBox(height: 16),
            Center(child: _buildCountdownTimer()),

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
                  ),
                  DisabledTextField(
                    controller: _depositController,
                    label: 'Kapora Bedeli (₺)',
                    icon: Icons.lock,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownTimer() {
    if (_remainingTime == Duration.zero) {
      return const Text(
        'Süre doldu',
        style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    final hours = _remainingTime.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = _remainingTime.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0');

    return FlipCardTimer(remainingTime: _remainingTime);
  }

  void _showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => SaveConfirmationDialog(
        onSave: _checkBid,
      ),
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
    _depositController.text = NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(deposit);
  }
}
