import 'package:get/get.dart';
import 'package:wolfie_sign/ui/document/document_controller.dart';
import 'package:wolfie_sign/ui/groups/groups_controller.dart';
import 'package:wolfie_sign/ui/login/login_controller.dart';
import 'package:wolfie_sign/ui/profile/profile_controller.dart';

class DependencyCreator {
  static init() {
    Get.put(LoginController());
    Get.put(GroupsController(), permanent: true);
    Get.put(DocumentController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
  }
}
