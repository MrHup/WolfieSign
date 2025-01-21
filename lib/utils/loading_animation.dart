import 'package:wolfie_sign/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';

class AnimationManager extends GetView<AnimationManagerController> {
  final String animationKey;

  const AnimationManager({super.key, required this.animationKey});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final file = controller.animations[animationKey];
      return file == null
          ? const SizedBox.shrink()
          : RiveAnimation.direct(file);
    });
  }
}

class AnimationManagerController extends GetxController {
  final animations = <String, RiveFile>{}.obs;

  final List<String> animationPaths = [];

  Future<void> preloadAnimations() async {
    logger.d("Preloading animations");
    await RiveFile.initialize();

    for (final path in animationPaths) {
      try {
        final data = await rootBundle.load(path);
        final file = RiveFile.import(data);
        final key = path.split('/').last.split('.').first;
        animations[key] = file;
        logger.d("Loaded animation: $key");
      } catch (e) {
        logger.e("Error loading animation: $path", error: e);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    preloadAnimations();
  }
}
