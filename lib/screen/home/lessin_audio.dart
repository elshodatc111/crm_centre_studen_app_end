import 'package:crm_center_studen_app/screen/home/play_audio_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LessinAudio extends StatefulWidget {
  final List<dynamic> audio;

  const LessinAudio({super.key, required this.audio});

  @override
  State<LessinAudio> createState() => _LessinAudioState();
}

class _LessinAudioState extends State<LessinAudio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kurs audio lug'atlar",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: widget.audio.length,
          itemBuilder: (ctx, index) {
            final url = widget.audio[index]['audio_url'];
            final name = widget.audio[index]['audio_name'];
            return GestureDetector(
              onTap: () {
                Get.to(() => PlayAudioPage(audioUrl: url, audioName: name));
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),

                ),
                color: Colors.white70,
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: const Icon(Icons.audiotrack, color: Colors.indigo, size: 32),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: const Icon(Icons.play_arrow, color: Colors.indigo, size: 30),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
