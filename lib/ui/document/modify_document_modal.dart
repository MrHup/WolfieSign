import 'package:flutter/material.dart';
import 'package:wolfie_sign/utils/app_colors.dart';
import 'package:wolfie_sign/utils/app_text_styles.dart';

class ModifyDocumentModal extends StatelessWidget {
  final TextEditingController promptController;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const ModifyDocumentModal({
    required this.promptController,
    required this.onSubmit,
    required this.onCancel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Modify Document', style: AppTextStyles.cardTitle),
              const SizedBox(height: 24),
              TextField(
                controller: promptController,
                minLines: 2,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'What do you want to change in the document?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                    ),
                    child: const Text('Submit', style: AppTextStyles.body),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
