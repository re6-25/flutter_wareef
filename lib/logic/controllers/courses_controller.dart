import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/data/providers/database_helper.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';

class CoursesController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;
  final _authController = Get.find<AuthController>();

  RxList<CourseModel> courses = <CourseModel>[].obs;
  RxList<CourseModel> filteredCourses = <CourseModel>[].obs;
  RxBool isLoading = false.obs;
  RxString selectedCategory = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCourses().then((_) => _seedNewCourses());
  }

  void filterCourses(String query) {
    _applyFilters(query: query);
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  void _applyFilters({String query = ''}) {
    Iterable<CourseModel> results = courses;
    
    if (selectedCategory.value != 'All') {
      results = results.where((c) => c.category == selectedCategory.value);
    }
    
    if (query.isNotEmpty) {
      results = results.where((c) => 
        c.title.toLowerCase().contains(query.toLowerCase()) || 
        c.description.toLowerCase().contains(query.toLowerCase())
      );
    }
    
    filteredCourses.value = results.toList();
  }

  Future<void> fetchCourses() async {
    try {
      isLoading.value = true;
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('courses');
      courses.value = maps.map((e) => CourseModel.fromMap(e)).toList();
      filteredCourses.value = courses;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch courses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _seedNewCourses() async {
    if (courses.any((c) => c.title.contains('الكاميو'))) return;

    final String waLink = 'https://api.whatsapp.com/send?phone=967775117639';

    // 1. Drawing Kids
    await addCourse(
      'دورة رسم الأطفال ✨',
      'تنمي موهبة طفلك. سجليه الآن الرابط 👇 \n$waLink',
      price: 2800.0,
      category: 'Arts',
      imagePath: 'assets/images/drawing_kids.png'
    );
    // 2. Wedding Invitations
    await addCourse(
      'تصميم دعوات الزفاف الورقية 💍',
      'أسرار التصميم باحترافية من جوالك. للتسجيل 👇 \n$waLink',
      price: 2800.0,
      category: 'Design',
      imagePath: 'assets/images/wedding_invitations.png'
    );
    // 3. Content Writing
    await addCourse(
      'دورة كتابة المحتوى ✍️',
      'تكتبي بثقة وتحولي موهبتك لمصدر دخل. الرابط 👇 \n$waLink',
      price: 2800.0,
      category: 'Tech',
      imagePath: 'assets/images/content_writing.png'
    );
    // 4. Polymer Clay
    await addCourse(
      'دورة الصلصال الحراري 🏺',
      'تحوّل موهبتك لقطع فنية مميزة. للتسجيل 👇 \n$waLink',
      price: 2800.0,
      category: 'Crafts',
      imagePath: 'assets/images/polymer_clay.png'
    );
    // 5. Resin Art
    await addCourse(
      'دورة فن الريزن 💎',
      'اصنعي قطع فخمة تُباع وتُطلب. سجل الآن 👇 \n$waLink',
      price: 2800.0,
      category: 'Crafts',
      imagePath: 'assets/images/resin_art.png'
    );
    // 6. Cameo
    await addCourse(
      'دورة الكاميو – القص الإلكتروني ✂️',
      'تعلمي استخدام الجهاز وقص الملصقات باحتراف. الرابط 👇 \n$waLink',
      price: 50.0,
      category: 'Crafts',
      imagePath: 'assets/images/cameo_course.png'
    );
    // 7. Photoshop
    await addCourse(
      'دورة الفوتوشوب المكثفة 💻',
      'تعديل الصور وتصميم البوستات الجذابة. للتسجيل 👇 \n$waLink',
      price: 50.0,
      category: 'Tech',
      imagePath: 'assets/images/photoshop_course.png'
    );
    // 8. Digital Invitations
    await addCourse(
      'دورة الدعوات الإلكترونية ✨',
      'تصميم دعوات أنيقة بلمسات بسيطة. سجل الآن 👇 \n$waLink',
      price: 50.0,
      category: 'Design',
      imagePath: 'assets/images/digital_invitations.png'
    );
    // 9. Knitting/Crochet
    await addCourse(
      'دورة الحياكة (الكروشيه) 🧶',
      'متعة وراحة وتحويل الخيوط لقطع فنية. للتسجيل 👇 \n$waLink',
      price: 20.0,
      category: 'Crafts',
      imagePath: 'assets/images/crochet_course.png'
    );
    
    fetchCourses();
  }

  Future<void> addCourse(String title, String description, {double price = 0.0, String? imagePath, String category = 'Other'}) async {
    final userId = _authController.currentUser.value?.id ?? 1;
    final course = CourseModel(
      title: title,
      description: description,
      price: price,
      imagePath: imagePath,
      category: category,
      createdBy: userId,
      createdAt: DateTime.now(),
    );
    final db = await _dbHelper.database;
    await db.insert('courses', course.toMap());
  }

  Future<void> updateCourse(int id, String title, String description, {double? price, String? imagePath, String? category}) async {
    final db = await _dbHelper.database;
    final Map<String, dynamic> values = {
      'title': title,
      'description': description,
    };
    if (price != null) values['price'] = price;
    if (imagePath != null) values['image_path'] = imagePath;
    if (category != null) values['category'] = category;
    
    await db.update('courses', values, where: 'id = ?', whereArgs: [id]);
    fetchCourses();
  }

  Future<void> deleteCourse(int id) async {
    final db = await _dbHelper.database;
    await db.delete('courses', where: 'id = ?', whereArgs: [id]);
    fetchCourses();
  }
}
