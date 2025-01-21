import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolfie_sign/utils/app_colors.dart';
import 'home_controller.dart';

class SideNavigator extends GetView<HomeController> {
  const SideNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: AppColors.primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavButton(
              Icons.group, 'Groups', () => controller.navigateTo(0)),
          _buildDivider(),
          _buildNavButton(Icons.home, 'Home', () => controller.navigateTo(1)),
          _buildDivider(),
          _buildNavButton(
              Icons.person, 'Profile', () => controller.navigateTo(2)),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, String label, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white),
      onPressed: onTap,
      tooltip: label,
      iconSize: 28,
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.2),
    );
  }
}
