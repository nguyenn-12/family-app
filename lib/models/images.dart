import 'package:cloud_firestore/cloud_firestore.dart';

class ImageModel {
  final String id;
  final String imageURL;
  final String description;
  final DateTime time;
  final String uploadedBy;
  final String familyCode;

  ImageModel({
    required this.id,
    required this.imageURL,
    required this.description,
    required this.time,
    required this.uploadedBy,
    required this.familyCode,
  });

  factory ImageModel.fromMap(String id, Map<String, dynamic> data) {
    return ImageModel(
      id: id,
      imageURL: data['imageURL'],
      description: data['description'],
      time: (data['time'] as Timestamp).toDate(),
      uploadedBy: data['uploadedBy'],
      familyCode: data['familyCode'],
    );
  }
}
