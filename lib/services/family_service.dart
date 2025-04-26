import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/families.dart';

class FamilyService {
  static final _familyRef = FirebaseFirestore.instance.collection('families');

  // TODO: create new family with creatorUid
  static Future<String> createFamily(String creatorUid) async {
    final newDoc = _familyRef.doc();
    final familyId = newDoc.id; // use auto-generated ID as familyCode
    final family = FamilyModel(
      id: familyId,
      createdBy: creatorUid,
      numMember: 1,
      dateCreate: DateTime.now(),
    );

    await newDoc.set(family.toMap());
    return familyId;
  }

  // TODO: get family by id
  static Future<FamilyModel?> getFamilyById(String familyId) async {
    final doc = await _familyRef.doc(familyId).get();
    if (!doc.exists) return null;
    return FamilyModel.fromMap(doc.data()!);
  }

  // TODO: update member count
  static Future<void> updateMemberCount(String familyId, int delta) async {
    final docRef = _familyRef.doc(familyId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        debugPrint("⚠️ Document $familyId does not exist. Skipping update.");
        return;
      }

      final currentCount = snapshot['numMember'] ?? 0;
      final newCount = currentCount + delta;

      // Nếu số lượng còn lại <= 0 thì không update nữa
      if (newCount <= 0) {
        debugPrint("⚠️ Member count is $newCount. Skipping update to avoid recreating deleted document.");
        return;
      }

      transaction.update(docRef, {'numMember': newCount});
    });
  }


  // TODO: fetch members according to familyCode
  static Future<List<Map<String, dynamic>>> fetchFamilyMembers(String familyCode) async {
    final users = await FirebaseFirestore.instance
        .collection('users')
        .where('familyCode', isEqualTo: familyCode)
        .get();

    return users.docs.map((doc) => doc.data()).toList();
  }

  // TODO: Cập nhật người tạo (createdBy) của family
  static Future<void> updateCreatedBy(String familyId, String newCreatorId) async {
    await _familyRef.doc(familyId).update({
      'createdBy': newCreatorId,
    });
  }

  // TODO: Xoá toàn bộ family
  static Future<void> deleteFamily(String familyId) async {
    await _familyRef.doc(familyId).delete();
  }
}