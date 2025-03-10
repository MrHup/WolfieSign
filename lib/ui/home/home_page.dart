import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'side_navigator.dart';
import 'home_pattern_painter.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomPaint(
            painter: HomePatternPainter(),
            size: Size.infinite,
          ),
          Row(
            children: [
              const SideNavigator(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 70,
                      ),
                    ),
                    Expanded(
                      child: Obx(() => controller.currentPage),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
