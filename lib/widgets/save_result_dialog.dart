import 'package:flutter/material.dart';
import 'package:e_ihale_clone/utils/colors.dart';

class SaveResultDialog extends StatelessWidget {
  final bool isSuccess;
  final String message;

  const SaveResultDialog({Key? key, required this.isSuccess, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.secondaryColor,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: isSuccess ? Colors.green : Colors.red,
            size: 60,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Tamam'),
          ),
        ),
      ],
    );
  }
}
