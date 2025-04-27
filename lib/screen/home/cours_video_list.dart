import 'package:crm_center_studen_app/screen/home/video_play.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CourseVideoList extends StatelessWidget {
  final List<dynamic> videos;
  const CourseVideoList({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kurs video darslari',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 3,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: videos.length,
        itemBuilder: (ctx, index) {
          final videoName = videos[index]['cours_name'];
          final videoUrl = videos[index]['video_url'];

          return GestureDetector(
            onTap: () {
              Get.to(() => VideoPlay(name: videoName, url: videoUrl));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: const Icon(
                      Icons.play_circle_fill,
                      size: 50,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            videoName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Video dars", // yoki boshqa ma'lumotlar
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.chevron_right, size: 30, color: Colors.indigo),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
