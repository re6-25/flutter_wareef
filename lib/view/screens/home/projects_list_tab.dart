import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:wareef_academy/logic/controllers/projects_controller.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/view/widgets/project_card.dart';
import 'package:wareef_academy/logic/services/pdf_service.dart';
import 'package:wareef_academy/view/widgets/announcement_banner.dart';

class ProjectsListTab extends StatelessWidget {
  const ProjectsListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProjectsController());
    final authController = Get.find<AuthController>();
    final List<String> categories = ['الكل', 'تقني', 'فني', 'تجاري', 'حرفي', 'تعليمي', 'أخرى'];
    final RxString selectedCategory = 'الكل'.obs;

    final Map<String, String> categoryKeys = {
      'الكل': 'cat_all',
      'تقني': 'cat_tech',
      'فني': 'cat_arts',
      'تجاري': 'cat_commercial',
      'حرفي': 'cat_crafts',
      'تعليمي': 'cat_educational',
      'أخرى': 'cat_other'
    };

    // Integrated Filter logic
    void applyFilters() {
      if (selectedCategory.value == 'الكل') {
        controller.filterProjects(''); // Reset to all
      } else {
        controller.filteredProjects.value = controller.projects
            .where((p) => p.category == selectedCategory.value)
            .toList();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('projects'.tr),
        actions: [
          IconButton(
            onPressed: () => PdfService.generateProjectsReport(controller.filteredProjects),
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
          ),
          if (authController.isWareefa)
            IconButton(
              onPressed: () => Get.toNamed('/project-form'),
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
              onChanged: (value) => controller.filterProjects(value),
              decoration: InputDecoration(
                hintText: 'search_projects'.tr,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                children: categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(categoryKeys[cat]?.tr ?? cat),
                    selected: selectedCategory.value == cat,
                    onSelected: (selected) {
                      if (selected) {
                        selectedCategory.value = cat;
                        applyFilters();
                      }
                    },
                  ),
                )).toList(),
              )),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                if (controller.filteredProjects.isEmpty) return Center(child: Text('no_projects_found'.tr));

                return AnimationLimiter(
                  child: ListView.builder(
                    itemCount: controller.filteredProjects.length,
                    itemBuilder: (ctx, idx) {
                      final project = controller.filteredProjects[idx];
                      return AnimationConfiguration.staggeredList(
                        position: idx,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: ProjectCard(project: project),
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
