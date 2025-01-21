import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wolfie_sign/ui/groups/add_group_modal.dart';
import 'package:wolfie_sign/ui/groups/add_member_modal.dart';
import 'package:wolfie_sign/utils/app_colors.dart';
import 'package:wolfie_sign/utils/logger.dart';

class GroupsController extends GetxController {
  final _groups = [].obs;
  List get groups => _groups;
  final _selectedGroup = Rxn<Map<String, dynamic>>();
  Map<String, dynamic>? get selectedGroup => _selectedGroup.value;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final nameController = TextEditingController();
  final memberNameController = TextEditingController();
  final memberEmailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _listenToGroups();
  }

  @override
  void onClose() {
    nameController.dispose();
    memberNameController.dispose();
    memberEmailController.dispose();
    super.onClose();
  }

  void showAddGroupModal() {
    nameController.clear();
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          color: AppColors.backdropColor,
          child: AddGroupModal(
            nameController: nameController,
            onAdd: () => _addNewGroup(),
            onCancel: () => Get.back(),
          ),
        ),
      ),
      barrierColor: Colors.transparent,
    );
  }

  Future<void> _addNewGroup() async {
    if (nameController.text.isEmpty) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final newGroup = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': nameController.text,
      'members': [],
    };

    try {
      final docRef = _firestore.collection('email-list').doc(userId);
      await docRef.update({
        'groups': FieldValue.arrayUnion([newGroup])
      });
      Get.back();
    } catch (e) {
      logger.e('Error adding group: $e');
    }
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
    final group = _groups.firstWhere((g) => g['name'] == groupName);
    _selectedGroup.value = group;
  }

  void closeGroupDetails() {
    _selectedGroup.value = null;
  }

  void onAddMember() {
    memberNameController.clear();
    memberEmailController.clear();
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          color: AppColors.backdropColor,
          child: AddMemberModal(
            nameController: memberNameController,
            emailController: memberEmailController,
            onAdd: () => _addNewMember(),
            onCancel: () => Get.back(),
          ),
        ),
      ),
      barrierColor: Colors.transparent,
    );
  }

  Future<void> _addNewMember() async {
    if (memberNameController.text.isEmpty || memberEmailController.text.isEmpty)
      return;
    if (selectedGroup == null) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final newMember = {
      'name': memberNameController.text,
      'email': memberEmailController.text,
    };

    try {
      final updatedGroup = Map<String, dynamic>.from(selectedGroup!);
      updatedGroup['members'] = [...updatedGroup['members'], newMember];

      final docRef = _firestore.collection('email-list').doc(userId);
      await docRef.update({
        'groups': FieldValue.arrayRemove([selectedGroup]),
      });
      await docRef.update({
        'groups': FieldValue.arrayUnion([updatedGroup]),
      });

      _selectedGroup.value = updatedGroup;
      Get.back();
    } catch (e) {
      logger.e('Error adding member: $e');
    }
  }

  void onCreateDocument() {
    logger.d('Create document clicked');
  }
}
