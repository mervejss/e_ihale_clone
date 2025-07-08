import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../utils/colors.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/section_header_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    DateTime createdAt = widget.auction['createdAt']?.toDate()?.toLocal() ?? DateTime.now();
    DateTime endAt = createdAt.add(const Duration(hours: 24));

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
    );
  }
}