import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final _key = 'isDarkMode';
  final _prefs = SharedPreferences.getInstance();

  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
  }

  _loadThemeFromPrefs() async {
    final prefs = await _prefs;
    isDarkMode.value = prefs.getBool(_key) ?? false;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  _saveThemeToPrefs(bool isDark) async {
    final prefs = await _prefs;
    prefs.setBool(_key, isDark);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _saveThemeToPrefs(isDarkMode.value);
  }
}
