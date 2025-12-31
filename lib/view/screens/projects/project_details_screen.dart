import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/logic/controllers/projects_controller.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key});

  Future<void> _launchWhatsApp(String phone) async {
    final link = 'https://api.whatsapp.com/send?phone=$phone';
    if (!await launchUrl(Uri.parse(link))) {
      Get.snackbar('Error', 'Could not launch WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;
    final authController = Get.find<AuthController>();
    final projectsController = Get.find<ProjectsController>();

    final bool canEdit = authController.currentUser.value?.id == project.ownerId;
    final bool isAdmin = authController.isAdmin;

    List<String> gallery = [];
    if (project.galleryImages != null && project.galleryImages!.isNotEmpty) {
      gallery = project.galleryImages!.split(',');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: project.imagePath != null
                  ? Image.file(File(project.imagePath!), fit: BoxFit.cover)
                  : Container(color: AppColors.primary, child: const Icon(Icons.palette, size: 80, color: Colors.white)),
            ),
            actions: [
              if (canEdit)
                IconButton(
                  icon: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.edit, color: Colors.white)),
                  onPressed: () => Get.toNamed('/project-form', arguments: project),
                ),
              if (canEdit || isAdmin)
                IconButton(
                  icon: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.delete, color: Colors.white)),
                  onPressed: () => _confirmDelete(project.id!),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(project.category, style: const TextStyle(color: AppColors.secondaryVariant, fontWeight: FontWeight.bold)),
                      ),
                      _buildStatusChip(project.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(project.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  const Divider(color: AppColors.secondary, thickness: 1),
                  const SizedBox(height: 16),
                  const Text('عن هذا المشروع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(project.description, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87)),
                  
                  const SizedBox(height: 30),
                  const Text('مبدعة المشروع (الوريفة)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  _buildOwnerCard(project),
                  
                  if (gallery.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    const Text('معرض الأعمال السابقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: gallery.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => _viewImage(gallery[index]),
                            child: Image.file(File(gallery[index]), fit: BoxFit.cover),
                          ),
                        );
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                  if (isAdmin && project.status == 'Pending') ...[
                     const Text('إجراءات الإدارة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 16),
                     Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => projectsController.updateStatus(project.id!, 'Approved').then((_) => Get.back()),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('قبول المشروع'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => projectsController.updateStatus(project.id!, 'Rejected').then((_) => Get.back()),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('رفض'),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerCard(ProjectModel project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.softGreen,
            child: Icon(Icons.person, color: AppColors.primary, size: 35),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('صاحبة الإبداع', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('الوريفة المبدعة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ),
          if (project.ownerPhone != null && project.ownerPhone!.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => _launchWhatsApp(project.ownerPhone!),
              icon: const Icon(Icons.message, size: 18),
              label: const Text('واتساب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'Approved' ? AppColors.success : (status == 'Rejected' ? AppColors.error : AppColors.warning);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.tr, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  void _viewImage(String path) {
    Get.to(() => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(child: InteractiveViewer(child: Image.file(File(path)))),
    ));
  }

  void _confirmDelete(int id) {
    Get.defaultDialog(
      title: 'حذف المشروع',
      middleText: 'هل أنت متأكد من حذف هذا الإبداع؟',
      onConfirm: () {
        Get.find<ProjectsController>().deleteProject(id);
        Get.back(); // close dialog
        Get.back(); // close screen
      },
      textConfirm: 'حذف',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
    );
  }
}
