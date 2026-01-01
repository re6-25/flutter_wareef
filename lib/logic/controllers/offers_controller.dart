import 'package:get/get.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/data/providers/database_helper.dart';

class OffersController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;

  RxList<Map<String, dynamic>> offersWithCourses = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    try {
      isLoading.value = true;
      final db = await _dbHelper.database;
      
      // Join offers with courses to get course details
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          offers.id as offer_id,
          offers.course_id,
          offers.discount_percentage,
          offers.image_path as offer_image,
          offers.created_at,
          courses.title,
          courses.description,
          courses.price,
          courses.image_path as course_image
        FROM offers
        INNER JOIN courses ON offers.course_id = courses.id
        ORDER BY offers.created_at DESC
      ''');
      
      offersWithCourses.value = maps;
    } catch (e) {
      print('Error fetching offers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addOffer(int courseId, double discountPercentage, {String? imagePath}) async {
    try {
      final db = await _dbHelper.database;
      final offer = OfferModel(
        courseId: courseId,
        discountPercentage: discountPercentage,
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );
      await db.insert('offers', offer.toMap());
      await fetchOffers();
      Get.snackbar('success'.tr, 'offer_added_successfully'.tr);
      Get.back();
    } catch (e) {
      Get.snackbar('error'.tr, 'Failed to add offer: $e');
    }
  }

  Future<void> deleteOffer(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete('offers', where: 'id = ?', whereArgs: [id]);
      await fetchOffers();
      Get.snackbar('success'.tr, 'offer_deleted_successfully'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'Failed to delete offer: $e');
    }
  }

  double calculateDiscountedPrice(double originalPrice, double discountPercentage) {
    return originalPrice - (originalPrice * discountPercentage / 100);
  }
}
