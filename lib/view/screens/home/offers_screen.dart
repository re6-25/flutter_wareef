import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/logic/controllers/courses_controller.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CoursesController>();
    
    // Filter courses that are considered "Special Offers" (those with price change in description or specific category)
    final offers = controller.courses.where((c) => c.description.contains('بدل') || c.description.contains('عرض')).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('عروض وريف الحصرية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: offers.isEmpty 
      ? const Center(child: Text('لا توجد عروض حالياً، تابعونا قريباً!'))
      : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            final course = offers[index];
            return Card(
              margin: const EdgeInsets.bottom(20),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Stack(
                    children: [
                      course.imagePath != null
                          ? (course.imagePath!.startsWith('assets/')
                              ? Image.asset(course.imagePath!, height: 180, width: double.infinity, fit: BoxFit.cover)
                              : Image.file(File(course.imagePath!), height: 180, width: double.infinity, fit: BoxFit.cover))
                          : Container(height: 180, color: AppColors.primary, child: const Icon(Icons.star, size: 50, color: Colors.white)),
                      Positioned(
                        top: 15,
                        left: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                          ),
                          child: const Text('خصم خاص 🔥', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        const SizedBox(height: 8),
                        Text(course.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => Get.toNamed('/course-details', arguments: course),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('احجزي مكانك الآن'),
                            ),
                            const Icon(Icons.arrow_forward_ios, color: AppColors.secondary, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
    );
  }
}
