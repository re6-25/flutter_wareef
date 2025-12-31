import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:wareef_academy/logic/controllers/courses_controller.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/view/widgets/course_card.dart';
import 'package:wareef_academy/view/widgets/announcement_banner.dart';

class CoursesListTab extends StatelessWidget {
  const CoursesListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CoursesController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('courses'.tr),
        actions: [
          if (authController.isAdmin)
            IconButton(
              onPressed: () => Get.toNamed('/course-form'),
              icon: const Icon(Icons.add_circle, size: 30),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const AnnouncementBanner(),
            TextField(
              onChanged: (value) => controller.filterCourses(value),
              decoration: InputDecoration(
                hintText: 'search_courses'.tr,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 12),
            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                children: ['All', 'Arts', 'Design', 'Tech', 'Crafts', 'Other'].map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(cat == 'All' ? 'الكل' : cat),
                      selected: controller.selectedCategory.value == cat,
                      onSelected: (selected) {
                        controller.filterByCategory(cat);
                      },
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    ),
                  );
                }).toList(),
              )),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                if (controller.filteredCourses.isEmpty) return Center(child: Text('no_courses_found'.tr));

                return AnimationLimiter(
                  child: ListView.builder(
                    itemCount: controller.filteredCourses.length,
                    itemBuilder: (ctx, idx) {
                      final course = controller.filteredCourses[idx];
                      return AnimationConfiguration.staggeredList(
                        position: idx,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: CourseCard(course: course),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
