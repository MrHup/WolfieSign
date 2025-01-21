import 'package:flutter/material.dart';
import 'package:wolfie_sign/utils/app_text_styles.dart';

class GroupCard extends StatefulWidget {
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
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 200),
        tween: Tween<double>(begin: 0, end: isHovered ? 1 : 0),
        builder: (context, double value, child) {
          return Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(0.01 * value)
              ..rotateY(0.15 * value),
            child: InkWell(
              onTap: widget.onTap,
              enableFeedback: false,
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Card(
                elevation: 20 + (10 * value),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: AppTextStyles.cardTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        '${widget.memberCount} members',
                        style: AppTextStyles.normal14Gray05,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
