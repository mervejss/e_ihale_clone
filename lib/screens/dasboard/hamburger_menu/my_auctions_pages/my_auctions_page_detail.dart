import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/colors.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/section_header_widget.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/text_field_widget.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/disabled_text_field_widget.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/dropdown_category_widget.dart';
import '../../../../services/firestore_service.dart';
import '../../../../widgets/save_confirmation_dialog.dart';
import '../../../../widgets/save_result_dialog.dart';

class AuctionDetailPage extends StatefulWidget {
  final Map<String, dynamic> auction;

  const AuctionDetailPage({super.key, required this.auction});

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage> {
  late TextEditingController productNameController;
  late TextEditingController brandController;
  late TextEditingController modelController;
  late TextEditingController descriptionController;
  late String selectedCategory;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    productNameController = TextEditingController(text: widget.auction['productName']);
    brandController = TextEditingController(text: widget.auction['brand']);
    modelController = TextEditingController(text: widget.auction['model']);
    descriptionController = TextEditingController(text: widget.auction['description']);
    selectedCategory = widget.auction['category'];
  }

  void _showSaveConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => SaveConfirmationDialog(onSave: _saveChanges),
    );
  }

  Future<void> _saveChanges() async {
    FirestoreService firestoreService = FirestoreService();
    String? auctionId = widget.auction['id'];

    if (auctionId == null) {
      _showSaveResultDialog(false, 'Döküman ID bulunamadı.');
      return;
    }

    try {
      await firestoreService.updateAuction(auctionId, {
        'productName': productNameController.text,
        'brand': brandController.text,
        'model': modelController.text,
        'description': descriptionController.text,
        'category': selectedCategory,
      });

      _showSaveResultDialog(true, 'Yaptığınız değişiklikler kaydedildi.');
    } catch (e) {
      _showSaveResultDialog(false, 'Değişiklikler kaydedilemedi.');
    }
  }

  void _showSaveResultDialog(bool isSuccess, String message) {
    showDialog(
      context: context,
      builder: (context) => SaveResultDialog(isSuccess: isSuccess, message: message),
    );
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _showSaveConfirmationDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'Ürün Bilgileri'),
            CustomTextField(
              controller: productNameController,
              label: 'Ürün Adı',
              icon: Icons.label,
              isRequired: true,
            ),
            CustomTextField(
              controller: brandController,
              label: 'Marka',
              icon: Icons.branding_watermark,
              isRequired: true,
            ),
            CustomTextField(
              controller: modelController,
              label: 'Model',
              icon: Icons.device_hub,
              isRequired: true,
            ),
            SectionHeader(title: 'Açıklama'),
            Stack(
              children: [
                TextFormField(
                  controller: descriptionController,
                  maxLines: isExpanded ? null : 1,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                    prefixIcon: const Icon(Icons.description, color: AppColors.primaryColor),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                    filled: true,
                    fillColor: AppColors.secondaryColor,
                  ),
                  style: const TextStyle(color: Colors.black),
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
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    descriptionController.text += '\n';
                    setState(() {});
                  },
                  icon: const Icon(Icons.add, color: AppColors.primaryColor),
                  label: const Text(
                    'Yeni Satır Ekle',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SectionHeader(title: 'Kategori Seçimi'),
            DropdownCategory(
              selectedCategory: selectedCategory,
              categoryIcons: const {
                'Telefon': Icons.phone_android,
                'Bilgisayar': Icons.computer,
                'Aksesuar': Icons.headphones,
                'Anakart': Icons.memory,
                'Teknik parça': Icons.build,
              },
              onChanged: (val) => setState(() => selectedCategory = val!),
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
          ],
        ),
      ),
    );
  }
}