import 'package:get/get.dart';
import 'package:wolfie_sign/ui/document/document_controller.dart';
import 'package:wolfie_sign/ui/groups/groups_controller.dart';
import 'package:wolfie_sign/ui/inner_home/inner_home_controller.dart';
import 'package:wolfie_sign/ui/login/login_controller.dart';
import 'package:wolfie_sign/ui/profile/profile_controller.dart';

class DependencyCreator {
  static init() {
    Get.put(ProfileController(), permanent: true);
    Get.put(GroupsController(), permanent: true);
    Get.put(DocumentController(), permanent: true);
    Get.put(InnerHomeController(), permanent: true);
    Get.put(LoginController());
  }
}
