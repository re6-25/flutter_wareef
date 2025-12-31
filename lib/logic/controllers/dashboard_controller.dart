import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wareef_academy/data/providers/database_helper.dart';

class DashboardController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;

  RxInt totalUsers = 0.obs;
  RxInt totalWareefas = 0.obs;
  RxInt approvedProjects = 0.obs;
  RxInt pendingProjects = 0.obs;
  RxInt totalCourses = 0.obs;
  RxMap<String, int> categoriesCount = <String, int>{}.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStats();
  }

  Future<void> fetchStats() async {
    try {
      isLoading.value = true;
      final db = await _dbHelper.database;

      totalUsers.value = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users')) ?? 0;
      totalWareefas.value = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users WHERE role_id = 2')) ?? 0;
      approvedProjects.value = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM projects WHERE status = "Approved" AND is_deleted = 0')) ?? 0;
      pendingProjects.value = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM projects WHERE status = "Pending" AND is_deleted = 0')) ?? 0;
      totalCourses.value = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM courses')) ?? 0;

      // Category Stats
      final List<Map<String, dynamic>> catResults = await db.rawQuery('SELECT category, COUNT(*) as count FROM projects WHERE is_deleted = 0 GROUP BY category');
      final Map<String, int> counts = {};
      for (var row in catResults) {
        counts[row['category'] as String] = row['count'] as int;
      }
      categoriesCount.value = counts;
    } finally {
      isLoading.value = false;
    }
  }
}
