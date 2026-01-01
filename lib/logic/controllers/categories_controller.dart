import 'package:get/get.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/data/providers/database_helper.dart';

class CategoriesController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;

  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('categories');
      categories.value = maps.map((e) => CategoryModel.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(String name, String type) async {
    try {
      final db = await _dbHelper.database;
      await db.insert('categories', {'name': name, 'type': type});
      await fetchCategories();
      Get.snackbar('Success', 'Category added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add category: $e');
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('categories', where: 'id = ?', whereArgs: [id]);
      await fetchCategories();
      Get.snackbar('Success', 'Category deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete category: $e');
    }
  }

  List<CategoryModel> getCategoriesByType(String type) {
    if (type == 'both') return categories;
    return categories.where((c) => c.type == type || c.type == 'both').toList();
  }
}
