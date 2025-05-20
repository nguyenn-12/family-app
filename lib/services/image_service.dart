import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family/models/images.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ImageService {
  static Future<List<ImageModel>> fetchImagesByFamilyCode(String familyCode, {int page = 1, int pageSize = 15}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('images')
        .where('familyCode', isEqualTo: familyCode)
        .orderBy('time', descending: true)
        .get();

    final allDocs = snapshot.docs;

    // Tính toán vị trí bắt đầu và kết thúc dựa trên page và pageSize
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    // Lấy phần dữ liệu tương ứng
    final pagedDocs = allDocs.sublist(
      startIndex,
      endIndex > allDocs.length ? allDocs.length : endIndex,
    );

    final images = pagedDocs.map((doc) => ImageModel.fromMap(doc.id, doc.data())).toList();

    return images;
  }
  // static const String _clientId = '4a47796c6fc8864';

  // static Future<void> uploadImageAndSaveToFirestore({
  //   required Uint8List imageBytes,
  //   required String description,
  //   required String uploadedBy,
  //   required String familyCode,
  // }) async {
  //   try {
  //     // Upload ảnh lên Imgur
  //     final response = await http.post(
  //       Uri.parse('https://api.imgur.com/3/image'),
  //       headers: {
  //         'Authorization': 'Client-ID $_clientId',
  //       },
  //       body: {
  //         'image': base64Encode(imageBytes),
  //       },
  //     );
  //
  //     final data = jsonDecode(response.body);
  //     final imageUrl = data['data']['link'];
  //
  //     // Lưu thông tin ảnh vào Firestore
  //     await FirebaseFirestore.instance.collection('images').add({
  //       'imageURL': imageUrl,
  //       'description': description,
  //       'uploadedBy': uploadedBy,
  //       'familyCode': familyCode,
  //       'time': Timestamp.now(),
  //     });
  //   } catch (e) {
  //     throw Exception('Error uploading image: $e');
  //   }
  // }
  static Future<void> uploadImageAndSaveToFirestore({
    required Uint8List imageBytes,
    required String description,
    required String uploadedBy,
    required String familyCode,
  }) async {
    try {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/db1dhw93x/image/upload');

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'family'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: 'upload.jpg',
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await http.Response.fromStream(response);
        final data = jsonDecode(res.body);
        final imageUrl = data['secure_url']; // đây là URL ảnh bạn cần

        // Lưu vào Firestore
        await FirebaseFirestore.instance.collection('images').add({
          'imageURL': imageUrl,
          'description': description,
          'uploadedBy': uploadedBy,
          'familyCode': familyCode,
          'time': Timestamp.now(),
        });
      } else {
        throw Exception('Cloudinary upload failed. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

}

