import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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

  final Color primaryColor = const Color(0xFF1e529b);
  final Color secondaryColor = Colors.white;

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
    if (images != null && images.length <= 10) {
      setState(() {
        _selectedImages = images;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final formattedDate = DateFormat('dd.MM.yyyy HH:mm:ss').format(now);

      print("Ürün Adı: ${_productNameController.text}");
      print("Marka: ${_brandController.text}");
      print("Model: ${_modelController.text}");
      print("Açıklama: ${_descriptionController.text}");
      print("Başlangıç Fiyatı: ${_startPriceWholeController.text},${_startPriceFractionalController.text}");
      print("Minimum Artış Tutarı: ${_minBidWholeController.text},${_minBidFractionalController.text}");
      print("Kategori: $_selectedCategory");
      print("Kapora Bedeli: ${_depositController.text}");
      print("Fotoğraflar: ${_selectedImages!.map((e) => e.name).join(', ')}");
      print("Onay Zamanı: $formattedDate");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: const Text('Yeni İhale Ekle', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Ürün Bilgileri'),
              _buildTextField(
                controller: _productNameController,
                label: 'Ürün Adı',
                icon: Icons.label,
                isRequired: true,
              ),
              _buildTextField(
                controller: _brandController,
                label: 'Marka',
                icon: Icons.branding_watermark,
              ),
              _buildTextField(
                controller: _modelController,
                label: 'Model',
                icon: Icons.device_hub,
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Açıklama',
                icon: Icons.description,
                maxLines: 2,
              ),
              _buildSectionHeader('Kategori Seçimi'),
              _buildDropdownCategory(),
              _buildSectionHeader('Fiyat Bilgileri'),
              _buildPriceField('Başlangıç Fiyatı', _startPriceWholeController, _startPriceFractionalController, Icons.monetization_on),
              _buildPriceField('Minimum Artış Tutarı', _minBidWholeController, _minBidFractionalController, Icons.add),
              _buildDisabledTextField(
                controller: _depositController,
                label: 'Kapora Bedeli (₺)',
                icon: Icons.lock,
              ),
              const SizedBox(height: 12),
              _buildSectionHeader('Fotoğraf Yükleme'),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                    onPressed: _pickImages,
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text('Fotoğraf Seç', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: _selectedImages != null && _selectedImages!.isNotEmpty
                    ? Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages!.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: primaryColor, width: 2),
                                ),
                                child: Image.file(
                                  File(_selectedImages![index].path),
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: primaryColor,
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                      color: secondaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Text(
                      '${_selectedImages!.length} fotoğraf seçildi',
                      style: TextStyle(color: primaryColor),
                    ),
                  ],
                )
                    : Text(
                  'Fotoğraf seçilmedi',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                  ),
                  onPressed: _submitForm,
                  child: Container(
                    width: 190,
                    child: Row(
                      children: [
                        Icon(Icons.gpp_good_sharp,color: Colors.white,),
                        SizedBox(width: 10,),
                        Text('Kaydet ve Onaya Gönder',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, left: 4),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: primaryColor),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: primaryColor),
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            ),
            style: TextStyle(color: Colors.black),
            maxLines: maxLines,
            validator: isRequired
                ? (value) => value!.isEmpty ? 'Zorunlu alan' : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
            borderRadius: BorderRadius.circular(8.0),
          ),
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        style: TextStyle(color: primaryColor),
      ),
    );
  }

  Widget _buildDropdownCategory() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        items: _categoryIcons.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(entry.value, color: primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        }).toList(),

        selectedItemBuilder: (context) {
          return _categoryIcons.entries.map((entry) {
            return Row(
              children: [
                Icon(entry.value, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }).toList();
        },

        onChanged: (val) {
          setState(() => _selectedCategory = val);
        },

        decoration: InputDecoration(
          labelText: 'Kategori',
          prefixIcon: Icon(Icons.category, color: primaryColor),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
            borderRadius: BorderRadius.circular(12.0),
          ),
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
        dropdownColor: Colors.white,
        style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
        validator: (value) => value == null ? 'Zorunlu alan' : null,
      ),
    );
  }


  Widget _buildPriceField(String title, TextEditingController wholeController, TextEditingController fractionalController, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, left: 4),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextFormField(
                  controller: wholeController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsFormatter(),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: Icon(icon, color: primaryColor),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(color: primaryColor),
                  onChanged: (_) => setState(() {
                    _updateDeposit();
                  }),
                ),
              ),
              SizedBox(width: 7),
              const Padding(
                padding: EdgeInsets.only(bottom: 0.0),
                child: Text(
                  ',',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 7),
              SizedBox(
                width: 70,
                child: TextFormField(
                  controller: fractionalController,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    suffixText: '₺',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: TextStyle(color: primaryColor),
                  onChanged: (_) => setState(() {
                    _updateDeposit();
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper class for currency formatting.
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final newText = newValue.text.replaceAll('.', '');
    if (newText.isEmpty) return newValue.copyWith(text: '');

    final int value = int.parse(newText);
    final formattedText = NumberFormat('#,###').format(value).replaceAll(',', '.');

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}