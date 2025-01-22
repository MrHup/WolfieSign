import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolfie_sign/ui/inner_home/envelope_card.dart';
import 'package:wolfie_sign/ui/inner_home/inner_home_controller.dart';
import 'package:wolfie_sign/utils/app_colors.dart';

class InnerHomePage extends GetView<InnerHomeController> {
  const InnerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: controller.envelopes.length,
          itemBuilder: (context, index) {
            final envelope = controller.envelopes[index];
            return EnvelopeCard(
              envelope: envelope,
              onTap: () => controller.onEnvelopeTap(envelope.envelopeId),
            );
          },
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Obx(() => FloatingActionButton(
                onPressed: controller.isRefreshing.value
                    ? null
                    : controller.refreshEnvelopes,
                backgroundColor: AppColors.primaryColor,
                child: controller.isRefreshing.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.refresh, color: Colors.white),
              )),
        ),
      ],
    );
  }
}
