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
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
            ),
          ),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: project.id ?? 'project',
                    child: project.imagePath != null
                        ? Image.file(File(project.imagePath!), fit: BoxFit.cover)
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                            ),
                            child: const Icon(Icons.palette, size: 80, color: Colors.white),
                          ),
                  ),
                ),
                actions: [
                  if (canEdit)
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        onPressed: () => Get.toNamed('/project-form', arguments: project),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (canEdit || isAdmin)
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                        onPressed: () => _confirmDelete(project.id!),
                      ),
                    ),
                  const SizedBox(width: 15),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.category_outlined, size: 16, color: AppColors.secondary),
                                const SizedBox(width: 8),
                                Text(project.category, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          _buildStatusChip(project.status),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(project.title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 25),
                      _buildSectionHeader('about_this_creativity'.tr, Icons.description_outlined),
                      const SizedBox(height: 12),
                      Text(
                        project.description,
                        style: TextStyle(fontSize: 16, height: 1.8, color: Colors.grey[800]),
                      ),
                      const SizedBox(height: 35),
                      _buildSectionHeader('project_creator'.tr, Icons.person_pin_outlined),
                      const SizedBox(height: 15),
                      _buildOwnerCard(project),
                      if (gallery.isNotEmpty) ...[
                        const SizedBox(height: 35),
                        _buildSectionHeader('previous_works'.tr, Icons.collections_outlined),
                        const SizedBox(height: 15),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                          itemCount: gallery.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: InkWell(
                                    onTap: () => _viewImage(gallery[index]),
                                    child: Image.file(
                                      File(gallery[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      if (isAdmin && project.status == 'Pending') ...[
                        const SizedBox(height: 40),
                        _buildSectionHeader('admin_actions'.tr, Icons.admin_panel_settings_outlined),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => projectsController.updateStatus(project.id!, 'Approved').then((_) => Get.back()),
                                icon: const Icon(Icons.check_circle_outline),
                                label: Text('approve_creativity'.tr),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => projectsController.updateStatus(project.id!, 'Rejected').then((_) => Get.back()),
                                icon: const Icon(Icons.cancel_outlined),
                                label: Text('reject'.tr),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
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
                Text('owner_of_creativity'.tr, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text('creative_wareefa'.tr, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ),
          if (project.ownerPhone != null && project.ownerPhone!.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () => _launchWhatsApp(project.ownerPhone!),
              icon: const Icon(Icons.message, size: 18),
              label: Text('whatsapp'.tr),
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
      title: 'delete_project_title'.tr,
      middleText: 'delete_project_confirmation'.tr,
      onConfirm: () {
        Get.find<ProjectsController>().deleteProject(id);
        Get.back(); // close dialog
        Get.back(); // close screen
      },
      textConfirm: 'delete_confirm'.tr,
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
    );
  }
}
