import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:wolfie_sign/data/models/envelope_model.dart';
import 'package:wolfie_sign/data/services/envelope_service.dart';
import 'package:wolfie_sign/utils/logger.dart';

class InnerHomeController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _envelopeService = EnvelopeService();
  final envelopes = <EnvelopeModel>[].obs;
  final isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToEnvelopes();
  }

  Future<void> refreshEnvelopes() async {
    if (isRefreshing.value) return;

    isRefreshing.value = true;
    final envelopeIds = envelopes.map((e) => e.envelopeId).toList();

    if (envelopeIds.isEmpty) {
      isRefreshing.value = false;
      return;
    }

    final response =
        await _envelopeService.batchUpdateEnvelopeStatus(envelopeIds);

    if (response != null && response is List) {
      await _updateFirestoreEnvelopes(response);
    }

    isRefreshing.value = false;
  }

  Future<void> _updateFirestoreEnvelopes(List<dynamic> updatedEnvelopes) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final docRef = _firestore.collection('documents').doc(userId);
    final currentEnvelopes = Map.fromEntries(
      envelopes.map((e) => MapEntry(e.envelopeId, {
            'group_id': e.groupId,
            'doc_title': e.docTitle,
          })),
    );

    final newEnvelopes = updatedEnvelopes.map((e) {
      final envelope = Map<String, dynamic>.from(e);
      final envelopeId = envelope['envelope_id'];
      final existingData = currentEnvelopes[envelopeId];

      if (existingData != null) {
        envelope['group_id'] = existingData['group_id'];
        envelope['doc_title'] = existingData['doc_title'];
      }

      return envelope;
    }).toList();

    await docRef.update({'envelopes': newEnvelopes});
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
