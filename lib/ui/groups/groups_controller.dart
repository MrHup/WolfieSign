import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wolfie_sign/utils/logger.dart';

class GroupsController extends GetxController {
  final _groups = [].obs;
  List get groups => _groups;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _listenToGroups();
  }

  void _listenToGroups() {
    final userId = _auth.currentUser?.uid;
    logger.d('User ID: $userId');
    if (userId != null) {
      _firestore
          .collection('email-list')
          .doc(userId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && snapshot.data()?['groups'] != null) {
          _groups.value = List.from(snapshot.data()?['groups'] ?? []);
        }
      });
    }
  }

  void onGroupTap(String groupName) {
    logger.d('Group tapped: $groupName');
  }
}
