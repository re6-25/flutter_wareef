import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/logic/controllers/projects_controller.dart';
import 'dart:io';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final controller = Get.find<ProjectsController>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (project.imagePath != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.file(
                  File(project.imagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            project.category,
                            style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(project.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  project.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (authController.isAdmin || (authController.isWareefa && project.ownerId == authController.currentUser.value?.id)) ...[
                      IconButton(
                        onPressed: () => Get.toNamed('/project-form', arguments: project),
                        icon: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(controller),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                    TextButton(
                      onPressed: () => Get.toNamed('/project-details', arguments: project),
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Approved': color = Colors.green; break;
      case 'Rejected': color = Colors.red; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(status.tr, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _confirmDelete(ProjectsController controller) {
    Get.defaultDialog(
      title: 'confirm_delete'.tr,
      middleText: 'delete_project_msg'.tr,
      textConfirm: 'delete'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteProject(project.id!);
        Get.back();
      },
    );
  }
}
