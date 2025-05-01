
// 📄 File: main_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family/pages/bottomnav.dart';
import 'package:family/pages/calendar.dart';
import 'package:family/pages/chat.dart';
import 'package:family/pages/gallery.dart';
import 'package:family/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:family/models/users.dart';
import 'package:family/pages/edit_profile.dart';
import 'package:provider/provider.dart';
import 'package:family/providers/user_provider.dart';
import 'package:family/providers/unread_provider.dart';
import 'package:family/services/listener_service.dart';


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
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user != null && user.familyCode.isNotEmpty) {
      _subscribeUnreadCounter(user);
      setupNotificationListeners(user);
    }

    _pages = [
      CalendarPage(),
      GalleryPage(),
      ChatPage(
        onGoToProfile: () {
          setState(() {
            _currentIndex = 3;
          });
        },
      ),
      ProfilePage(),
      EditProfilePage()
    ];
  }

  void _subscribeUnreadCounter(UserModel user) {
    FirebaseFirestore.instance
        .collection('families')
        .doc(user.familyCode)
        .collection('messages')
        .snapshots()
        .listen((snapshot) {
      final unread = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final List readBy = data['readBy'] ?? [];
        return data['senderId'] != user.id && !readBy.contains(user.id);
      }).length;

      context.read<UnreadProvider>().setUnread(unread);
    });
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
    final unreadCount = context.watch<UnreadProvider>().unread;

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
            style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
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
        unreadCount: unreadCount,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}