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
        title: const Text('عن أكاديمية وريف'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 100),
                  const SizedBox(height: 10),
                  const Text(
                    'WAREF ACADEMY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'من نحن؟',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'أكاديمية وريف هي منصة رائدة تهدف إلى تمكين الشابات المبدعات (الوريفات) من خلال تقديم دورات تدريبية احترافية في مجالات الفنون، التقنية، والأشغال اليدوية. نحن نؤمن بأن كل موهبة تستحق أن تتحول إلى مشروع ناجح، ولذلك نوفر بيئة محفزة تجمع بين التعلم والعرض والنمو.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'تواصلوا معنا عبر عوالمنا',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSocialCard(
                    'فيسبوك',
                    'تابعونا لآخر الأخبار والفعاليات',
                    Icons.facebook,
                    Colors.blue[900]!,
                    'https://www.facebook.com/WareefAcademy/?locale=ar_AR',
                  ),
                  const SizedBox(height: 12),
                  _buildSocialCard(
                    'إنستقرام',
                    'شاهدوا إبداعات وريفاتنا اليومية',
                    Icons.camera_alt,
                    Colors.pink[600]!,
                    'https://www.instagram.com/wareef_academy/',
                  ),
                  const SizedBox(height: 12),
                  _buildSocialCard(
                    'واتساب',
                    'للاستفسار والتسجيل المباشر',
                    Icons.chat,
                    Colors.green[600]!,
                    'https://api.whatsapp.com/send?phone=967775117639',
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'جميع الحقوق محفوظة © أكاديمية وريف 2024',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialCard(String title, String subtitle, IconData icon, Color color, String url) {
    return InkWell(
      onTap: () => _launchURL(url),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
