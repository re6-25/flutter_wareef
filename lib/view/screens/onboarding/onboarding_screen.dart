import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'onboarding_title_1'.tr,
      'body': 'onboarding_body_1'.tr,
      'image': 'assets/images/logo.png'
    },
    {
      'title': 'onboarding_title_2'.tr,
      'body': 'onboarding_body_2'.tr,
      'image': 'assets/images/background.png'
    },
    {
      'title': 'onboarding_title_3'.tr,
      'body': 'onboarding_body_3'.tr,
      'image': 'assets/images/logo.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: _pages.length,
            itemBuilder: (ctx, idx) => _buildPage(_pages[idx]),
          ),
          // Wave decoration or background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 30,
            right: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.offNamed('/login'),
                  child: Text('skip'.tr, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ),
                Row(
                  children: List.generate(_pages.length, (idx) => _buildDot(idx)),
                ),
                GestureDetector(
                  onTap: () {
                    if (_currentPage == _pages.length - 1) {
                      Get.offNamed('/login');
                    } else {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _currentPage == _pages.length - 1 ? Icons.check : Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, String> page) {
    return Container(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Styled Image/Logo
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(
                image: AssetImage(page['image']!),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Text(
            page['title']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              page['body']!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: _currentPage == index ? 30 : 8,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.secondary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
