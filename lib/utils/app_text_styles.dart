import 'package:flutter/material.dart';
import 'package:wolfie_sign/utils/app_colors.dart';

/// AppTextStyle format as follows:
/// [fontWeight][fontSize][colorName][opacity]
/// Example: bold18White05
///
class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.backdropColor,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 0, 3, 29),
  );

  static const TextStyle normal16Gray05 = TextStyle(
    fontSize: 16,
    color: AppColors.backdropColor,
  );

  static const TextStyle normal14Gray05 = TextStyle(
    fontSize: 14,
    color: AppColors.backdropColor,
  );

  static const TextStyle fadedText =
      TextStyle(fontSize: 16, color: AppColors.fadedColorDarker);

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );

  static const TextStyle highlight = TextStyle(
    fontSize: 16,
    color: AppColors.primaryColor,
    fontWeight: FontWeight.bold,
  );
}
