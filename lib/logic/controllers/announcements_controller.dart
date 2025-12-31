import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/data/providers/database_helper.dart';

class AnnouncementsController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;
  RxList<AnnouncementModel> announcements = <AnnouncementModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _seedIfEmpty();
    fetchAnnouncements();
  }

  Future<void> _seedIfEmpty() async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM announcements')) ?? 0;
    if (count == 0) {
      await addAnnouncement(
        'مرحباً بكم في أكاديمية وريف 🎊',
        'يسرنا الإعلان عن افتتاح قسم المشاريع التقنية الجديد لدعم الوريفات المبدعات.',
      );
      await addAnnouncement(
        'بادروا بالتسجيل في دورة "فن الخط العربي" 🖋️',
        'دورة تدريبية مكثفة تقدمها نخبة من المدربين المتميزين، لا تفوتوا الفرصة!',
      );
      await addAnnouncement(
        'تحديث جديد للتطبيق (نسخة 1.2) 🚀',
        'أصبح بإمكانكم الآن تصنيف مشاريعكم وتصدير تقاريركم بصيغة PDF.',
      );
    }
  }

  Future<void> fetchAnnouncements() async {
    try {
      isLoading.value = true;
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('announcements', orderBy: 'created_at DESC');
      announcements.value = maps.map((e) => AnnouncementModel.fromMap(e)).toList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAnnouncement(String title, String content, {String? imagePath}) async {
    final announcement = AnnouncementModel(
      title: title,
      content: content,
      imagePath: imagePath,
      createdAt: DateTime.now(),
    );
    final db = await _dbHelper.database;
    await db.insert('announcements', announcement.toMap());
    fetchAnnouncements();
  }

  Future<void> deleteAnnouncement(int id) async {
    final db = await _dbHelper.database;
    await db.delete('announcements', where: 'id = ?', whereArgs: [id]);
    fetchAnnouncements();
  }
}
