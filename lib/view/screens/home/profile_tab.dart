import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/logic/controllers/localization_controller.dart';
import 'package:wareef_academy/logic/controllers/theme_controller.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _pickImage(AuthController auth) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await auth.updateProfileImage(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final themeController = Get.find<ThemeController>();
    final localeController = Get.find<LocalizationController>();

    return Scaffold(
      appBar: AppBar(title: Text('profile'.tr)),
      body: Obx(() {
        final user = authController.currentUser.value;
        if (user == null) return Center(child: Text('guest_mode'.tr));

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: user.profileImage != null ? FileImage(File(user.profileImage!)) : null,
                    child: user.profileImage == null ? const Icon(Icons.person, size: 70, color: AppColors.primary) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickImage(authController),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoTile('user_id'.tr, user.id.toString(), Icons.numbers),
            _buildInfoTile('username'.tr, user.username, Icons.person_outline),
            _buildInfoTile('role'.tr, _getRoleName(user.roleId), Icons.security),
            if (authController.isAdmin) ...[
              const SizedBox(height: 16),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.dashboard, color: AppColors.primary),
                title: Text('admin_dashboard'.tr),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.toNamed('/admin-dashboard'),
              ),
              ListTile(
                leading: const Icon(Icons.people, color: AppColors.primary),
                title: Text('manage_users'.tr),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.toNamed('/users-management'),
              ),
              ListTile(
                leading: const Icon(Icons.rule, color: AppColors.primary),
                title: Text('manage_roles'.tr),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.toNamed('/roles-management'),
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.primary),
              title: Text('about_wareef_academy'.tr),
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
        );
      }),
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
      case 1: return 'role_admin'.tr;
      case 2: return 'role_wareefa'.tr;
      default: return 'role_guest'.tr;
    }
  }
}
