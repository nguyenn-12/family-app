import 'package:family/pages/bottomnav.dart';
import 'package:family/pages/calendar.dart';
import 'package:family/pages/chat.dart';
import 'package:family/pages/gallery.dart';
import 'package:family/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:family/models/users.dart';
import 'package:family/pages/edit_profile.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

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
      ChatPage(
                onGoToProfile: () {
          setState(() {
            _currentIndex = 3; // hoặc tab Profile
          });
        },),
      ProfilePage(),
      EditProfilePage()
    ];
  }

  final List<String> _titles = [
    'Calendar ',
    'Gallery',
    'Chatting Room',
    'Profile',
    'Edit Profile'
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _currentIndex == 3
          ? null
          : PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          centerTitle: true,
          title: Text(
            _titles[_currentIndex],
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          //backgroundColor: const Color(0xFFA580D8),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00C6A2),
                  Color(0xFF007B8F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
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