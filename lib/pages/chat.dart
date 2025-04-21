import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Đây là Chat Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
