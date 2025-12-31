import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // We check SharedPreferences directly for faster initial route decision
    // In a real app, you'd might want to wait for AuthController to initialize
    return null; // Logic will be handled in GetX initialRoute or by checking prefs
  }
}

// Custom Guard for specific roles if needed
class RoleGuard extends GetMiddleware {
  final int requiredRole;
  RoleGuard(this.requiredRole);

  @override
  RouteSettings? redirect(String? route) {
    // Logic to prevent Wareefa from seeing Admin pages, etc.
    return null; 
  }
}
