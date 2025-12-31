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
    _seedIfEmpty().then((_) => fetchAnnouncements());
  }

  Future<void> _seedIfEmpty() async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM announcements')) ?? 0;
    
    // Check if the promo announcement already exists
    final promoCheck = await db.query('announcements', where: 'title LIKE ?', whereArgs: ['%عروض نهاية العام%']);

    if (promoCheck.isEmpty) {
      await addAnnouncement(
        '🎁 عروض وريف لنهاية العام 🎁',
        'لفترة محدودة جداً! استثمري في نفسك مع عروضنا الحصرية على كافة الدورات. لا تضيعي الفرصة وكوني من المبدعات!',
        imagePath: 'assets/images/year_end_promo.png',
      );
    }

    if (count == 0) {
      await addAnnouncement(
        'مرحباً بكم في أكاديمية وريف 🎊',
        'يسرنا الإعلان عن افتتاح قسم المشاريع التقنية الجديد لدعم الوريفات المبدعات.',
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
  }

  Future<void> deleteAnnouncement(int id) async {
    final db = await _dbHelper.database;
    await db.delete('announcements', where: 'id = ?', whereArgs: [id]);
    fetchAnnouncements();
  }
}
