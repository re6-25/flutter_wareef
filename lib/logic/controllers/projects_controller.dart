import 'package:get/get.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/data/providers/database_helper.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';

class ProjectsController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;
  final _authController = Get.find<AuthController>();

  RxList<ProjectModel> projects = <ProjectModel>[].obs;
  RxList<ProjectModel> filteredProjects = <ProjectModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  void filterProjects(String query) {
    if (query.isEmpty) {
      filteredProjects.value = projects;
    } else {
      filteredProjects.value = projects
          .where((p) => p.title.toLowerCase().contains(query.toLowerCase()) || 
                       p.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> fetchProjects() async {
    try {
      isLoading.value = true;
      final db = await _dbHelper.database;
      final user = _authController.currentUser.value;

      List<Map<String, dynamic>> maps;
      if (user == null) {
        // Guest: Only approved
        maps = await db.query('projects', where: 'status = ? AND is_deleted = 0', whereArgs: ['Approved']);
      } else if (user.roleId == 1) {
        // Admin: All
        maps = await db.query('projects', where: 'is_deleted = 0');
      } else {
        // Wareefa: Own
        maps = await db.query('projects', where: 'owner_id = ? AND is_deleted = 0', whereArgs: [user.id]);
      }
      projects.value = maps.map((e) => ProjectModel.fromMap(e)).toList();
      filteredProjects.value = projects;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch projects: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addProject(String title, String description, {String? imagePath, String category = 'Other'}) async {
    final user = _authController.currentUser.value;
    if (user == null) return;

    final project = ProjectModel(
      title: title,
      description: description,
      ownerId: user.id!,
      imagePath: imagePath,
      category: category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final db = await _dbHelper.database;
    await db.insert('projects', project.toMap());
    fetchProjects();
  }

  Future<void> updateProject(int id, String title, String description, {String? imagePath, String? category}) async {
    final db = await _dbHelper.database;
    final Map<String, dynamic> values = {
      'title': title,
      'description': description,
      'image_path': imagePath,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (category != null) values['category'] = category;

    await db.update(
      'projects',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchProjects();
  }

  Future<void> deleteProject(int id) async {
    final db = await _dbHelper.database;
    // Logical delete as per requirement fields (is_deleted)
    await db.update(
      'projects',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchProjects();
  }

  Future<void> updateStatus(int id, String status) async {
    final db = await _dbHelper.database;
    await db.update(
      'projects',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchProjects();
  }
}
