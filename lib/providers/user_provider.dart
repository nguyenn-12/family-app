import 'package:flutter/material.dart';
import 'package:family/models/users.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  final _storage = const FlutterSecureStorage();

  void setUser(UserModel? user) {
    _user = user;

    if (user != null) {
      _storage.write(key: 'current_user', value: jsonEncode(user.toJson()));
    } else {
      _storage.delete(key: 'current_user');
    }

    notifyListeners();
  }

  void clearUser() {
    _user = null;
    _storage.delete(key: 'current_user');
    notifyListeners();
  }

  Future<void> loadUserFromStorage() async {
    final jsonStr = await _storage.read(key: 'current_user');
    if (jsonStr != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(jsonStr));
        notifyListeners();
      } catch (e) {
        // Nếu lỗi parse, reset luôn
        await _storage.delete(key: 'current_user');
        _user = null;
      }
    }
  }
}
