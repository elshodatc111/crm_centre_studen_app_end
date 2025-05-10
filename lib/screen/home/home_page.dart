import 'dart:convert';
import 'package:crm_center_studen_app/screen/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:crm_center_studen_app/screen/home/show_group.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<dynamic> _groups = [];
  final GetStorage _storage = GetStorage();
  bool _isLoading = true;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchGroups();
  }

  Future<void> _loadTokenAndFetchGroups() async {
    final token = _storage.read('token') ?? '';
    if (token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _storage.erase();
        Get.offAll(() => const SplashPage());
      });
      setState(() => _isLoading = false);
      return;
    }

    _token = token;
    await fetchGroups();
  }


  Future<void> fetchGroups() async {
    try {
      final response = await http.get(
        Uri.parse('https://crm-center.atko.tech/api/user/groups'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final groups = data['groups'] ?? [];

        setState(() {
          _groups.clear();
          _groups.addAll(groups);
          _isLoading = false;
        });
      } else {
        _showSnackBar("Ma'lumotlarni olishda xatolik yuz berdi.");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar("Serverga ulanishda xatolik: $e");
      setState(() => _isLoading = false);
    }
  }

  String formatDate(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return '';
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guruhlar", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 3,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
          ? const Center(child: Text("Guruhlar topilmadi"))
          : ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          return InkWell(
            onTap: () {
              Get.to(() => ShowGroup(
                id: group['id'],
                group_name: group['group_name'],
              ));
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      group['group_name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Boshlanish',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatDate(group['lessen_start'] ?? ''),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Tugash',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatDate(group['lessen_end'] ?? ''),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
