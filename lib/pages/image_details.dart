import 'package:flutter/material.dart';
import 'package:family/models/images.dart';
import 'package:intl/intl.dart';

class ImageDetailsPage extends StatelessWidget {
  final ImageModel image;

  const ImageDetailsPage({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(image.time);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          centerTitle: true,
          title: const Text(
            'Image Details',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFFA87CEC),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.network(
                image.imageURL,
                fit: BoxFit.contain, // giữ đúng tỉ lệ ảnh, không crop, không bóp méo
              ),
            ),
          ),
          Container(
            height: 140,
            width: double.infinity, // full chiều rộng
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F8FD),
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '" ${image.description} "',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(
                        0xFF2A2730)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Uploaded by: ${image.uploadedBy}',
                    style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Time: $formattedDate',
                    style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),


    );
  }
}
