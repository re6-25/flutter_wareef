import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LocalizationController extends GetxController {
  final _key = 'language';
  final _prefs = SharedPreferences.getInstance();

  Rx<Locale> locale = const Locale('ar').obs;

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }

  void _loadLanguage() async {
    final prefs = await _prefs;
    String? lang = prefs.getString(_key);
    if (lang != null) {
      locale.value = Locale(lang);
    }
    Get.updateLocale(locale.value);
  }

  void toggleLanguage() async {
    if (locale.value.languageCode == 'ar') {
      locale.value = const Locale('en');
    } else {
      locale.value = const Locale('ar');
    }
    final prefs = await _prefs;
    await prefs.setString(_key, locale.value.languageCode);
    Get.updateLocale(locale.value);
  }
}
