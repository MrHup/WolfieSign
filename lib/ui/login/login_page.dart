import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolfie_sign/ui/login/dot_painter.dart';
import 'package:wolfie_sign/utils/app_colors.dart';
import 'package:wolfie_sign/utils/app_text_styles.dart';
import 'package:wolfie_sign/utils/logger.dart';
import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Stack(
        children: [
          CustomPaint(
            painter: DotPatternPainter(),
            size: Size.infinite,
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Text
                  Image.asset(
                    'assets/images/logo_big.png',
                    height: 200,
                  ),
                  const SizedBox(height: 16),

                  // Email Field
                  const Text(
                    'Email',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.email),
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Password Field
                  const Text(
                    'Password',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign In Button
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sign Up Text
                  GestureDetector(
                    onTap: () {
                      logger.w(
                          "Sign up is not implemented yet. Reach out for an account or create it manually.");
                    },
                    child: const Text(
                      "Don't have an account? Sign up now",
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                )
              : const SizedBox()),
          // Powered by section
          Positioned(
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                const Text(
                  'Powered by',
                  style: AppTextStyles.body,
                ),
                const SizedBox(width: 8),
                Image.asset(
                  'assets/images/docusign.png',
                  height: 70,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
