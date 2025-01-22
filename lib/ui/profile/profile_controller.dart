import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolfie_sign/data/repositories/user_repository.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final nameController = TextEditingController();
  final userEmail = ''.obs;
  final userName = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    final user = await _userRepository.getCurrentUser();
    if (user != null) {
      userEmail.value = user.email;
      userName.value = user.name ?? '';
      nameController.text = user.name ?? '';
    }
    isLoading.value = false;
  }

  Future<void> updateName() async {
    if (nameController.text.trim().isNotEmpty) {
      isLoading.value = true;
      await _userRepository.updateUserName(nameController.text.trim());
      userName.value = nameController.text.trim();
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAllNamed('/');
  }
}
