import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/logic/controllers/categories_controller.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoriesController());
    final TextEditingController nameController = TextEditingController();
    final RxString selectedType = 'both'.obs;

    return Scaffold(
      appBar: AppBar(title: Text('manage_categories_title'.tr)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, controller, nameController, selectedType),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final cat = controller.categories[index];
            return ListTile(
              title: Text(cat.name),
              subtitle: Text('Type: ${cat.type}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () => controller.deleteCategory(cat.id!),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddDialog(BuildContext context, CategoriesController controller, TextEditingController nameController, RxString selectedType) {
    Get.defaultDialog(
      title: 'add_category'.tr,
      content: Column(
        children: [
          TextField(controller: nameController, decoration: InputDecoration(labelText: 'category_name'.tr)),
          const SizedBox(height: 10),
          Obx(() => DropdownButton<String>(
            value: selectedType.value,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'both', child: Text('Both')),
              DropdownMenuItem(value: 'project', child: Text('Projects Only')),
              DropdownMenuItem(value: 'course', child: Text('Courses Only')),
            ],
            onChanged: (v) => selectedType.value = v!,
          )),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          if (nameController.text.isNotEmpty) {
            controller.addCategory(nameController.text, selectedType.value);
            nameController.clear();
            Get.back();
          }
        },
        child: Text('save'.tr),
      ),
    );
  }
}
