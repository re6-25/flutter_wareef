import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/logic/controllers/courses_controller.dart';
import 'dart:io';

class CourseCard extends StatelessWidget {
  final CourseModel course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final controller = Get.find<CoursesController>();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImage(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  course.category,
                  style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                if (course.price > 0)
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${course.price} SAR',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (authController.isAdmin) ...[
                      IconButton(
                        onPressed: () => Get.toNamed('/course-form', arguments: course),
                        icon: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(controller),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                    TextButton(
                      onPressed: () => Get.toNamed('/course-details', arguments: course),
                      child: const Text('View Course'),
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

  Widget _buildImage() {
    if (course.imagePath != null) {
      final isAsset = course.imagePath!.startsWith('assets');
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: isAsset
              ? Image.asset(course.imagePath!, fit: BoxFit.cover)
              : Image.file(File(course.imagePath!), fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: const Icon(Icons.school, size: 80, color: AppColors.primary),
    );
  }

  void _confirmDelete(CoursesController controller) {
    Get.defaultDialog(
      title: 'confirm_delete'.tr,
      middleText: 'delete_course_msg'.tr,
      textConfirm: 'delete'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteCourse(course.id!);
        Get.back();
      },
    );
  }
}
