import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolfie_sign/ui/groups/group_card.dart';
import 'package:wolfie_sign/ui/groups/groups_controller.dart';
import 'package:wolfie_sign/utils/app_text_styles.dart';

class GroupsPage extends GetView<GroupsController> {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Packs', style: AppTextStyles.title),
          const SizedBox(height: 20),
          Expanded(
            child: Obx(
              () => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.8,
                ),
                itemCount: controller.groups.length,
                itemBuilder: (context, index) {
                  final group = controller.groups[index];
                  return GroupCard(
                    name: group['name'],
                    members: group['members'],
                    onTap: () => controller.onGroupTap(group['name']),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
