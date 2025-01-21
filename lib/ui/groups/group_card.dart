import 'package:flutter/material.dart';
import 'package:wolfie_sign/utils/app_text_styles.dart';

class GroupCard extends StatelessWidget {
  final String name;
  final int memberCount;
  final VoidCallback onTap;

  const GroupCard({
    required this.name,
    required this.memberCount,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.cardTitle,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                '$memberCount members',
                style: AppTextStyles.normal14Gray05,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
