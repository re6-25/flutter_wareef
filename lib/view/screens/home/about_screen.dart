import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      Get.snackbar('Error', 'Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('about_wareef_academy'.tr, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Hero(
                  tag: 'logo',
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
                      ],
                    ),
                    child: Image.asset('assets/images/logo.png', height: 120),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'WAREF ACADEMY',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('who_are_we'.tr, Icons.info_outline),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                        ),
                        child: Text(
                          'about_description'.tr,
                          style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSectionTitle('creativity_titles'.tr, Icons.share_outlined),
                      const SizedBox(height: 20),
                      _buildSocialCard(
                        'facebook'.tr,
                        'facebook_subtitle'.tr,
                        Icons.facebook,
                        const Color(0xFF1877F2),
                        'https://www.facebook.com/WareefAcademy/?locale=ar_AR',
                      ),
                      const SizedBox(height: 15),
                      _buildSocialCard(
                        'instagram'.tr,
                        'instagram_subtitle'.tr,
                        Icons.camera_alt,
                        const Color(0xFFE4405F),
                        'https://www.instagram.com/wareef_academy/',
                      ),
                      const SizedBox(height: 15),
                      _buildSocialCard(
                        'whatsapp'.tr,
                        'whatsapp_subtitle'.tr,
                        Icons.chat,
                        const Color(0xFF25D366),
                        'https://api.whatsapp.com/send?phone=967775117639',
                      ),
                      const SizedBox(height: 60),
                      Center(
                        child: Column(
                          children: [
                              Text(
                                'all_rights_reserved'.tr,
                                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                              ),
                              const SizedBox(height: 5),
                              Text('creativity_starts_here'.tr, style: const TextStyle(color: AppColors.secondary, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildSocialCard(String title, String subtitle, IconData icon, Color color, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
