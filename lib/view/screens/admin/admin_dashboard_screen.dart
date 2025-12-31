import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wareef_academy/logic/controllers/dashboard_controller.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الأداء العام', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildStatCard('المستخدمين', controller.totalUsers.value.toString(), Icons.people, Colors.blue)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildStatCard('الدورات', controller.totalCourses.value.toString(), Icons.school, Colors.orange)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildStatCard('مشاريع مقبولة', controller.approvedProjects.value.toString(), Icons.check_circle, Colors.green)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildStatCard('مشاريع معلقة', controller.pendingProjects.value.toString(), Icons.pending, Colors.redAccent)),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('توزيع المشاريع حسب النوع', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => Get.toNamed('/manage-announcements'),
                    icon: const Icon(Icons.campaign, color: Colors.blue),
                    tooltip: 'إدارة الإعلانات',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (controller.categoriesCount.isEmpty)
                const Center(child: Text('لا توجد بيانات متاحة بعد'))
              else
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (controller.categoriesCount.values.toList()..sort()).last.toDouble() + 1,
                      barGroups: controller.categoriesCount.entries.map((e) {
                        return BarChartGroupData(
                          x: controller.categoriesCount.keys.toList().indexOf(e.key),
                          barRods: [
                            BarChartRodData(
                              toY: e.value.toDouble(),
                              color: AppColors.primary,
                              width: 25,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final int index = value.toInt();
                              if (index < 0 || index >= controller.categoriesCount.length) return const Text('');
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(controller.categoriesCount.keys.toList()[index], style: const TextStyle(fontSize: 10)),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 15),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
