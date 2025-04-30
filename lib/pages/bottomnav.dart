// import 'package:flutter/material.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
//
// class BottomNav extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//
//   const BottomNav({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return CurvedNavigationBar(
//       index: currentIndex,
//       backgroundColor:Color(0xFFF9F8FD),
//       //color: Color(0xFFA57BE4),
//       color: Color(0xFF019F92),
//       //Color(0xFF007B8F),
//       buttonBackgroundColor: Color(0xFFECB22F),
//       animationDuration: Duration(milliseconds: 300),
//       onTap: onTap,
//       height: 65, // Chiều cao của thanh nav
//       animationCurve: Curves.linear,
//       items: const [
//         Icon(Icons.date_range_outlined, size: 30, color: Colors.white), // Lịch
//         Icon(Icons.collections_outlined, size: 30, color: Colors.white),  // Ảnh
//         Icon(Icons.forum_outlined, size: 30, color: Colors.white),           // Chat
//         Icon(Icons.account_circle, size: 30, color: Colors.white),         // Hồ sơ
//       ],
//     );
//   }
// }


// 📄 File: bottomnav.dart
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int unreadCount;

  const BottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,
      backgroundColor: const Color(0xFFF9F8FD),
      color: const Color(0xFF019F92),
      buttonBackgroundColor: const Color(0xFFECB22F),
      animationDuration: const Duration(milliseconds: 300),
      height: 65,
      animationCurve: Curves.linear,
      onTap: onTap,
      items: [
        const Icon(Icons.date_range_outlined, size: 30, color: Colors.white),
        const Icon(Icons.collections_outlined, size: 30, color: Colors.white),
        Stack(
          children: [
            const Icon(Icons.forum_outlined, size: 30, color: Colors.white),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        const Icon(Icons.account_circle, size: 30, color: Colors.white),
      ],
    );
  }
}
