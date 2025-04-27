import 'dart:convert';
import 'package:crm_center_studen_app/screen/home/show_group.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // ← GetStorage import qilindi
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _groups = [];
  bool _isLoading = true;
  final GetStorage _storage = GetStorage(); // ← Storage ochildi
  late String _token; // ← token endi initState ichida olinadi

  @override
  void initState() {
    super.initState();
    _token = _storage.read('token') ?? ''; // ← Tokenni saqlangan joydan oldik
    fetchGroups();
  }

  Future<void> fetchGroups() async {
    if (_token.isEmpty) {
      // Agar token topilmasa
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token topilmadi. Qayta login qiling.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('https://crm-center.atko.tech/api/user/groups'),
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _groups = data['groups'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  String formatDate(String dateTime) {
    final date = DateTime.parse(dateTime);
    return DateFormat('yyyy-MM-dd').format(date);
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
            onTap: (){
              print(group['id']);
              Get.to(()=>ShowGroup(id: group['id'],group_name: group['group_name'],));
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                color: Colors.white70,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Text(
                      group['group_name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Boshlanish vaqti',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              group['lessen_start'] != null
                                  ? formatDate(group['lessen_start'])
                                  : '',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Tugash vaqti',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              group['lessen_end'] != null
                                  ? formatDate(group['lessen_end'])
                                  : '',
                              style: const TextStyle(fontSize: 20),
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
