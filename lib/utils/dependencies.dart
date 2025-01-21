import 'package:get/get.dart';
import 'package:wolfie_sign/ui/login/login_controller.dart';

class DependencyCreator {
  static init() {
    Get.lazyPut(() => LoginController());
  }
}
