import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/data/models/app_models.dart';
import 'package:wareef_academy/logic/controllers/projects_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProjectFormScreen extends StatefulWidget {
  const ProjectFormScreen({super.key});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _controller = Get.find<ProjectsController>();
  final List<String> _categories = ['تقني', 'فني', 'تجاري', 'حرفي', 'تعليمي', 'أخرى'];
  String _selectedCategory = 'تقني';
  String? _imagePath;
  List<String> _galleryImages = [];
  ProjectModel? _editingProject;

  @override
  void initState() {
    super.initState();
    _editingProject = Get.arguments as ProjectModel?;
    if (_editingProject != null) {
      _titleController.text = _editingProject!.title;
      _descriptionController.text = _editingProject!.description;
      _phoneController.text = _editingProject!.ownerPhone ?? '';
      _imagePath = _editingProject!.imagePath;
      _selectedCategory = _editingProject!.category;
      if (_editingProject!.galleryImages != null && _editingProject!.galleryImages!.isNotEmpty) {
        _galleryImages = _editingProject!.galleryImages!.split(',');
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _pickGalleryImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _galleryImages.addAll(images.map((e) => e.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editingProject == null ? 'add_project'.tr : 'edit_project'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'title'.tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'required'.tr : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'project_category_label'.tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories.map((c) {
                  final Map<String, String> categoryKeys = {
                    'الكل': 'cat_all',
                    'تقني': 'cat_tech',
                    'فني': 'cat_arts',
                    'تجاري': 'cat_commercial',
                    'حرفي': 'cat_crafts',
                    'تعليمي': 'cat_educational',
                    'أخرى': 'cat_other'
                  };
                  return DropdownMenuItem(value: c, child: Text(categoryKeys[c]?.tr ?? c));
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'photographer_phone'.tr,
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'required'.tr : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'description'.tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'required'.tr : null,
              ),
              const SizedBox(height: 20),
              Text('cover_image_optional'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            Text('pick_image'.tr),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text('your_works_gallery'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _galleryImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _galleryImages.length) {
                      return GestureDetector(
                        onTap: _pickGalleryImages,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_photo_alternate_outlined),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: FileImage(File(_galleryImages[index])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => setState(() => _galleryImages.removeAt(index)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final galleryString = _galleryImages.join(',');
                      if (_editingProject == null) {
                        await _controller.addProject(
                          _titleController.text, 
                          _descriptionController.text, 
                          imagePath: _imagePath, 
                          ownerPhone: _phoneController.text,
                          galleryImages: galleryString,
                          category: _selectedCategory
                        );
                      } else {
                        await _controller.updateProject(
                          _editingProject!.id!, 
                          _titleController.text, 
                          _descriptionController.text, 
                          imagePath: _imagePath, 
                          ownerPhone: _phoneController.text,
                          galleryImages: galleryString,
                          category: _selectedCategory
                        );
                      }
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text('save'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
