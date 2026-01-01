import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/logic/controllers/offers_controller.dart';
import 'package:wareef_academy/logic/controllers/courses_controller.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final controller = Get.put(OffersController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('exclusive_offers'.tr, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          if (authController.isAdmin)
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 30),
              onPressed: () => _showAddOfferDialog(context, controller),
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Obx(() => controller.isLoading.value 
            ? const Center(child: CircularProgressIndicator())
            : controller.offersWithCourses.isEmpty 
              ? Center(child: Text('no_offers_currently'.tr))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 110, 16, 16),
                  itemCount: controller.offersWithCourses.length,
                  itemBuilder: (context, index) {
                    final offerData = controller.offersWithCourses[index];
                    return _buildOfferCard(context, offerData, authController, controller);
                  },
                )
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, Map<String, dynamic> offerData, AuthController auth, OffersController controller) {
    final originalPrice = (offerData['price'] ?? 0.0).toDouble();
    final discountPercentage = (offerData['discount_percentage'] ?? 0.0).toDouble();
    final discountedPrice = controller.calculateDiscountedPrice(originalPrice, discountPercentage);
    final imagePath = offerData['offer_image'] ?? offerData['course_image'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imagePath != null
                    ? (imagePath.startsWith('assets') 
                        ? Image.asset(imagePath, fit: BoxFit.cover)
                        : Image.file(File(imagePath), fit: BoxFit.cover))
                    : Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.local_offer, size: 50, color: AppColors.primary),
                      ),
                ),
              ),
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                      const SizedBox(width: 5),
                      Text('${discountPercentage.toStringAsFixed(0)}% ${'discount'.tr}', 
                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              if (auth.isAdmin)
                Positioned(
                  top: 15,
                  right: 15,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.black45),
                    onPressed: () => controller.deleteOffer(offerData['offer_id']),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offerData['title'] ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  offerData['description'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '${originalPrice.toStringAsFixed(0)} SAR',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${discountedPrice.toStringAsFixed(0)} SAR',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: Text('book_now'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOfferDialog(BuildContext context, OffersController controller) {
    final coursesController = Get.find<CoursesController>();
    final discountController = TextEditingController();
    int? selectedCourseId;

    Get.defaultDialog(
      title: 'add_new_offer'.tr,
      content: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Obx(() => DropdownButtonFormField<int>(
                  value: selectedCourseId,
                  decoration: InputDecoration(
                    labelText: 'select_course'.tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: coursesController.courses.map((course) {
                    return DropdownMenuItem<int>(
                      value: course.id,
                      child: Text('${course.title} (${course.price} SAR)'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedCourseId = value);
                  },
                )),
                const SizedBox(height: 16),
                TextField(
                  controller: discountController,
                  decoration: InputDecoration(
                    labelText: 'discount_percentage'.tr,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                if (selectedCourseId != null && discountController.text.isNotEmpty) ...[
                  Builder(
                    builder: (context) {
                      final course = coursesController.courses.firstWhere((c) => c.id == selectedCourseId);
                      final discount = double.tryParse(discountController.text) ?? 0;
                      final discountedPrice = controller.calculateDiscountedPrice(course.price, discount);
                      
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text('original_price'.tr + ': ${course.price.toStringAsFixed(0)} SAR',
                                 style: const TextStyle(decoration: TextDecoration.lineThrough)),
                            const SizedBox(height: 4),
                            Text('discounted_price'.tr + ': ${discountedPrice.toStringAsFixed(0)} SAR',
                                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
      confirm: ElevatedButton(
        onPressed: () {
          if (selectedCourseId != null && discountController.text.isNotEmpty) {
            final discount = double.tryParse(discountController.text) ?? 0;
            if (discount > 0 && discount <= 100) {
              controller.addOffer(selectedCourseId!, discount);
            } else {
              Get.snackbar('error'.tr, 'invalid_discount_percentage'.tr);
            }
          }
        },
        child: Text('save'.tr),
      ),
    );
  }
}
