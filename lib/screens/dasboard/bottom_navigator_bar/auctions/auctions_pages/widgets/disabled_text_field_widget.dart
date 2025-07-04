import 'package:flutter/material.dart';

import '../../../../../../utils/colors.dart';

class DisabledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;

  const DisabledTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enabled: false,
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
        style: const TextStyle(color: AppColors.primaryColor),
      ),
    );
  }
}