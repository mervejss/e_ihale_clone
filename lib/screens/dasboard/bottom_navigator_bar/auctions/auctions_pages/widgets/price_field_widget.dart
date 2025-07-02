import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../../../utils/colors.dart';

class PriceField extends StatelessWidget {
  final String title;
  final TextEditingController wholeController;
  final TextEditingController fractionalController;
  final IconData icon;
  final Function onUpdate;

  const PriceField({
    Key? key,
    required this.title,
    required this.wholeController,
    required this.fractionalController,
    required this.icon,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, left: 4),
            child: Text(
              title,
              style: const TextStyle(
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
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu alan' : null,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsFormatter(),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: Icon(icon, color: AppColors.primaryColor),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: AppColors.secondaryColor,
                  ),
                  style: const TextStyle(color: AppColors.primaryColor),
                  onChanged: (_) => onUpdate(),
                ),
              ),
              const SizedBox(width: 7),
              const Padding(
                padding: EdgeInsets.only(bottom: 0.0),
                child: Text(
                  ',',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 7),
              SizedBox(
                width: 70,
                child: TextFormField(
                  validator: (value) => value == null || value.isEmpty ? 'Zorunlu alan' : null,
                  controller: fractionalController,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    suffixText: '₺',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: AppColors.secondaryColor,
                  ),
                  style: const TextStyle(color: AppColors.primaryColor),
                  onChanged: (_) => onUpdate(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
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