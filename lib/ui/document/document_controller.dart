import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentController extends GetxController {
  final _group = Rxn<Map<String, dynamic>>();
  final bodyController = TextEditingController();
  final selectedTemplate = RxString('');

  set group(Map<String, dynamic> value) => _group.value = value;
  String get groupName => _group.value?['name'] ?? '';
  List<dynamic> get groupMembers => _group.value?['members'] ?? [];

  @override
  void onClose() {
    bodyController.dispose();
    super.onClose();
  }

  void selectTemplate(String template) {
    selectedTemplate.value = template;
  }

  void onSubmit() {
    print('Submitting document');
  }
}
