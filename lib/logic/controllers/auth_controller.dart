import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/data/providers/database_helper.dart';

class AuthController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;
  final _prefs = SharedPreferences.getInstance();

  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
    _ensureAdminExists();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await _prefs;
    final userId = prefs.getInt('user_id');
    if (userId != null) {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (maps.isNotEmpty) {
        currentUser.value = UserModel.fromMap(maps.first);
      }
    }
  }

  Future<void> _ensureAdminExists() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> admins = await db.query(
      'users',
      where: 'role_id = ?',
      whereArgs: [1], // Admin role id
    );

    if (admins.isEmpty) {
      // Check if username 'admin' already exists with other role (unlikely but safe)
      final existing = await db.query('users', where: 'username = ?', whereArgs: ['admin']);
      if (existing.isEmpty) {
        await _internalRegister('admin', 'admin123', 1);
      }
    }
  }

  String _generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    return sha256.convert(bytes).toString();
  }

  // Internal registration without UI feedback for seeding
  Future<void> _internalRegister(String username, String password, int roleId) async {
    final salt = _generateSalt();
    final hash = _hashPassword(password.trim(), salt);
    final user = UserModel(
      username: username.trim(),
      passwordHash: hash,
      salt: salt,
      roleId: roleId,
      createdAt: DateTime.now(),
    );
    final db = await _dbHelper.database;
    await db.insert('users', user.toMap());
  }

  Future<bool> register(String username, String password, int roleId) async {
    try {
      isLoading.value = true;
      
      // Check if username exists first to give better error message
      final db = await _dbHelper.database;
      final existing = await db.query('users', where: 'username = ?', whereArgs: [username.trim()]);
      
      if (existing.isNotEmpty) {
        Get.snackbar('error'.tr, 'username_exists'.tr);
        return false;
      }

      await _internalRegister(username, password, roleId);
      return true;
    } catch (e) {
      Get.snackbar('error'.tr, 'Registration failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      isLoading.value = true;
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> users = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username.trim()],
      );

      if (users.isEmpty) {
        Get.snackbar('error'.tr, 'user_not_found'.tr);
        return false;
      }

      final userMap = users.first;
      final salt = userMap['salt'];
      final storedHash = userMap['password_hash'];
      final inputHash = _hashPassword(password.trim(), salt);

      if (storedHash == inputHash) {
        final user = UserModel.fromMap(userMap);
        currentUser.value = user;
        
        final prefs = await _prefs;
        await prefs.setInt('user_id', user.id!);
        await prefs.setInt('role_id', user.roleId);
        
        return true;
      } else {
        Get.snackbar('error'.tr, 'invalid_password'.tr);
        return false;
      }
    } catch (e) {
      Get.snackbar('error'.tr, 'Login failed: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    currentUser.value = null;
    final prefs = await _prefs;
    await prefs.remove('user_id');
    await prefs.remove('role_id');
    Get.offAllNamed('/login');
  }

  Future<void> updateProfileImage(String path) async {
    if (currentUser.value == null) return;
    try {
      final db = await _dbHelper.database;
      await db.update(
        'users',
        {'profile_image': path},
        where: 'id = ?',
        whereArgs: [currentUser.value!.id],
      );
      
      // Update local state
      final updatedUser = UserModel(
        id: currentUser.value!.id,
        username: currentUser.value!.username,
        passwordHash: currentUser.value!.passwordHash,
        salt: currentUser.value!.salt,
        roleId: currentUser.value!.roleId,
        isActive: currentUser.value!.isActive,
        profileImage: path,
        createdAt: currentUser.value!.createdAt,
      );
      currentUser.value = updatedUser;
      Get.snackbar('success'.tr, 'profile_image_updated'.tr);
    } catch (e) {
      Get.snackbar('error'.tr, 'Failed to update profile image: $e');
    }
  }

  bool get isAdmin => currentUser.value?.roleId == 1;
  bool get isWareefa => currentUser.value?.roleId == 2;
  bool get isGuest => currentUser.value == null || currentUser.value?.roleId == 3;
}
