import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rive/rive.dart';
import 'package:wolfie_sign/firebase_options.dart';
import 'package:wolfie_sign/ui/document/document_page.dart';
import 'package:wolfie_sign/ui/home/home_binding.dart';
import 'package:wolfie_sign/ui/home/home_page.dart';
import 'package:wolfie_sign/ui/login/login_binding.dart';
import 'package:wolfie_sign/ui/login/login_page.dart';
import 'package:wolfie_sign/utils/app_colors.dart';
import 'package:wolfie_sign/utils/dependencies.dart';
import 'package:wolfie_sign/utils/logger.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      overlayColor: AppColors.backgroundColor,
      overlayWidgetBuilder: (_) {
        return const Center(
          child: SizedBox(
            width: 270,
            height: 270,
            child: Center(
              child: RiveAnimation.asset(
                'assets/animations/wolf.riv',
              ),
            ),
          ),
        );
      },
      child: GetMaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: AppColors.backgroundColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.backgroundColor,
            elevation: 0,
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        getPages: [
          GetPage(
            name: "/",
            page: () => const LoginPage(),
            binding: LoginBinding(),
          ),
          GetPage(
            name: "/home",
            page: () => const HomePage(),
            binding: HomeBinding(),
          ),
          GetPage(
            name: "/document",
            page: () => const DocumentPage(),
          ),
        ],
        home: const LoginPage(),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initialiseServices();
  DependencyCreator.init();
  runApp(App());
}

Future<void> initialiseServices() async {
  logger.i("Initialising Services");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
