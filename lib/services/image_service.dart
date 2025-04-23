import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family/models/images.dart';

class ImageService {
  static Future<List<ImageModel>> fetchImagesByFamilyCode(String familyCode) async {

    final snapshot = await FirebaseFirestore.instance
        .collection('images') // Sửa tên nếu cần
        .where('familyCode', isEqualTo: familyCode)
        .orderBy('time', descending: true)
        .get();

    final images = snapshot.docs.map((doc) {
      final image = ImageModel.fromMap(doc.id, doc.data());
      return image;
    }).toList();

    return images;
  }
}

