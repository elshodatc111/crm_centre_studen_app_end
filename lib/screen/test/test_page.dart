import 'dart:convert';
import 'package:crm_center_studen_app/screen/test/test_show.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final String apiUrl = 'https://crm-center.atko.tech/api/user/tests';

  Future<List<Map<String, dynamic>>> fetchTests() async {
    try {
      final box = GetStorage();
      String? token = box.read('token');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['testlar']);
      } else {
        debugPrint("API xatosi: \${response.statusCode} - \${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("Tarmoq xatosi: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Testlar", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 3,
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchTests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "❌ Testlar mavjud emas.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              );
            }

            final testlar = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemCount: testlar.length,
              itemBuilder: (context, index) {
                final test = testlar[index];
                return _buildTestCard(test);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTestCard(Map<String, dynamic> test) {
    List<Map<String, dynamic>> testList = List<Map<String, dynamic>>.from(test['testlar']);
    return GestureDetector(
      onTap: () {
        Get.to(() => TestShow(
          group_id: test['group_id'],
          group_name: test['group_name'],
          testlar: testList,
        ))?.then((_) {
          // This will be triggered when TestShow is popped back
          setState(() {
            // Refresh your data if needed, for example, calling fetchTests again
          });
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white70,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.white30,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      test['group_name'] ?? "Noma'lum guruh",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildInfoRow("Testlar: ${testList.length}"),
                        _buildInfoRow("Urinishlar: ${test['urinishlar'] ?? 0}"),
                        _buildInfoRow("To'g'ri javoblar: ${test['tugri_javob'] ?? 0}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }
}
