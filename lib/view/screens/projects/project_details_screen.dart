import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/logic/controllers/projects_controller.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;
    final authController = Get.find<AuthController>();
    final projectsController = Get.find<ProjectsController>();

    final bool canEdit = authController.currentUser.value?.id == project.ownerId;
    final bool isAdmin = authController.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Get.toNamed('/project-form', arguments: project),
            ),
          if (canEdit || isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _confirmDelete(project.id!),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(File(project.imagePath!), height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 24),
            ],
            _buildInfoCard('Status', project.status, _getStatusColor(project.status)),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(project.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            if (isAdmin && project.status == 'Pending') ...[
              const Divider(),
              const SizedBox(height: 16),
              const Text('Admin Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => projectsController.updateStatus(project.id!, 'Approved').then((_) => Get.back()),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => projectsController.updateStatus(project.id!, 'Rejected').then((_) => Get.back()),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved': return Colors.green;
      case 'Rejected': return Colors.red;
      default: return Colors.orange;
    }
  }

  void _confirmDelete(int id) {
    Get.defaultDialog(
      title: 'Delete Project',
      middleText: 'Are you sure you want to delete this project?',
      onConfirm: () {
        Get.find<ProjectsController>().deleteProject(id);
        Get.back(); // close dialog
        Get.back(); // close screen
      },
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
    );
  }
}
