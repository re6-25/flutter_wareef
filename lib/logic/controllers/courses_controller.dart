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
    
    // Category Filter
    if (selectedCategory.value != 'All') {
      results = results.where((c) => c.category == selectedCategory.value);
    }
    
    // Search Query Filter
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
    // Check if the new courses are already added
    if (courses.any((c) => c.title.contains('رسم الأطفال'))) return;

    // Add Art Course
    await addCourse(
      'دورة رسم الأطفال ✨',
      'بتساعدهم وتشغل وقتهم وتطورهم وبسعر حلو ولأخر مرة تنفتح فيه الدورة 🥺 سجليه معنا الآن بسعر 2800 بس للتسجيل والاستفسار 👇 775117639',
      category: 'Arts',
      imagePath: 'assets/images/drawing_kids.png'
    );
    // Add Wedding Invitations
    await addCourse(
      'تصميم دعوات الزفاف الورقية 💍',
      'من جوالك وباحترافية مطلقة مع المبدعة إيناس العريقي. عرض خاص ومحدود جداً! استثمري في نفسك بـ 2800 ريال يمني بس بدلاً من 35 ريال!',
      category: 'Design',
      imagePath: 'assets/images/wedding_invitations.jpg'
    );
    // Add Content Writing
    await addCourse(
      'دورة كتابة المحتوى ✍️',
      'تكتبي بثقة بدون تردد، تعرفي كيف تقنعي وتبيعي بالكلام، تحولي كتابتك لمصدر دخل. السعر: 2800 ريال لفترة محدودة.',
      category: 'Tech',
      imagePath: 'assets/images/content_writing.png'
    );
    // Add Polymer Clay
    await addCourse(
      'دورة الصلصال الحراري 🏺',
      'تحوّل موهبتك لقطع فنية تنباع، وتعطيك مهارة يدوية مميزة تقدري تبدأي بها مشروعك. بسعر 2800 بدل 30 ر.س',
      category: 'Crafts',
      imagePath: 'assets/images/polymer_clay.jpg'
    );
    // Add Resin Art
    await addCourse(
      'دورة فن الريزن 💎',
      'تفتح لك باب دخل إبداعي، تعلّمك شغل مطلوب، وتخليك تصنعي قطع فخمة تُباع وتُطلب. سعر الدورة: 2800 ريال بدل 35 ر.س',
      category: 'Crafts',
      imagePath: 'assets/images/resin_art.jpg'
    );
    fetchCourses();
  }

  Future<void> addCourse(String title, String description, {String? imagePath, String category = 'Other'}) async {
    // If auth user is null, we use a default ID (for seeding)
    final userId = _authController.currentUser.value?.id ?? 1;

    final course = CourseModel(
      title: title,
      description: description,
      imagePath: imagePath,
      category: category,
      createdBy: userId,
      createdAt: DateTime.now(),
    );

    final db = await _dbHelper.database;
    await db.insert('courses', course.toMap());
  }

  Future<void> updateCourse(int id, String title, String description, {String? imagePath, String? category}) async {
    final db = await _dbHelper.database;
    final Map<String, dynamic> values = {
      'title': title,
      'description': description,
      'image_path': imagePath,
    };
    if (category != null) values['category'] = category;

    await db.update(
      'courses',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchCourses();
  }

  Future<void> deleteCourse(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
    fetchCourses();
  }
}
