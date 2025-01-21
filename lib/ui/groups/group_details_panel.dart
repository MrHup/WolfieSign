import 'package:flutter/material.dart';
import 'package:wolfie_sign/utils/app_colors.dart';
import 'package:wolfie_sign/utils/app_text_styles.dart';
import 'package:wolfie_sign/ui/groups/member_avatar.dart';

class GroupDetailsPanel extends StatelessWidget {
  final String groupName;
  final List<dynamic> members;
  final VoidCallback onClose;
  final VoidCallback onAddMember;
  final VoidCallback onCreateDocument;

  const GroupDetailsPanel({
    required this.groupName,
    required this.members,
    required this.onClose,
    required this.onAddMember,
    required this.onCreateDocument,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width > 1200
          ? 700
          : MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      height: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onClose,
                ),
                const SizedBox(width: 16),
                Text(groupName, style: AppTextStyles.cardTitle),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Members', style: AppTextStyles.title),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return ListTile(
                    title: Text(member['name']),
                    subtitle: Text(member['email']),
                    trailing: MemberAvatar(
                      email: member['email'],
                      backgroundColor:
                          Colors.primaries[index % Colors.primaries.length],
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onAddMember,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    )),
                child: const Text('Add New Member', style: AppTextStyles.body),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onCreateDocument,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    )),
                child: const Text('Create Document', style: AppTextStyles.body),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
