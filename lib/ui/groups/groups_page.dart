import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolfie_sign/ui/groups/group_card.dart';
import 'package:wolfie_sign/ui/groups/group_details_panel.dart';
import 'package:wolfie_sign/ui/groups/groups_controller.dart';
import 'package:wolfie_sign/utils/app_text_styles.dart';
import 'package:wolfie_sign/utils/app_colors.dart';

class GroupsPage extends GetView<GroupsController> {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Packs', style: AppTextStyles.title),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(
                  () => GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisExtent: 150,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
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
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: controller.showAddGroupModal,
            backgroundColor: AppColors.primaryColor,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        Obx(() => AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              right: controller.selectedGroup != null ? 0 : -800,
              top: 0,
              bottom: 0,
              child: controller.selectedGroup != null
                  ? GroupDetailsPanel(
                      groupName: controller.selectedGroup!['name'],
                      members: controller.selectedGroup!['members'],
                      onClose: controller.closeGroupDetails,
                      onAddMember: controller.onAddMember,
                      onCreateDocument: controller.onCreateDocument,
                    )
                  : const SizedBox(),
            )),
      ],
    );
  }
}
