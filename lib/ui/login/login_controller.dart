import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:wolfie_sign/ui/groups/groups_controller.dart';
import 'package:wolfie_sign/ui/inner_home/inner_home_controller.dart';
import 'package:wolfie_sign/ui/profile/profile_controller.dart';

class LoginController extends GetxController {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final _auth = FirebaseAuth.instance;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> handleSignIn() async {
    isLoading.value = true;
    Get.context!.loaderOverlay.show();
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Initialize controllers that depend on user data
        await Future.wait([
          Get.find<ProfileController>().loadUserData(),
          Get.find<InnerHomeController>().loadInitialData(),
          Get.find<GroupsController>().loadInitialData(),
        ]);
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign in: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
      Get.context!.loaderOverlay.hide();
    }
  }
}
