import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/data/providers/database_helper.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class RolesManagementController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;
  RxList<Map<String, dynamic>> roles = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    isLoading.value = true;
    final db = await _dbHelper.database;
    final result = await db.query('roles');
    roles.assignAll(result);
    isLoading.value = false;
  }

  Future<void> addRole(String name) async {
    final db = await _dbHelper.database;
    await db.insert('roles', {'name': name});
    fetchRoles();
  }

  Future<void> updateRole(int id, String name) async {
    final db = await _dbHelper.database;
    await db.update('roles', {'name': name}, where: 'id = ?', whereArgs: [id]);
    fetchRoles();
  }

  Future<void> deleteRole(int id) async {
    final db = await _dbHelper.database;
    await db.delete('roles', where: 'id = ?', whereArgs: [id]);
    fetchRoles();
  }
}

class RolesManagementScreen extends StatelessWidget {
  const RolesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RolesManagementController());
    final TextEditingController roleController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Roles')),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: controller.roles.length,
          itemBuilder: (context, index) {
            final role = controller.roles[index];
            return ListTile(
              title: Text(role['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    onPressed: () {
                      roleController.text = role['name'];
                      _showRoleDialog(context, controller, roleId: role['id'], roleController: roleController);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => controller.deleteRole(role['id']),
                  ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          roleController.clear();
          _showRoleDialog(context, controller, roleController: roleController);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showRoleDialog(BuildContext context, RolesManagementController controller, {int? roleId, required TextEditingController roleController}) {
    Get.defaultDialog(
      title: roleId == null ? 'Add Role' : 'Edit Role',
      content: TextField(controller: roleController, decoration: const InputDecoration(labelText: 'Role Name')),
      confirm: ElevatedButton(
        onPressed: () {
          if (roleId == null) {
            controller.addRole(roleController.text);
          } else {
            controller.updateRole(roleId, roleController.text);
          }
          Get.back();
        },
        child: const Text('Save'),
      ),
    );
  }
}
