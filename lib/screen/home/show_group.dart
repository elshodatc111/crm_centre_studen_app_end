import 'dart:convert';
import 'package:crm_center_studen_app/screen/home/cours_video_list.dart';
import 'package:crm_center_studen_app/screen/home/lessin_audio.dart';
import 'package:crm_center_studen_app/screen/home/lessin_day.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ShowGroup extends StatefulWidget {
  final int id;
  final String group_name;

  const ShowGroup({super.key, required this.id, required this.group_name});

  @override
  State<ShowGroup> createState() => _ShowGroupState();
}

class _ShowGroupState extends State<ShowGroup> {
  final GetStorage _storage = GetStorage();
  bool _isLoading = true;
  Map<String, dynamic>? _group;
  List<dynamic> _days = [];
  late final bool audio_status;
  List<dynamic> audio = [];
  late final bool video_status;
  List<dynamic> video = [];

  @override
  void initState() {
    super.initState();
    fetchGroupDetails();
  }

  Future<void> fetchGroupDetails() async {
    final String token = _storage.read('token') ?? '';

    if (token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Token topilmadi!')));
      setState(() => _isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('https://crm-center.atko.tech/api/user/group/${widget.id}'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _group = data['groups'];
        _days = data['days'];
        audio_status = (data['audio_status'] == 1); // Convert to bool
        audio = data['audios'];
        video_status = (data['video_status'] == 1); // Convert to bool
        video = data['video'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xatolik: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.group_name,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 3,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _group == null
              ? const Center(child: Text('Guruh maʼlumotlari topilmadi'))
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _group!['cours_name'] ?? 'Kurs nomi mavjud emas',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      buildItem(
                        "O‘qituvchi",
                        _group!['techer'] ?? 'N/A',
                        Icons.person,
                      ),
                      const SizedBox(height: 8),
                      buildItem(
                        "Dars xonasi",
                        _group!['room_name'] ?? 'N/A',
                        Icons.meeting_room,
                      ),
                      const SizedBox(height: 8),
                      buildItem(
                        "Dars vaqti",
                        _group!['time'] ?? 'N/A',
                        Icons.access_time,
                      ),
                      const SizedBox(height: 8),
                      buildItem(
                        "Kurs narxi",
                        '${_group!['price'] ?? 0} so‘m',
                        Icons.attach_money,
                      ),
                      const SizedBox(height: 8),
                      buildItem(
                        "Darslar soni",
                        "${_group!['lessen_count'] ?? 0} ta dars",
                        Icons.book,
                      ),
                      const SizedBox(height: 8),
                      buildItem(
                        "Boshlanish vaqti",
                        formatDate(_group!['lessen_start'] ?? ''),
                        Icons.calendar_today,
                      ),
                      const SizedBox(height: 8),
                      buildItem(
                        "Tugash vaqti",
                        formatDate(_group!['lessen_end'] ?? ''),
                        Icons.calendar_today,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: Get.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.blue,
                        ),
                        child: TextButton(
                          onPressed: () {
                            Get.to(() => LessinDay(days: _days));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                "Dars kunlari",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      audio_status?Container(
                        width: Get.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.deepPurpleAccent,
                        ),
                        child: TextButton(
                          onPressed: () {
                            Get.to(() => LessinAudio(audio: audio));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.headset, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                "Kurs audio lug'atlar",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ):const SizedBox.shrink(),
                      const SizedBox(height: 8),
                      video_status?Container(
                        width: Get.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.deepOrangeAccent,
                        ),
                        child: TextButton(
                          onPressed: () {
                            Get.to(() => CourseVideoList(videos: video));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_library, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                "Kurs video darslar",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ):const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget buildItem(String title, String? item, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.indigo),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        Text(
          item ?? 'N/A', // Fallback text if item is null
          style: const TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  Widget buildButton(String label, Color color, IconData icon) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: color,
      ),
      child: TextButton(
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(String dateTime) {
    if (dateTime.isEmpty) {
      return 'N/A';
    }
    final date = DateTime.parse(dateTime);
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
