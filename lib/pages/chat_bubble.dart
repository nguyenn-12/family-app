// 📄 File: chat_bubble.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final bool isMe;
  final String? text;
  final String? imageUrl;
  final String senderName;
  final String? avatarUrl;
  final DateTime? timestamp;

  const ChatBubble({
    Key? key,
    required this.isMe,
    this.text,
    this.imageUrl,
    required this.senderName,
    this.avatarUrl,
    this.timestamp,
  }) : super(key: key);

  String _formatTime(DateTime? ts) {
    if (ts == null) return '';
    final now = DateTime.now();
    final isToday = now.year == ts.year && now.month == ts.month && now.day == ts.day;
    return isToday
        ? DateFormat('HH:mm').format(ts)
        : DateFormat('dd/MM HH:mm').format(ts);
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTime(timestamp);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[400],
                backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(
                  senderName.isNotEmpty ? senderName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                )
                    : null,
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      senderName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.grey[300] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl!,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Text(text ?? '', style: const TextStyle(fontSize: 15)),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    timeStr,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}