import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:family/models/events.dart';
import 'package:family/services/event_service.dart';
import 'package:family/providers/user_provider.dart';
import 'package:family/models/notifications.dart';
import 'package:family/services/notification_service.dart';

class CalendarPage extends StatefulWidget {
  //final UserModel user;
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _firestoreEvents = {};
  //late UserModel currentUser;
  late final currentUser;

  List<Event> _getEventsForDay(DateTime day) {
    return _firestoreEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<UserProvider>(context, listen: false);
      currentUser = provider.user;
      _loadEventsFromFirestore();
      setState(() {});
    });

  }

  Future<void> _loadEventsFromFirestore() async {

    final familyCode = currentUser.familyCode;
    if (familyCode == null) {
      print('No familyCode found for current user');
      return;
    }
    final events = await EventService.loadEvents(familyCode);

    //final events = await EventService.loadEvents('12345'); // hoặc familyCode nếu có biến
    Map<DateTime, List<Event>> tempEvents = {};

    for (var event in events) {
      DateTime key = DateTime(event.day.year, event.day.month, event.day.day);
      tempEvents.putIfAbsent(key, () => []).add(event);
    }

    setState(() {
      _firestoreEvents = tempEvents;
    });
  }

  static Future<void> sendBirthdayNotification(Event event) async {

    try {
      // Lấy thông tin về gia đình từ event
      final familyCode = event.familyCode;
      final ownerEmail = event.owner ?? ''; // Email của người chủ sinh nhật
      final title = event.title; // Tiêu đề của sự kiện, có thể là tên của người chủ sinh nhật

      // Lấy danh sách các người dùng có familyCode giống với currentUser
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final snapshot = await usersCollection.where('familyCode', isEqualTo: familyCode).get();

      // Duyệt qua từng user và tạo thông báo
      for (var doc in snapshot.docs) {
        final user = doc.data();
        final receiverEmail = user['email'];

        // Tạo thông báo
        final notification = NotificationModel(
          id: '',
          receiver: receiverEmail, // Người nhận là email của người dùng
          sender: ownerEmail, // Người gửi là chủ sinh nhật
          content: '$title! 🎉', // Nội dung thông báo
          type: 'Birthday', // Loại thông báo
          status: 0, // 0: chưa xem, 1: đã xem
          time: DateTime.now(), // Thời gian thông báo
        );

        // Gọi hàm addNotification để lưu thông báo vào Firestore
        await NotificationService.addNotification(notification);
      }
    } catch (e) {
      print('Error sending birthday notification: $e');
    }
  }


  void _showEventDialog({DateTime? selectedDate, Map<String, dynamic>? event}) {
    final TextEditingController titleController =
    TextEditingController(text: event?['title'] ?? '');
    final TextEditingController locationController =
    TextEditingController(text: event?['location'] ?? '');
    TimeOfDay selectedTime = event?['time'] != null
        ? TimeOfDay(
            hour: int.parse(event!['time'].split(':')[0]),
            minute: int.parse(event['time'].split(':')[1]),
        ) : TimeOfDay.now();
    final bool isBirthday = event?['isBirthday'] ?? false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFE), // màu nền dialog
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Stack(
                      children: [
                        Center(
                          child: Text(
                            event == null ? 'Add Event' : 'Edit Event',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF331A3F),
                            ),

                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '📅 Date: ${selectedDate?.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Time Picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🕒 Time: ${selectedTime.format(context)}',
                          style: TextStyle(fontSize: 18),
                        ),
                        TextButton(
                          child: Text('Choose Time'),
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title input
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(fontSize: 18),
                      ),
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),

                    // Location input
                    TextField(
                      controller: locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        labelStyle: TextStyle(fontSize: 18),
                      ),
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (event != null)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF33A5C),
                              padding: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            icon: Icon(Icons.delete, color: Colors.white, size: 20),
                            label: Text('Delete', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                            onPressed: (isBirthday)
                                ? null : () async {
                                await EventService.deleteEvent(event['id']);

                                final senderEmail = currentUser.email;

                                // Fetch family members từ collection users
                                final membersSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .where('familyCode',
                                    isEqualTo: currentUser.familyCode)
                                    .get();

                                // Add notification for each member
                                for (var doc in membersSnapshot.docs) {
                                  final receiverEmail = doc['email'];

                                  if (receiverEmail == senderEmail) {
                                    continue; // không gửi thông báo cho chính mình
                                  }

                                  final notification = NotificationModel(
                                    id: '',
                                    receiver: receiverEmail,
                                    sender: senderEmail,
                                    content: '${currentUser
                                        .name} deleted an event on ${selectedDate
                                        ?.toLocal().toString().split(' ')[0]}',
                                    type: 'Event',
                                    status: 0,
                                    time: DateTime.now(),
                                  );

                                  await NotificationService.addNotification(
                                      notification);
                                }
                                Navigator.pop(context);
                                _loadEventsFromFirestore();
                            },
                          ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF329B80),
                            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: Icon(event == null ? Icons.add : Icons.update, color: Colors.white, size: 20),
                          label: Text(
                            event == null ? 'Add event' : 'Update',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          onPressed: () async {
                            final title = titleController.text.trim();
                            final location = locationController.text.trim();
                            final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                            if (event == null) {
                              final familyCode = currentUser.familyCode;
                              if (familyCode == "") {
                                print("No family code, can't add event.");
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Text(
                                        "You must join a family to add an event.",
                                        textAlign: TextAlign.center,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      actions: [
                                        Center(
                                          child: TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text("OK"),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              }
                              // Add new
                              await EventService.addEvent(
                                day: selectedDate!,
                                time: formattedTime,
                                title: title,
                                location: location,
                                familyCode: familyCode,
                                //familyCode: '12345',
                              );

                              final senderEmail = currentUser.email;

                              // Fetch family members từ collection users
                              final membersSnapshot = await FirebaseFirestore.instance
                                  .collection('users')
                                  .where('familyCode', isEqualTo: familyCode)
                                  .get();

                              // Add notification for each member
                              for (var doc in membersSnapshot.docs) {
                                final receiverEmail = doc['email'];

                                  if (receiverEmail == senderEmail) {
                                    continue; // không gửi thông báo cho chính mình
                                  }

                                final notification = NotificationModel(
                                  id: '',
                                  receiver: receiverEmail,
                                  sender: senderEmail,
                                  content: '${currentUser.name} added an event on ${selectedDate?.toLocal().toString().split(' ')[0]}\n Check Calendar for details ! ',
                                  type: 'Event',
                                  status: 0,
                                  time: DateTime.now(),
                                );

                                await NotificationService.addNotification(notification);

                              }

                            } else {
                              // Update
                              await EventService.updateEvent(
                                eventId: event['id'],
                                time: formattedTime,
                                title: title,
                                location: location,
                              );

                              final senderEmail = currentUser.email;

                              // Fetch family members từ collection users
                              final membersSnapshot = await FirebaseFirestore.instance
                                  .collection('users')
                                  .where('familyCode', isEqualTo: currentUser.familyCode)
                                  .get();

                              // Add notification for each member
                              for (var doc in membersSnapshot.docs) {
                                final receiverEmail = doc['email'];

                                if (receiverEmail == senderEmail) {
                                  continue; // không gửi thông báo cho chính mình
                                }
                                final notification = NotificationModel(
                                  id: '',
                                  receiver: receiverEmail,
                                  sender: senderEmail,
                                  content: '${currentUser.name} updated an event on ${selectedDate?.toLocal().toString().split(' ')[0]}\n Check Calendar for details ! ',
                                  type: 'Event',
                                  status: 0,
                                  time: DateTime.now(),
                                );

                                await NotificationService.addNotification(notification);
                              }

                            }

                            Navigator.pop(context);
                            _loadEventsFromFirestore(); // Refresh
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
        );
    },
    );

  }


  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_selectedDay ?? _focusedDay);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Calendar (nửa trên màn hình)
            Container(
              // height: screenHeight * 0.45,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFD),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,
                eventLoader: (day) => _getEventsForDay(day),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF331A3F),
                  ),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  weekendTextStyle: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                  todayTextStyle: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  selectedTextStyle: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFFF3DEAD),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFF329B80),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          margin: EdgeInsets.only(top: 4, right: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Color(0xFFF14C6A), // màu của dấu chấm
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return SizedBox();
                  },
                ),
              ),

            ),

            // Danh sách sự kiện (nửa dưới)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: events.isEmpty
                      ? Center(
                      child: Text(
                       'No event on this day',
                       style: TextStyle(
                         fontSize: 18,
                         color: Colors.grey[600],
                       ),
                     ),
                   ) : _buildEventList(events),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: _selectedDay != null
           ? FloatingActionButton(
        onPressed: () {
          // TODO: mở form tạo sự kiện
          print('Tạo sự kiện cho ngày $_selectedDay');
          _showEventDialog(selectedDate: _selectedDay);
        },
        backgroundColor: Color(0xFF329B80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // độ cong góc
        ),
        child: Icon(Icons.add, color: Colors.white, size: 40),
        )
          : null,

    );
  }

  Widget _buildEventList(List<Event> events) {
    final grouped = groupEventsByTimeSlot(events);

    return ListView(
      children: grouped.entries.map((entry) {
        final slot = entry.key;
        final slotEvents = entry.value;
        final iconColor = _getIconColor(slot);
        final icon = _getIconForSlot(slot);
        final backgroundColor = _getBackgroudColor(slot);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  slot,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...slotEvents.map((event) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              color: backgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
              elevation: 3,
              child: ListTile(
                title: Text(event.title, style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF050505),
                  fontWeight: FontWeight.w500,
                ),
                ),
                subtitle: Text('🕒 ${event.time} 📍 ${event.location}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF131515),

                  ),
                ),
                trailing: (event.isBirthday ?? false)
                    ? IconButton(
                  icon: Icon(Icons.notifications_active),
                  onPressed: () {
                    sendBirthdayNotification(event);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text(
                            "Successfully remind your family about birthday.",
                            textAlign: TextAlign.center,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          actions: [
                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text("OK"),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                )
                    : null,
                onTap: () {
                  _showEventDialog(
                    selectedDate: event.day,
                    event: {
                      'id': event.id,
                      'title': event.title,
                      'location': event.location,
                      'time': event.time,
                      'isBirthday': event.isBirthday,
                    },
                  );
                },
              ),
            )),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  Map<String, List<Event>> groupEventsByTimeSlot(List<Event> events) {
    Map<String, List<Event>> grouped = {
      'Birthday': [],
      'Morning': [],
      'Noon': [],
      'Afternoon': [],
      'Evening': [],
    };

    for (var event in events) {
      final hour = int.tryParse(event.time.split(':')[0]) ?? 0;
      bool isBirthday = event.isBirthday ?? false;

      if (isBirthday) {
        grouped['Birthday']!.add(event);
      } else if (hour >= 5 && hour < 11) {
        grouped['Morning']!.add(event);
      } else if (hour >= 11 && hour < 14) {
        grouped['Noon']!.add(event);
      } else if (hour >= 14 && hour < 18) {
        grouped['Afternoon']!.add(event);
      } else {
        grouped['Evening']!.add(event);
      }
    }

    return grouped..removeWhere((key, value) => value.isEmpty);
  }

  IconData _getIconForSlot(String slot) {
    switch (slot) {
      case 'Birthday':
        return Icons.cake;
      case 'Morning':
        return Icons.wb_sunny;
      case 'Noon':
        return Icons.lunch_dining;
      case 'Afternoon':
        return Icons.wb_twilight;
      case 'Evening':
        return Icons.nightlight_round;
      default:
        return Icons.event;
    }
  }

  Color _getIconColor(String slot) {
    switch (slot) {
      case 'Birthday':
        return Color(0xFFEF6393);
      case 'Morning':
        return Color(0xFFF4BC06);
      case 'Noon':
        return Color(0xFFF65423);
      case 'Afternoon':
        return Color(0xFF3B76F6);
      case 'Evening':
        return Color(0xFF7124F4);
      default:
        return Colors.grey;
    }
  }

  Color _getBackgroudColor(String slot) {
    switch (slot) {
      case 'Birthday':
        return Color(0xFFFBCCDC);
      case 'Morning':
        return Color(0xFFF4E5AF);
      case 'Noon':
        return Color(0xFFF6B9A5);
      case 'Afternoon':
        return Color(0xFFB0C8F8);
      case 'Evening':
        return Color(0xFFD6C5F6);
      default:
        return Colors.grey;
    }
  }

}
