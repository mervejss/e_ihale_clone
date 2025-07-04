import 'package:flutter/material.dart';
import 'package:e_ihale_clone/widgets/save_result_dialog.dart';
import 'package:e_ihale_clone/utils/colors.dart';

class SaveConfirmationDialog extends StatelessWidget {
  final VoidCallback onSave;

  const SaveConfirmationDialog({Key? key, required this.onSave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.secondaryColor,
      title: Row(
        children: [
          Icon(Icons.save, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          const Text(
            'Değişiklikleri Kaydet',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: const Text(
        'Değişiklikleri kaydetmek istediğinize emin misiniz?',
        style: TextStyle(fontSize: 16),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.cancel, color: Colors.red),
          label: const Text('İptal', style: TextStyle(color: Colors.red)),
          onPressed: () {
            Navigator.pop(context);
            Future.microtask(() {
              showDialog(
                context: context,
                builder: (_) => const SaveResultDialog(
                  isSuccess: false,
                  message: 'İşlem iptal edildi.',
                ),
              );
            });
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('Kaydet'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.pop(context);
            onSave();
          },
        ),
      ],
    );
  }
}
