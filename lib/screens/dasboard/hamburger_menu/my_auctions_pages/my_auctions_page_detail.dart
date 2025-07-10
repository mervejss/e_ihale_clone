import 'dart:async';
import 'dart:io'; // Import for handling file operations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_ihale_clone/screens/dasboard/bottom_navigator_bar/auctions/auctions_page.dart';
import 'package:e_ihale_clone/screens/dasboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Import for picking images
import '../../../../../utils/colors.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/section_header_widget.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/text_field_widget.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/disabled_text_field_widget.dart';
import '../../../../../screens/dasboard/bottom_navigator_bar/auctions/auctions_pages/widgets/dropdown_category_widget.dart';
import '../../../../services/firestore_service.dart';
import '../../../../widgets/loading_screen.dart';
import '../../../../widgets/save_confirmation_dialog.dart';
import '../../../../widgets/save_result_dialog.dart';
import '../../bottom_navigator_bar/auctions/auctions_pages/widgets/photo_iew_age.dart';

class MyAuctionsPageDetail extends StatefulWidget {
  final Map<String, dynamic> auction;

  const MyAuctionsPageDetail({super.key, required this.auction});

  @override
  State<MyAuctionsPageDetail> createState() => _MyAuctionsPageDetailState();
}

class _MyAuctionsPageDetailState extends State<MyAuctionsPageDetail> {
  late TextEditingController productNameController;
  late TextEditingController brandController;
  late TextEditingController modelController;
  late TextEditingController descriptionController;
  late String selectedCategory;
  bool isExpanded = false;
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _imageTimer;
  List<File> _selectedImages = [];
  bool _photoError = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startImageSlider();

    productNameController = TextEditingController(text: widget.auction['productName']);
    brandController = TextEditingController(text: widget.auction['brand']);
    modelController = TextEditingController(text: widget.auction['model']);
    descriptionController = TextEditingController(text: widget.auction['description']);
    selectedCategory = widget.auction['category'];
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const LoadingScreen();
        },
      );

      // 1. Eğer yeni fotoğraf seçilmişse, önce onları upload et ve Firestore'u güncelle
      if (_selectedImages.isNotEmpty) {
        await firestoreService.updateAuctionImages(auctionId, _selectedImages);
      }

      // 2. Diğer alanları güncelle (foto URL'leri updateAuctionImages içinde güncellendi)
      await firestoreService.updateAuction(auctionId, {
        'productName': productNameController.text,
        'brand': brandController.text,
        'model': modelController.text,
        'description': descriptionController.text,
        'category': selectedCategory,
      });

      _showSaveResultDialog(true, 'Yaptığınız değişiklikler kaydedildi.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } catch (e) {
      _showSaveResultDialog(false, 'Değişiklikler kaydedilemedi: $e');
    }
  }


  void _showSaveResultDialog(bool isSuccess, String message) {
    showDialog(
      context: context,
      builder: (context) => SaveResultDialog(isSuccess: isSuccess, message: message),
    );
  }

  void _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
        _photoError = _selectedImages.isEmpty;
      });
    }
  }

  void _removeAllImages() {
    setState(() {
      _selectedImages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime createdAt = (widget.auction['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    DateTime endAt = createdAt.add(Duration(hours: 24));
    List<String> imageUrls = List<String>.from(widget.auction['imageUrls'] ?? []);
    String fallbackImage = 'assets/images/urun_gorseli_hazirlaniyor_foto.jpg';

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        title: const Text('İhale Detayları'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _showSaveConfirmationDialog();

            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'İhale Görselleri'),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 5,
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
                if (imageUrls.length > 1) ...[
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
            SectionHeader(title: 'İhale Fotoğraflarını Güncelleme'),
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
                if (_selectedImages.isNotEmpty)
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
              child: _selectedImages.isNotEmpty
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ReorderableListView(
                      scrollDirection: Axis.horizontal,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = _selectedImages.removeAt(oldIndex);
                          _selectedImages.insert(newIndex, item);
                        });
                      },
                      children: _selectedImages.map((image) {
                        final index = _selectedImages.indexOf(image);
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
                                    image,
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

  // Implement any additional methods for your functionalities
  void _showImageOptions(BuildContext context, String imagePath) {
    // Implement the image options like deletion or viewing
  }
}