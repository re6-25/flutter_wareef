import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/core/app_translations.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/logic/controllers/localization_controller.dart';
import 'package:wareef_academy/logic/controllers/theme_controller.dart';
import 'package:wareef_academy/routes/app_routes.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Controllers
  Get.put(ThemeController());
  Get.put(LocalizationController());
  Get.put(AuthController());

  runApp(const WareefApp());
}

class WareefApp extends StatelessWidget {
  const WareefApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final localeController = Get.find<LocalizationController>();

    final textTheme = GoogleFonts.cairoTextTheme(
      Theme.of(context).textTheme,
    );

    return GetMaterialApp(
      title: 'Wareef Academy',
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: localeController.locale.value,
      fallbackLocale: const Locale('ar'),
      themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        textTheme: textTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        textTheme: textTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      ),
      getPages: AppRoutes.routes,
      initialRoute: '/onboarding',
    );
  }
}
