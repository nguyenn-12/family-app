import 'package:family/services/event_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // để lấy email user đăng nhập
import 'package:family/providers/user_provider.dart';
import 'package:provider/provider.dart';


import 'package:family/models/notifications.dart';
import 'package:family/services/notification_service.dart';
import 'package:family/services/user_service.dart';
import 'package:family/services/family_service.dart';
import 'package:family/services/event_service.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  //late Future<List<NotificationModel>> _notificationsFuture;
  final NotificationService _notificationService = NotificationService();
  late List<NotificationModel> notifications = [];
  late final currentUser;
  //bool isLoaded = false;


  @override
  void initState() {
    super.initState();
    final provider = Provider.of<UserProvider>(context, listen: false);
    currentUser = provider.user;
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
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8, // to hơn
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, // background trắng
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notif.type == 'NewMember' ? 'Add new member' : 'Happy Birthday',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,

                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(senderAvatar),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    senderName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                '" ${notif.content} "',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (notif.type == 'NewMember') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final senderUser = await UserService.getUserByEmail(notif.sender);

                        if (senderUser != null) {
                          // Bỏ chữ pending_ ra để lấy familyCode thật
                          String pendingCode = senderUser.familyCode;
                          String realFamilyCode = pendingCode.replaceFirst('pending_', '');

                          await UserService.updateFamilyCode(senderUser.id, realFamilyCode);
                          await FamilyService.updateMemberCount(realFamilyCode, 1);

                          // Xóa notification
                          await NotificationService.deleteNotification(notif.id);
                          // setState(() {
                          //   notifications.removeWhere((n) => n.id == notif.id);
                          // });
                          await EventService.addBirthdayEvent(senderUser.email, senderUser.name, realFamilyCode, senderUser.dob);
                        }
                        Navigator.pop(context);


                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF63BC66),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Accept',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        // TODO: Xử lý Reject
                        final senderUser = await UserService.getUserByEmail(notif.sender);

                        if (senderUser != null) {
                          // Xóa familyCode
                          await UserService.updateFamilyCode(senderUser.id, '');

                          // Xóa notification
                          await NotificationService.deleteNotification(notif.id);
                          // setState(() {
                          //   notifications.removeWhere((n) => n.id == notif.id);
                          // });
                        }
                        Navigator.pop(context);

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDA4A4A),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Reject',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)
                      ),
                    ),
                  ],
                )
              ] else ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF019F92),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Close',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  void _showEventDialog(NotificationModel notif) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'New Event',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                ' ${notif.content}',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF019F92),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Close',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          centerTitle: true,
          title: const Text(
            'Notifications',
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          //backgroundColor: const Color(0xFFA87CEC),
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
      backgroundColor: Colors.white,
        body: StreamBuilder<List<NotificationModel>>(
          stream: _notificationService.streamNotificationsByReceiver(currentUser.email!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('There are no notifications'));
            }

            final notifications = snapshot.data!;

            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
                  ),
                  child: ListTile(
                    tileColor: notif.status == 0 ? Colors.purple.shade50 : Colors.white,
                    leading: _buildLeadingIcon(notif.type),
                    title: Text(_getNotificationMessage(notif.type)),
                    subtitle: Text('${_formatTime(notif.time)}'),
                    onTap: () => _handleNotificationTap(notif),
                  ),
                );
              },
            );
          },
        )

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
        return 'Someone reminded about BIRTHDAY event.';
      case 'Event':
        return 'A new update to your SCHEDULE';
      default:
        return 'You have a new notification';
    }
  }

}
