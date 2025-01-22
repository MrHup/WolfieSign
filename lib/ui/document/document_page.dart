import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolfie_sign/ui/document/document_controller.dart';
import 'package:wolfie_sign/ui/groups/member_avatars_row.dart';
import 'package:wolfie_sign/utils/app_colors.dart';
import 'package:wolfie_sign/utils/app_text_styles.dart';

class DocumentPage extends GetView<DocumentController> {
  const DocumentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 1200;

            final contentSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(controller.groupName, style: AppTextStyles.cardTitle),
                    MemberAvatarsRow(members: controller.groupMembers),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('Select Document Template',
                    style: AppTextStyles.title),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Obx(() => _TemplateButton(
                          label: 'Travel',
                          isSelected:
                              controller.selectedTemplate.value == 'Travel',
                          onTap: () => controller.selectTemplate('Travel'),
                        )),
                    const SizedBox(width: 16),
                    Obx(() => _TemplateButton(
                          label: 'GDPR',
                          isSelected:
                              controller.selectedTemplate.value == 'GDPR',
                          onTap: () => controller.selectTemplate('GDPR'),
                        )),
                    const SizedBox(width: 16),
                    Obx(() => _TemplateButton(
                          label: 'Custom',
                          isSelected:
                              controller.selectedTemplate.value == 'Custom',
                          onTap: () => controller.selectTemplate('Custom'),
                        )),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('Document Body', style: AppTextStyles.title),
                const SizedBox(height: 16),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      TextField(
                        controller: controller.bodyController,
                        maxLines: null,
                        textAlign: TextAlign.start,
                        expands: true,
                        decoration: const InputDecoration(
                          // border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Color.fromARGB(255, 241, 241, 241),
                        ),
                        onChanged: (_) => print('Hello'),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: IconButton(
                          color: AppColors.primaryColor,
                          iconSize: 64,
                          icon: const Icon(Icons.edit_document),
                          onPressed: () => print('Transform'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: controller.onSubmit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )),
                    child: const Text('Submit', style: AppTextStyles.body),
                  ),
                ),
              ],
            );

            final previewSection = Container(
              width: isWideScreen ? 595 : double.infinity,
              height: isWideScreen ? 842 : 500,
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
            );

            if (isWideScreen) {
              return Row(
                children: [
                  Expanded(child: contentSection),
                  previewSection,
                ],
              );
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: constraints.maxHeight - 48,
                    child: contentSection,
                  ),
                  previewSection,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TemplateButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primaryColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          )),
      child: Text(label),
    );
  }
}
