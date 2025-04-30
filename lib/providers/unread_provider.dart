// 📄 File: providers/unread_provider.dart
import 'package:flutter/material.dart';

class UnreadProvider extends ChangeNotifier {
  int _unread = 0;

  int get unread => _unread;

  void setUnread(int value) {
    _unread = value;
    notifyListeners();
  }
}