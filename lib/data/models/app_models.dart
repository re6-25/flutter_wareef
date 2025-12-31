class UserModel {
  final int? id;
  final String username;
  final String passwordHash;
  final String salt;
  final int roleId;
  final bool isActive;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.salt,
    required this.roleId,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password_hash': passwordHash,
      'salt': salt,
      'role_id': roleId,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      passwordHash: map['password_hash'],
      salt: map['salt'],
      roleId: map['role_id'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class ProjectModel {
  final int? id;
  final String title;
  final String description;
  final String status;
  final int ownerId;
  final String? imagePath;
  final String category;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    this.id,
    required this.title,
    required this.description,
    this.status = 'Pending',
    required this.ownerId,
    this.imagePath,
    this.category = 'Other',
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'owner_id': ownerId,
      'image_path': imagePath,
      'category': category,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      status: map['status'] ?? 'Pending',
      ownerId: map['owner_id'],
      imagePath: map['image_path'],
      category: map['category'] ?? 'Other',
      isDeleted: map['is_deleted'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

class AnnouncementModel {
  final int? id;
  final String title;
  final String content;
  final String? imagePath;
  final DateTime createdAt;

  AnnouncementModel({
    this.id,
    required this.title,
    required this.content,
    this.imagePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      imagePath: map['image_path'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class CourseModel {
  final int? id;
  final String title;
  final String description;
  final String? imagePath;
  final String category;
  final int createdBy;
  final DateTime createdAt;

  CourseModel({
    this.id,
    required this.title,
    required this.description,
    this.imagePath,
    this.category = 'Other',
    required this.createdBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_path': imagePath,
      'category': category,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      imagePath: map['image_path'],
      category: map['category'] ?? 'Other',
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
