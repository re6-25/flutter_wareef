import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/logic/controllers/courses_controller.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key});

  final String supervisorNumber = '967775117639';

  @override
  Widget build(BuildContext context) {
    final CourseModel course = Get.arguments;
    final authController = Get.find<AuthController>();
    final coursesController = Get.find<CoursesController>();

    final bool isAdmin = authController.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Get.toNamed('/course-form', arguments: course),
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _confirmDelete(course.id!),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (course.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(File(course.imagePath!), height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 24),
            ],
            Text('course_description'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(course.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            if (course.price > 0) ...[
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${'price'.tr}: ${course.price} SAR',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 32),
            if (!authController.isGuest)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _registerViaWhatsApp(course.title),
                  icon: const Icon(Icons.chat),
                  label: Text('whatsapp_register'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _registerViaWhatsApp(String courseTitle) async {
    final message = '${'whatsapp_register_msg'.tr} $courseTitle';
    final url = 'https://api.whatsapp.com/send?phone=$supervisorNumber&text=${Uri.encodeComponent(message)}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not launch WhatsApp');
    }
  }

  void _confirmDelete(int id) {
    Get.defaultDialog(
      title: 'delete_course_title'.tr,
      middleText: 'delete_course_confirmation'.tr,
      onConfirm: () {
        Get.find<CoursesController>().deleteCourse(id);
        Get.back(); // close dialog
        Get.back(); // close screen
      },
      textConfirm: 'delete_confirm'.tr,
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
    );
  }
}
