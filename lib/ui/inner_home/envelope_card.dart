import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wolfie_sign/data/models/envelope_model.dart';
import 'package:wolfie_sign/utils/app_colors.dart';
import 'package:wolfie_sign/utils/app_text_styles.dart';

class EnvelopeCard extends StatelessWidget {
  final EnvelopeModel envelope;
  final VoidCallback onTap;

  const EnvelopeCard({
    required this.envelope,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  Color get statusColor {
    switch (envelope.status) {
      case 'completed':
        return AppColors.secondaryColor;
      case 'sent':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 8,
              height: 120,
              color: statusColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      envelope.docTitle,
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sent to: ${envelope.senderName}',
                      style: AppTextStyles.normal14Gray05,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Status: ',
                              style: AppTextStyles.normal16Gray05,
                            ),
                            Text(
                              envelope.status,
                              style: AppTextStyles.normal16Gray05.copyWith(
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          DateFormat('dd-MM-yyyy')
                              .format(envelope.statusChangedDateTime),
                          style: AppTextStyles.normal14Gray05,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
