import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolfie_sign/ui/groups/member_avatar.dart';
import 'package:wolfie_sign/utils/app_colors.dart';
import 'package:wolfie_sign/utils/app_text_styles.dart';
import 'profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          elevation: 30,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Obx(() => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'My Profile',
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 24),
                    MemberAvatar(
                      email: controller.userEmail.value,
                      backgroundColor: AppColors.primaryColor,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      controller.userEmail.value,
                      style: AppTextStyles.normal16Gray05,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: controller.nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter your name',
                        // border: OutlineInputBorder(
                        //   borderSide: BorderSide.,
                        // ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.updateName,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 102, 102, 102),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Update',
                            style: AppTextStyles.normal16Gray05),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.signOut,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            const Text('Sign Out', style: AppTextStyles.body),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
