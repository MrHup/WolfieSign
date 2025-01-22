import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolfie_sign/ui/inner_home/envelope_card.dart';
import 'package:wolfie_sign/ui/inner_home/inner_home_controller.dart';

class InnerHomePage extends GetView<InnerHomeController> {
  const InnerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        itemCount: controller.envelopes.length,
        itemBuilder: (context, index) {
          final envelope = controller.envelopes[index];
          return EnvelopeCard(
            envelope: envelope,
            onTap: () => controller.onEnvelopeTap(envelope.envelopeId),
          );
        },
      ),
    );
  }
}
