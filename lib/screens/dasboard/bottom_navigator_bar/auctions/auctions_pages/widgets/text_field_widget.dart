import 'package:flutter/material.dart';
import '../../../../../../utils/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool isRequired;
  final int maxLines;
  final IconData? icon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.maxLines = 1,
    this.icon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text, // Ekleme
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, left: 4),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: icon != null ? Icon(icon, color: AppColors.primaryColor) : null,
              hintText: hintText,
              suffixIcon: suffixIcon,
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryColor),
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              fillColor: AppColors.secondaryColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            ),
            style: const TextStyle(color: Colors.black),
            maxLines: maxLines,
            obscureText: obscureText,
            keyboardType: keyboardType, // Ekleme
            validator: isRequired ? (value) {
              if (value == null || value.isEmpty) {
                return 'Zorunlu alan';
              }
              return null;
            } : null,
          ),
        ],
      ),
    );
  }
}