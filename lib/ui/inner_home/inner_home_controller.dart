import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:wolfie_sign/data/models/envelope_model.dart';
import 'package:wolfie_sign/utils/logger.dart';

class InnerHomeController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final envelopes = <EnvelopeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToEnvelopes();
  }

  void _listenToEnvelopes() {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      _firestore.collection('documents').doc(userId).snapshots().listen(
        (snapshot) {
          if (snapshot.exists && snapshot.data()?['envelopes'] != null) {
            final envelopesList = List<Map<String, dynamic>>.from(
                snapshot.data()?['envelopes'] ?? []);
            envelopes.value =
                envelopesList.map((e) => EnvelopeModel.fromJson(e)).toList();
          }
        },
        onError: (error) => logger.e('Error listening to envelopes: $error'),
      );
    }
  }

  void onEnvelopeTap(String envelopeId) {
    logger.d('Envelope tapped: $envelopeId');
  }
}
