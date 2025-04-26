import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // để lấy email user đăng nhập
import 'package:family/providers/user_provider.dart';
import 'package:provider/provider.dart';


import 'package:family/models/notifications.dart';
import 'package:family/services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<NotificationModel>> _notificationsFuture;
  final NotificationService _notificationService = NotificationService();
  late List<NotificationModel> notifications = [];
  late final currentUser;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UserProvider>(context, listen: false);
    currentUser = provider.user;

    if (currentUser != null) {
      _notificationsFuture = _notificationService.fetchNotificationsByReceiver(currentUser.email!);
    } else {
      _notificationsFuture = Future.value([]);
    }
  }

  void _fetchNotifications() {
    if (currentUser != null) {
      _notificationsFuture = _notificationService.fetchNotificationsByReceiver(currentUser.email!);
    }
  }

  void _handleNotificationTap(NotificationModel notif) async {
    // Cập nhật status thành 1
    if (notif.status == 0) {
      await _notificationService.updateNotificationStatus(notif.id, 1);
      setState(() {
        // Tạo bản sao mới với status được cập nhật
        final updatedNotif = NotificationModel(
          id: notif.id,
          receiver: notif.receiver,
          sender: notif.sender,
          content: notif.content,
          type: notif.type,
          status: 1, // Cập nhật status thành 1
          time: notif.time,
        );

        // Tìm index của thông báo trong danh sách
        final index = notifications.indexOf(notif);
        if (index != -1) {
          // Cập nhật lại thông báo tại vị trí đó trong danh sách
          notifications[index] = updatedNotif;
        }
      });
    }

    // Xử lý dialog
    if (notif.type == 'NewMember' || notif.type == 'Birthday') {
      // Fetch thêm dữ liệu người gửi
      final senderInfo = await _notificationService.fetchUserByEmail(notif.sender);
      _showUserDialog(notif, senderInfo['name'], senderInfo['avatar']);
    } else if (notif.type == 'Event') {
      _showEventDialog(notif);
    }
  }

  void _showUserDialog(NotificationModel notif, String senderName, String senderAvatar) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(senderName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(senderAvatar),
            ),
            SizedBox(height: 16),
            Text(notif.content),
          ],
        ),
        actions: notif.type == 'NewMember'
            ? [
          TextButton(
            onPressed: () {
              // TODO: Xử lý Accept
              Navigator.pop(context);
            },
            child: Text('Accept'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Xử lý Reject
              Navigator.pop(context);
            },
            child: Text('Reject'),
          ),
        ]
            : [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEventDialog(NotificationModel notif) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Event'),
        content: Text(notif.content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          centerTitle: true,
          title: const Text(
            'Notifications',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFFA87CEC),
        ),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('There are no notification'));
          }

          //List<NotificationModel> notifications = snapshot.data!;
          notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Container(
                  decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)), // Viền dưới
              ),
                child: ListTile(
                tileColor: notif.status == 0 ? Colors.purple.shade50 : Colors.white,
                leading: _buildLeadingIcon(notif.type),
                title: Text(_getNotificationMessage(notif.type)),
                subtitle: Text('${_formatTime(notif.time)}'),
                onTap: () => _handleNotificationTap(notif),
                )
              );
            },
          );
        },
      ),
    );
  }

  // Icon tùy theo loại thông báo
  Widget _buildLeadingIcon(String type) {
    switch (type) {
      case 'NewMember':
        return Icon(Icons.person_add, color: Colors.blue, size: 40);
      case 'Birthday':
        return Icon(Icons.cake, color: Colors.pink, size: 40);
      case 'Event':
        return Icon(Icons.event, color: Colors.green, size: 40);
      default:
        return Icon(Icons.notifications, color: Colors.grey, size: 40);
    }
  }

  // Định dạng thời gian
  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')} • ${time.day}/${time.month}/${time.year}';
  }

  String _getNotificationMessage(String type) {
    switch (type) {
      case 'NewMember':
        return 'Someone is asking to JOIN your family';
      case 'Birthday':
        return 'Today is someone\'s BIRTHDAY.';
      case 'Event':
        return 'Someone just added a new EVENT';
      default:
        return 'You have a new notification';
    }
  }

}
