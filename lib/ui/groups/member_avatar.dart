import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wolfie_sign/utils/app_text_styles.dart';

class MemberAvatar extends StatelessWidget {
  final String email;
  final Color backgroundColor;
  final double size;

  const MemberAvatar({
    required this.email,
    required this.backgroundColor,
    this.size = 48,
    Key? key,
  }) : super(key: key);

  String get initials {
    final parts = email.split('@');
    if (parts.isEmpty) return '';
    return parts[0].substring(0, min(2, parts[0].length)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      child: Text(
        initials,
        style: AppTextStyles.body.copyWith(fontSize: size * 0.4),
      ),
    );
  }
}
