import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family/models/users.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';


class UserService {
  static final _usersRef = FirebaseFirestore.instance.collection('users');

  /// 🔐 Hash mật khẩu bằng SHA-256
  static String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static Future<void> saveUser(UserModel user) async {
    final newDoc = _usersRef.doc();
    final generatedId = newDoc.id;

    // Mã hóa mật khẩu trước khi lưu
    final hashedPassword =  _hashPassword(user.pass);

    await newDoc.set({
      'id': generatedId,
      'email': user.email,
      'name': user.name,
      'dob': user.dob.toIso8601String(),
      'pass': hashedPassword,
      'avatar': user.avatar,
      'familyCode': user.familyCode,
      'gender': user.gender,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  static Future<bool> checkEmailExists(String email) async {
    final query = await _usersRef.where('email', isEqualTo: email).get();
    return query.docs.isNotEmpty;
  }

  static Future<bool> verifyUserLogin(String email, String password) async {
    final hashedPassword = _hashPassword(password);
    final query = await _usersRef.where('email', isEqualTo: email).where('pass', isEqualTo: hashedPassword).get();
    return query.docs.isNotEmpty;
  }

  static Future<UserModel?> fetchUser(String email) async {
    final snapshot = await _usersRef.where('email', isEqualTo: email).limit(1).get();
    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();
    return UserModel(
      id: data['id'],
      email: data['email'],
      name: data['name'],
      dob: DateTime.parse(data['dob']),
      pass: data['pass'],
      avatar: data['avatar'],
      familyCode: data['familyCode'],
      gender: data['gender'],
    );
  }


  static Future<UserModel?> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final snapshot = await _usersRef.where('email', isEqualTo: user.email).limit(1).get();
    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data();
    return UserModel(
      id: data['id'],
      email: data['email'],
      name: data['name'],
      dob: DateTime.parse(data['dob']),
      pass: data['pass'],
      avatar: data['avatar'],
      familyCode: data['familyCode'],
      gender: data['gender'],
    );
  }

  static Future<void> updatePassword(String email, String newPassword) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (query.docs.isEmpty) return;

    final hashed = _hashPassword(newPassword);
    final docId = query.docs.first.id;

    await FirebaseFirestore.instance.collection('users').doc(docId).update({'pass': hashed});

  }

  // TODO: Update toàn bộ thông tin người dùng
  static Future<void> updateUser(UserModel user) async {
    try {
      await _usersRef.doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception("Failed to update user: $e");
    }
  }

  // TODO: Optional: update chỉ một vài trường
  static Future<void> updateField(String userId, Map<String, dynamic> data) async {
    await _usersRef.doc(userId).update(data);
  }

  // TODO: Optional: update familyCode
  static Future<void> updateFamilyCode(String userId, String familyCode) async {
    final query = _usersRef.where('id', isEqualTo: userId);
    final user = await query.get();

    if (user.docs.isNotEmpty) {
      final docId = user.docs.first.id;
      await _usersRef.doc(docId).update({'familyCode': familyCode});
    }
  }

  static Future<String?> getFamilyCodeForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.email).get();
    print(user);
    return doc.data()?['familyCode'];
  }


}
