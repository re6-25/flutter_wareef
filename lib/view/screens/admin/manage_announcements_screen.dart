import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/logic/controllers/announcements_controller.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ManageAnnouncementsScreen extends StatefulWidget {
  const ManageAnnouncementsScreen({super.key});

  @override
  State<ManageAnnouncementsScreen> createState() => _ManageAnnouncementsScreenState();
}

class _ManageAnnouncementsScreenState extends State<ManageAnnouncementsScreen> {
  final _controller = Get.put(AnnouncementsController());
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _imagePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _imagePath = image.path);
  }

  void _addAnnouncement() {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      _controller.addAnnouncement(_titleController.text, _contentController.text, imagePath: _imagePath);
      _titleController.clear();
      _contentController.clear();
      setState(() => _imagePath = null);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('manage_announcements_title'.tr)),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (_controller.announcements.isEmpty) return Center(child: Text('no_announcements_currently'.tr));

        return ListView.builder(
          itemCount: _controller.announcements.length,
          itemBuilder: (context, index) {
            final announcement = _controller.announcements[index];
            return ListTile(
              leading: announcement.imagePath != null
                  ? CircleAvatar(backgroundImage: FileImage(File(announcement.imagePath!)))
                  : const CircleAvatar(child: Icon(Icons.campaign)),
              title: Text(announcement.title),
              subtitle: Text(announcement.content, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _controller.deleteAnnouncement(announcement.id!),
              ),
            );
          },
        );
      }),
    );
  }

  void _showAddDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('add_new_announcement'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(controller: _titleController, decoration: InputDecoration(labelText: 'announcement_title'.tr)),
              const SizedBox(height: 10),
              TextField(controller: _contentController, decoration: InputDecoration(labelText: 'announcement_content'.tr), maxLines: 3),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                  child: _imagePath != null ? Image.file(File(_imagePath!), fit: BoxFit.cover) : const Icon(Icons.add_a_photo),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addAnnouncement,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: Text('send_announcement'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
