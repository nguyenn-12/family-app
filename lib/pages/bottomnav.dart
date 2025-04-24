import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,
      backgroundColor:Color(0xFFF9F8FD),
      color: Color(0xFFA87CEC),
      buttonBackgroundColor: Color(0xFFECB22F),
      animationDuration: Duration(milliseconds: 300),
      onTap: onTap,
      height: 65, // Chiều cao của thanh nav
      animationCurve: Curves.linear,
      items: const [
        Icon(Icons.date_range_outlined, size: 30, color: Colors.white), // Lịch
        Icon(Icons.collections_outlined, size: 30, color: Colors.white),  // Ảnh
        Icon(Icons.forum_outlined, size: 30, color: Colors.white),           // Chat
        Icon(Icons.account_circle, size: 30, color: Colors.white),         // Hồ sơ
      ],
    );
  }
}
