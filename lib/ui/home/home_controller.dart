import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wolfie_sign/ui/groups/groups_page.dart';
import 'package:wolfie_sign/ui/inner_home/inner_home_page.dart';
import 'package:wolfie_sign/ui/profile/profile_page.dart';

class HomeController extends GetxController {
  final _currentPageIndex = 1.obs;

  Widget get currentPage {
    switch (_currentPageIndex.value) {
      case 0:
        return const GroupsPage();
      case 1:
        return const InnerHomePage();
      case 2:
        return const ProfilePage();
      default:
        return const InnerHomePage();
    }
  }

  void navigateTo(int index) {
    _currentPageIndex.value = index;
  }
}
