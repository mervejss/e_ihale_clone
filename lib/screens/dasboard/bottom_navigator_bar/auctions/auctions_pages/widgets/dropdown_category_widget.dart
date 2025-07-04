import 'package:flutter/material.dart';

import '../../../../../../utils/colors.dart';

class DropdownCategory extends StatelessWidget {
  final String? selectedCategory;
  final Map<String, IconData> categoryIcons;
  final Function(String?) onChanged;

  const DropdownCategory({
    Key? key,
    this.selectedCategory,
    required this.categoryIcons,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        items: categoryIcons.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Icon(entry.value, color: AppColors.primaryColor),
                const SizedBox(width: 10),
                Text(entry.key, style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: 'Kategori',
          prefixIcon: Icon(Icons.category, color: AppColors.primaryColor),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor),
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: AppColors.secondaryColor,
        ),
      ),
    );
  }
}