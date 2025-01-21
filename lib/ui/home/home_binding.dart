import 'package:get/get.dart';
import 'package:wolfie_sign/ui/groups/groups_controller.dart';
import 'home_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => GroupsController());
  }
}
