import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Đây là Profile Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
