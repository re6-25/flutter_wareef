import 'dart:io';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static Completer<Database>? _dbCompleter;

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    if (_dbCompleter != null) return _dbCompleter!.future;
    
    _dbCompleter = Completer<Database>();
    try {
      _database = await _initDB('wareef_academy.db');
      _dbCompleter!.complete(_database);
      return _database!;
    } catch (e) {
      _dbCompleter!.completeError(e);
      _dbCompleter = null;
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 7,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE projects ADD COLUMN image_path TEXT');
      await db.execute('ALTER TABLE courses ADD COLUMN image_path TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE projects ADD COLUMN category TEXT DEFAULT "Other"');
      await db.execute('''
        CREATE TABLE announcements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          image_path TEXT,
          created_at TEXT
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE courses ADD COLUMN category TEXT DEFAULT "Other"');
    }
    if (oldVersion < 5) {
      // Use try-catch for ALTER TABLE to avoid errors if column already exists (sometimes happen during dev)
      try { await db.execute('ALTER TABLE projects ADD COLUMN owner_phone TEXT'); } catch(e) {}
      try { await db.execute('ALTER TABLE projects ADD COLUMN gallery_images TEXT'); } catch(e) {}
    }
    if (oldVersion < 6) {
      try { await db.execute('ALTER TABLE users ADD COLUMN profile_image TEXT'); } catch(e) {}
      try { await db.execute('ALTER TABLE courses ADD COLUMN price REAL DEFAULT 0.0'); } catch(e) {}
      
      await db.execute('''
        CREATE TABLE offers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          course_id INTEGER NOT NULL,
          discount_percentage REAL NOT NULL,
          image_path TEXT,
          created_at TEXT,
          FOREIGN KEY (course_id) REFERENCES courses (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL -- project, course, both
        )
      ''');

      // Seed default categories
      final defaultCats = [
        {'name': 'Arts', 'type': 'both'},
        {'name': 'Design', 'type': 'both'},
        {'name': 'Tech', 'type': 'both'},
        {'name': 'Crafts', 'type': 'both'},
        {'name': 'Educational', 'type': 'both'},
        {'name': 'Commercial', 'type': 'both'},
        {'name': 'Other', 'type': 'both'},
      ];
      for (var cat in defaultCats) {
        await db.insert('categories', cat);
      }
    }
    if (oldVersion < 7) {
      // Drop and recreate offers table with new schema
      await db.execute('DROP TABLE IF EXISTS offers');
      await db.execute('''
        CREATE TABLE offers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          course_id INTEGER NOT NULL,
          discount_percentage REAL NOT NULL,
          image_path TEXT,
          created_at TEXT,
          FOREIGN KEY (course_id) REFERENCES courses (id)
        )
      ''');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL'; // 0 for false, 1 for true
    const intType = 'INTEGER NOT NULL';

    // Roles Table
    await db.execute('''
      CREATE TABLE roles (
        id $idType,
        name $textType
      )
    ''');

    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username TEXT NOT NULL UNIQUE,
        password_hash $textType,
        salt $textType,
        role_id $intType,
        is_active $boolType DEFAULT 1,
        profile_image TEXT,
        created_at $textType,
        FOREIGN KEY (role_id) REFERENCES roles (id)
      )
    ''');

    // Projects Table
    await db.execute('''
      CREATE TABLE projects (
        id $idType,
        title $textType,
        description $textType,
        status $textType DEFAULT 'Pending', -- Pending, Approved, Rejected
        owner_id $intType,
        owner_phone TEXT,
        gallery_images TEXT,
        image_path TEXT,
        category TEXT DEFAULT 'Other',
        is_deleted $boolType DEFAULT 0,
        created_at $textType,
        updated_at $textType,
        FOREIGN KEY (owner_id) REFERENCES users (id)
      )
    ''');

    // Courses Table
    await db.execute('''
      CREATE TABLE courses (
        id $idType,
        title $textType,
        description $textType,
        price REAL DEFAULT 0.0,
        created_by $intType,
        image_path TEXT,
        category TEXT DEFAULT 'Other',
        created_at $textType,
        FOREIGN KEY (created_by) REFERENCES users (id)
      )
    ''');

    // Announcements Table
    await db.execute('''
      CREATE TABLE announcements (
        id $idType,
        title $textType,
        content $textType,
        image_path TEXT,
        created_at $textType
      )
    ''');

    // Offers Table
    await db.execute('''
      CREATE TABLE offers (
        id $idType,
        course_id $intType,
        discount_percentage REAL NOT NULL,
        image_path TEXT,
        created_at $textType,
        FOREIGN KEY (course_id) REFERENCES courses (id)
      )
    ''');

    // Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        name $textType,
        type $textType
      )
    ''');

    // Seed Initial Data (Roles & Admin)
    await db.insert('roles', {'name': 'Admin'});
    await db.insert('roles', {'name': 'Wareefa'});
    await db.insert('roles', {'name': 'Guest'});
    
    // Default Admin (Password: admin123 - will hash in real logic, but for seed we use simple one or handle it in AuthController)
    // For simplicity of seeding, we'll let AuthController handle initial admin if not exists

    // Seed default categories
    final defaultCats = [
      {'name': 'Arts', 'type': 'both'},
      {'name': 'Design', 'type': 'both'},
      {'name': 'Tech', 'type': 'both'},
      {'name': 'Crafts', 'type': 'both'},
      {'name': 'Educational', 'type': 'both'},
      {'name': 'Commercial', 'type': 'both'},
      {'name': 'Other', 'type': 'both'},
    ];
    for (var cat in defaultCats) {
      await db.insert('categories', cat);
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
