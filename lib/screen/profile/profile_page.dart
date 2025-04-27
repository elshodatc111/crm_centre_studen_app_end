import 'dart:convert';
import 'package:crm_center_studen_app/screen/login/login_page.dart';
import 'package:crm_center_studen_app/screen/profile/password_update.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  final _storage = GetStorage();
  late String _token;

  @override
  void initState() {
    super.initState();
    _token = _storage.read('token') ?? '';
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse('https://crm-center.atko.tech/api/user/profile'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _profile = data;
          _isLoading = false;
        });
      } else {
        throw Exception("Status code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xatolik yuz berdi: $e")),
      );
    }
  }

  Future<void> _logout() async {
    try {
      final response = await http.post(
        Uri.parse('https://crm-center.atko.tech/api/user/logout'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );
      print(_token);
      print(response.statusCode);

      if (response.statusCode == 200) {
        await _storage.remove('token');
        Get.off(LoginPage());
      } else {
        final data = jsonDecode(response.body);
        final msg = data['message'] ?? 'Xatolik yuz berdi';
        Get.snackbar("Xatolik", msg.toString(), backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar("Xatolik", "Tarmoqqa ulanishda muammo", backgroundColor: Colors.red.shade100);
    }
  }


  void showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: const Text(
          "Rostdan ham chiqmoqchimisiz?",
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Bekor qilish"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text("Chiqish", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String formatNumber(num? value) {
    if (value == null) return "0";
    return NumberFormat.decimalPattern().format(value);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Colors.indigo;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(color: Colors.white)),
        backgroundColor: themeColor,
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
          ? const Center(child: Text("Foydalanuvchi ma'lumotlari topilmadi"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: themeColor.shade100,
              child: Text(
                (_profile!['user_name'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(fontSize: 36, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _profile!['user_name'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet,
                    color: (_profile!['balans'] ?? 0) >= 0 ? Colors.blue : Colors.red),
                const SizedBox(width: 4.0),
                Text("${formatNumber(_profile!['balans'])} so'm",
                    style: const TextStyle(fontSize: 20.0)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _profile!['email'] ?? '',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _itemAbout("Telefon raqam", _profile!['phone1'], Icons.phone_android),
                _itemAbout("Qo'shimcha telefon", _profile!['phone2'], Icons.phone),
                _itemAbout("Yashash manzil", _profile!['address'], Icons.location_on_outlined),
                _itemAbout("Tug'ilgan vaqt", formatDate(_profile!['birthday']), Icons.cake_outlined),
                _itemAbout(
                  "Holati",
                  _profile!['status'] == "true" ? "Faol" : "Nofaol",
                  Icons.verified_user_outlined,
                ),
                _itemAbout(
                  "Ro'yhatga olindi",
                  formatDate(_profile!['created_at']),
                  Icons.event_note,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const PasswordUpdate());
                },
                icon: const Icon(Icons.lock_outline, color: Colors.white),
                label: const Text("Parolni almashtirish", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: showLogoutConfirmation,
                icon: const Icon(Icons.logout),
                label: const Text("Chiqish"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemAbout(String title, String? value, IconData icon) {
    return SizedBox(
      width: Get.width * 0.42,
      child: Card(
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 16.0, color: Colors.deepPurpleAccent),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value?.isNotEmpty == true ? value! : "-",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
