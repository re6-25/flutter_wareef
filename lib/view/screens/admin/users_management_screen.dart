import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/data/providers/database_helper.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class UsersManagementController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;
  RxList<UserModel> users = <UserModel>[].obs;
  RxList<Map<String, dynamic>> roles = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    fetchRoles();
  }

  Future<void> fetchUsers() async {
    isLoading.value = true;
    final db = await _dbHelper.database;
    final result = await db.query('users');
    users.assignAll(result.map((e) => UserModel.fromMap(e)).toList());
    isLoading.value = false;
  }

  Future<void> fetchRoles() async {
    final db = await _dbHelper.database;
    final result = await db.query('roles');
    roles.assignAll(result);
  }

  Future<void> deleteUser(int id) async {
    final db = await _dbHelper.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
    fetchUsers();
  }

  Future<void> updateUserRole(int userId, int roleId) async {
    final db = await _dbHelper.database;
    await db.update('users', {'role_id': roleId}, where: 'id = ?', whereArgs: [userId]);
    fetchUsers();
  }
}

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UsersManagementController());

    return Scaffold(
      appBar: AppBar(title: Text('users_management_title'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(user.username),
                subtitle: Text('${'role_label'.tr}${_getRoleName(user.roleId, controller.roles)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () => _showRoleDialog(context, user, controller),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () => controller.deleteUser(user.id!),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _getRoleName(int roleId, List roles) {
    final role = roles.firstWhere((element) => element['id'] == roleId, orElse: () => {'name': 'unknown'.tr});
    return role['name'];
  }

  void _showRoleDialog(BuildContext context, UserModel user, UsersManagementController controller) {
    Get.defaultDialog(
      title: 'update_role_title'.tr,
      content: Column(
        children: controller.roles.map((role) => ListTile(
          title: Text(role['name']),
          onTap: () {
            controller.updateUserRole(user.id!, role['id']);
            Get.back();
          },
        )).toList(),
      ),
    );
  }
}
