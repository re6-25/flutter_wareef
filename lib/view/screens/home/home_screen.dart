import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/view/screens/home/projects_list_tab.dart';
import 'package:wareef_academy/view/screens/home/courses_list_tab.dart';
import 'package:wareef_academy/view/screens/home/profile_tab.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _authController = Get.find<AuthController>();

  final List<Widget> _tabs = [
    const ProjectsListTab(),
    const CoursesListTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2 && _authController.currentUser.value == null) {
            Get.snackbar('Access Denied', 'Please login to view profile');
            return;
          }
          setState(() => _currentIndex = index);
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.assignment), label: 'projects'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.school), label: 'courses'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: 'profile'.tr),
        ],
      ),
    );
  }
}
