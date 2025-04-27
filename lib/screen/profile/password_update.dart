import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class PasswordUpdate extends StatefulWidget {
  const PasswordUpdate({super.key});

  @override
  State<PasswordUpdate> createState() => _PasswordUpdateState();
}

class _PasswordUpdateState extends State<PasswordUpdate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _storage = GetStorage();
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final token = _storage.read('token') ??
        '55|P8FZrjrUf8rWcjpSKoxJI6ENWw6QHDXsGwiqDFco2e4ba01a';

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse('https://crm-center.atko.tech/api/user/change/password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'current_password': _currentPasswordController.text,
        'new_password': _newPasswordController.text,
        'new_password_confirmation': _confirmPasswordController.text,
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _showMessageDialog("✅ Parol yangilandi", data['message'], success: true);
    } else {
      final error = jsonDecode(response.body);
      _showMessageDialog("❌ Xatolik", error['message'] ?? "Noma'lum xatolik yuz berdi");
    }
  }

  void _showMessageDialog(String title, String message, {bool success = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (success) Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.indigo;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Parolni yangilash"),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Iltimos, quyidagi maydonlarni to‘ldiring:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _currentPasswordController,
                label: "Joriy parol",
                hintText: "********",
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _newPasswordController,
                label: "Yangi parol",
                hintText: "Yangi parol kiriting",
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordController,
                label: "Yangi parolni tasdiqlang",
                hintText: "Yangi parolni qayta kiriting",
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return "Parollar mos emas";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _changePassword,
                  icon: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.lock_reset,color: Colors.white,),
                  label: Text(
                    _isLoading ? "Yuklanmoqda..." : "Parolni yangilash",
                    style: const TextStyle(fontSize: 16,color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return "Iltimos, $label ni kiriting";
            }
            if (value.length < 6) {
              return "Parol kamida 6 ta belgidan iborat bo‘lishi kerak";
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
