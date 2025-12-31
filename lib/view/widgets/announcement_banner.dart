import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/logic/controllers/announcements_controller.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';
import 'dart:io';

class AnnouncementBanner extends StatelessWidget {
  const AnnouncementBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnnouncementsController());

    return Obx(() {
      if (controller.announcements.isEmpty) return const SizedBox.shrink();
      
      return InkWell(
        onTap: () => Get.toNamed('/offers'),
        child: Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 16),
          child: PageView.builder(
            itemCount: controller.announcements.length,
            itemBuilder: (context, index) {
              final announcement = controller.announcements[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryVariant],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  image: announcement.imagePath != null
                      ? DecorationImage(
                          image: (announcement.imagePath!.startsWith('assets/') 
                             ? AssetImage(announcement.imagePath!) as ImageProvider
                             : FileImage(File(announcement.imagePath!))),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      announcement.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
