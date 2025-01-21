import 'package:flutter/material.dart';
import 'package:wolfie_sign/utils/app_text_styles.dart';
import 'member_avatar.dart';

class MemberAvatarsRow extends StatelessWidget {
  final List<dynamic> members;
  final double avatarSize;
  final double spacing;

  const MemberAvatarsRow({
    required this.members,
    this.avatarSize = 48,
    this.spacing = -10,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxDisplayed = 3;
    final displayMembers = members.take(maxDisplayed).toList();
    final remainingCount = members.length - maxDisplayed;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ...List.generate(
          displayMembers.length,
          (index) => Transform.translate(
            offset: Offset(index * spacing, 0),
            child: MemberAvatar(
              email: displayMembers[index]['email'],
              backgroundColor:
                  Colors.primaries[index % Colors.primaries.length],
              size: avatarSize,
            ),
          ),
        ),
        if (remainingCount > 0)
          Transform.translate(
            offset: Offset((displayMembers.length - 1) * spacing + 8, 0),
            child: Text(
              '+$remainingCount',
              style: AppTextStyles.normal14Gray05,
            ),
          ),
      ],
    );
  }
}
