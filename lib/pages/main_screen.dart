import 'package:family/pages/bottomnav.dart';
import 'package:family/pages/calendar.dart';
import 'package:family/pages/chat.dart';
import 'package:family/pages/gallery.dart';
import 'package:family/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:family/models/users.dart';


class MainScreen extends StatefulWidget {
  final UserModel user;
  const MainScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 3;


  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      CalendarPage(),
      GalleryPage(),
      ChatPage(),
      ProfilePage(user: widget.user),
    ];
  }

  final List<String> _titles = [
    'Calendar ',
    'Gallery',
    'Chat',
    'Profile',
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          centerTitle: true,
          title: Text(
            _titles[_currentIndex],
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFFA87CEC),
        ),
      ),

      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}