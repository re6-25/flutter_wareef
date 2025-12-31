import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wareef_academy/logic/controllers/auth_controller.dart';
import 'package:wareef_academy/view/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = Get.find<AuthController>();
  int _selectedRoleId = 2; // Default: Wareefa

  final List<Map<String, dynamic>> _roles = [
    {'id': 1, 'name': 'Admin / مسئول'},
    {'id': 2, 'name': 'Wareefa / وريفة'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Leaf pattern)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.9),
                  Colors.white,
                ],
              ),
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Small Logo or Icon
                    const Icon(Icons.eco, size: 80, color: AppColors.secondary),
                    const SizedBox(height: 20),
                    Text(
                      'sign_up'.tr,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'create_new_account'.tr,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    // Username Field
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                        hintText: 'username'.tr,
                        filled: true,
                        fillColor: Colors.grey[200]!.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'enter_username'.tr : null,
                    ),
                    const SizedBox(height: 20),
                    // Role Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedRoleId,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primary),
                        filled: true,
                        fillColor: Colors.grey[200]!.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _roles.map((role) {
                        return DropdownMenuItem<int>(
                          value: role['id'],
                          child: Text(role['name']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _selectedRoleId = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                        hintText: 'password'.tr,
                        filled: true,
                        fillColor: Colors.grey[200]!.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'enter_password'.tr;
                        if (value.length < 6) return 'password_too_short'.tr;
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Register Button
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _authController.isLoading.value
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      final success = await _authController.register(
                                        _usernameController.text,
                                        _passwordController.text,
                                        _selectedRoleId,
                                      );
                                      if (success) {
                                        Get.snackbar('success'.tr, 'account_created_msg'.tr);
                                        Get.back();
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                            ),
                            child: _authController.isLoading.value
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text('sign_up'.tr, style: const TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                        )),
                    const SizedBox(height: 20),
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('already_have_account'.tr),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'login'.tr,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
