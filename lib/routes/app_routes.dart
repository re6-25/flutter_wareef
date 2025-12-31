import 'package:get/get.dart';
import 'package:wareef_academy/view/screens/auth/login_screen.dart';
import 'package:wareef_academy/view/screens/auth/register_screen.dart';
import 'package:wareef_academy/view/screens/home/home_screen.dart';
import 'package:wareef_academy/view/screens/projects/project_details_screen.dart';
import 'package:wareef_academy/view/screens/projects/project_form_screen.dart';
import 'package:wareef_academy/view/screens/courses/course_form_screen.dart';
import 'package:wareef_academy/view/screens/courses/course_details_screen.dart';
import 'package:wareef_academy/view/screens/admin/users_management_screen.dart';
import 'package:wareef_academy/view/screens/admin/roles_management_screen.dart';
import 'package:wareef_academy/view/screens/admin/admin_dashboard_screen.dart';
import 'package:wareef_academy/view/screens/onboarding/onboarding_screen.dart';
import 'package:wareef_academy/view/screens/admin/manage_announcements_screen.dart';

class AppRoutes {
  static const initial = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const projectDetails = '/project-details';
  static const projectForm = '/project-form';
  static const courseDetails = '/course-details';
  static const courseForm = '/course-form';
  static const manageAnnouncements = '/manage-announcements';

  static final routes = [
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: register, page: () => const RegisterScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: projectDetails, page: () => const ProjectDetailsScreen()),
    GetPage(name: projectForm, page: () => const ProjectFormScreen()),
    GetPage(name: courseDetails, page: () => const CourseDetailsScreen()),
    GetPage(name: courseForm, page: () => const CourseFormScreen()),
    GetPage(name: '/users-management', page: () => const UsersManagementScreen()),
    GetPage(name: '/roles-management', page: () => const RolesManagementScreen()),
    GetPage(name: '/admin-dashboard', page: () => const AdminDashboardScreen()),
    GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
  ];
}
