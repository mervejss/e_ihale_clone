import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../../services/firestore_service.dart';
import '../../../../../services/storage_service.dart';
import '../../../../../utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_ihale_clone/screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/section_header_widget.dart';
import 'package:e_ihale_clone/screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/text_field_widget.dart';
import 'package:e_ihale_clone/screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/disabled_text_field_widget.dart';
import 'package:e_ihale_clone/screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/dropdown_category_widget.dart';
import 'package:e_ihale_clone/screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/price_field_widget.dart';

class CreateAuctionPage extends StatefulWidget {
  const CreateAuctionPage({super.key});

  @override
  State<CreateAuctionPage> createState() => _CreateAuctionPageState();
}

class _CreateAuctionPageState extends State<CreateAuctionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startPriceWholeController = TextEditingController();
  final TextEditingController _startPriceFractionalController = TextEditingController();
  final TextEditingController _minBidWholeController = TextEditingController();
  final TextEditingController _minBidFractionalController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();

  String? _selectedCategory;
  List<XFile>? _selectedImages = [];

  final List<String> _categories = [
    'Telefon',
    'Bilgisayar',
    'Aksesuar',
    'Anakart',
    'Teknik parça',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Telefon': Icons.phone_android,
    'Bilgisayar': Icons.computer,
    'Aksesuar': Icons.headphones,
    'Anakart': Icons.memory,
    'Teknik parça': Icons.build,
  };

  bool _photoError = false;

  void _updateDeposit() {
    String whole = _startPriceWholeController.text.replaceAll('.', '');
    String fractional = _startPriceFractionalController.text;
    double price = double.tryParse('$whole.$fractional') ?? 0.0;
    double deposit = price * 0.05;
    _depositController.text = '${NumberFormat.currency(locale: 'tr_TR', symbol: '₺').format(deposit)}';
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      if (images.length > 10) {
        _showImageAlert('En fazla 10 resim seçebilirsiniz.');
      } else {
        setState(() {
          _selectedImages = images;
          _photoError = false;
        });
      }
    }
  }

  void _removeAllImages() {
    setState(() {
      _selectedImages!.clear();
      _photoError = true;
    });
  }

  void _showImageAlert(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _submitForm() async {
    final isValid = _formKey.currentState!.validate();

    setState(() {
      _photoError = _selectedImages == null || _selectedImages!.isEmpty;
    });

    if (isValid && !_photoError) {
      final now = DateTime.now().toLocal();

      // Giriş yapmış kullanıcının uid'sini al
      User? user = FirebaseAuth.instance.currentUser;
      String createdBy = user?.uid ?? '';

      if (createdBy.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı girişi yapılmamış.')),
        );
        return;
      }

      // İhaleyi Firestore'a kaydet
      FirestoreService firestoreService = FirestoreService();
      await firestoreService.createAuction(
        createdBy: createdBy,
        productName: _productNameController.text,
        brand: _brandController.text,
        model: _modelController.text,
        description: _descriptionController.text,
        startPrice: '${_startPriceWholeController.text},${_startPriceFractionalController.text}',
        minBid: '${_minBidWholeController.text},${_minBidFractionalController.text}',
        category: _selectedCategory!,
        deposit: _depositController.text,
        imageUrls: [], // Bu kısmı boş liste olarak bırakıyoruz
        createdAt: now,
      );

      print("Ürün Adı: ${_productNameController.text}");
      print("Marka: ${_brandController.text}");
      print("Model: ${_modelController.text}");
      print("Açıklama: ${_descriptionController.text}");
      print("Başlangıç Fiyatı: ${_startPriceWholeController.text},${_startPriceFractionalController.text}");
      print("Minimum Artış Tutarı: ${_minBidWholeController.text},${_minBidFractionalController.text}");
      print("Kategori: $_selectedCategory");
      print("Kapora Bedeli: ${_depositController.text}");
      print("İhale Oluşturma Zamanı: ${DateFormat('dd.MM.yyyy HH:mm:ss', 'tr_TR').format(now)}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('İhale başarıyla oluşturuldu!')),
      );
    }
  }

  void _showImageOptions(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(File(path)),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        title: const Text('Yeni İhale Ekle', style: TextStyle(color: AppColors.secondaryColor)),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(title: 'Ürün Bilgileri'),
              CustomTextField(
                controller: _productNameController,
                label: 'Ürün Adı',
                hintText: 'Ürün adını buraya giriniz',
                icon: Icons.label,
                isRequired: true,
              ),
              CustomTextField(
                controller: _brandController,
                label: 'Marka',
                hintText: 'Ürün markasını buraya giriniz',
                icon: Icons.branding_watermark,
                isRequired: true,
              ),
              CustomTextField(
                controller: _modelController,
                label: 'Model',
                hintText: 'Ürün modelini buraya giriniz',
                icon: Icons.device_hub,
                isRequired: true,
              ),
              CustomTextField(
                controller: _descriptionController,
                label: 'Açıklama',
                hintText: 'Ürün açıklamasını buraya giriniz',
                icon: Icons.description,
                maxLines: 2,
                isRequired: true,
              ),
              SectionHeader(title: 'Kategori Seçimi'),
              DropdownCategory(
                selectedCategory: _selectedCategory,
                categoryIcons: _categoryIcons,
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              SectionHeader(title: 'Fiyat Bilgileri'),
              PriceField(
                title: 'Başlangıç Fiyatı',
                wholeController: _startPriceWholeController,
                fractionalController: _startPriceFractionalController,
                icon: Icons.monetization_on,
                onUpdate: () {
                  _updateDeposit();
                  _formKey.currentState!.validate();
                },
              ),
              PriceField(
                title: 'Minimum Artış Tutarı',
                wholeController: _minBidWholeController,
                fractionalController: _minBidFractionalController,
                icon: Icons.add,
                onUpdate: () {
                  _updateDeposit();
                  _formKey.currentState!.validate();
                },
              ),
              DisabledTextField(
                controller: _depositController,
                label: 'Kapora Bedeli (₺)',
                icon: Icons.lock,
              ),
              const SizedBox(height: 12),
              SectionHeader(title: 'Fotoğraf Yükleme'),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    onPressed: _pickImages,
                    icon: const Icon(Icons.image, color: AppColors.secondaryColor),
                    label: const Text('Fotoğraf Seç', style: TextStyle(color: AppColors.secondaryColor)),
                  ),
                  const SizedBox(width: 12),
                  if (_selectedImages != null && _selectedImages!.isNotEmpty)
                    InkWell(
                      onTap: _removeAllImages,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade700, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.highlight_remove_sharp, color: Colors.red.shade700, size: 22),
                            const SizedBox(width: 3),
                            Text(
                              'Seçili fotoğrafların tümünü kaldır',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (_photoError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'En az 1 resim seçmelisiniz.',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                height: 150,
                child: _selectedImages != null && _selectedImages!.isNotEmpty
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ReorderableListView(
                        scrollDirection: Axis.horizontal,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final item = _selectedImages!.removeAt(oldIndex);
                            _selectedImages!.insert(newIndex, item);
                          });
                        },
                        children: _selectedImages!.map((image) {
                          final index = _selectedImages!.indexOf(image);
                          return Container(
                            key: ValueKey(image),
                            margin: const EdgeInsets.all(4.0),
                            child: GestureDetector(
                              onTap: () => _showImageOptions(context, image.path),
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.primaryColor, width: 2),
                                    ),
                                    child: Image.file(
                                      File(image.path),
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: AppColors.secondaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Positioned(
                                    bottom: 2,
                                    right: 4,
                                    child: Icon(
                                      Icons.zoom_out_map,
                                      color: AppColors.secondaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Text(
                      'Fotoğrafları kaydırarak sıralamasını değiştirebilirsiniz.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                    const Text(
                      'Fotoğraflara tıklayarak ise yüklediğiniz fotoğrafı daha büyük boyutta görüntüleyebilir ve inceleyebilirsiniz.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
                    : Text(
                  'Fotoğraf seçilmedi',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  onPressed: _submitForm,
                  child: Container(
                    width: 190,
                    child: Row(
                      children: [
                        Icon(Icons.gpp_good_sharp, color: AppColors.secondaryColor),
                        SizedBox(width: 10),
                        Text('Kaydet ve Onaya Gönder',
                            style: TextStyle(color: AppColors.secondaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
