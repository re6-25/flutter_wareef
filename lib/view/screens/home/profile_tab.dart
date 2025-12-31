import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/logic/controllers/localization_controller.dart';
import 'package:wareef_academy/logic/controllers/theme_controller.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();
    final localeController = Get.find<LocalizationController>();

    final user = authController.currentUser.value;

    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr)),
      body: user == null 
        ? const Center(child: Text('Guest Mode'))
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person, size: 60, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoTile('User ID', user.id.toString(), Icons.numbers),
              _buildInfoTile('username'.tr, user.username, Icons.person_outline),
              _buildInfoTile('Role', _getRoleName(user.roleId), Icons.security),
              if (authController.isAdmin) ...[
                const SizedBox(height: 16),
               if (authController.currentUser.value?.roleId == 1) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.dashboard, color: AppColors.primary),
                title: const Text('Admin Dashboard'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.toNamed('/admin-dashboard'),
              ),
              ListTile(
                leading: const Icon(Icons.people, color: AppColors.primary),
                title: const Text('Manage Users'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.toNamed('/users-management'),
              ),
              ListTile(
                leading: const Icon(Icons.rule, color: AppColors.primary),
                title: const Text('Manage Roles'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.toNamed('/roles-management'),
              ),
            ],
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.primary),
                title: const Text('عن أكاديمية وريف'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.toNamed('/about'),
              ),
              const Divider(height: 48),
              ListTile(
                title: Text('theme_mode'.tr),
                trailing: Obx(() => Switch(
                  value: themeController.isDarkMode.value,
                  onChanged: (val) => themeController.toggleTheme(),
                )),
                leading: const Icon(Icons.brightness_4),
              ),
              ListTile(
                title: Text('language'.tr),
                trailing: Text(localeController.locale.value.languageCode.toUpperCase()),
                onTap: () => localeController.toggleLanguage(),
                leading: const Icon(Icons.language),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => authController.logout(),
                  icon: const Icon(Icons.logout),
                  label: Text('logout'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      dense: true,
    );
  }

  String _getRoleName(int roleId) {
    switch (roleId) {
      case 1: return 'Admin';
      case 2: return 'Wareefa';
      default: return 'Guest';
    }
  }
}
