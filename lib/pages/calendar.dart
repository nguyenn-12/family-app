import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:family/models/events.dart';
import 'package:family/services/event_service.dart';
import 'package:family/services/user_service.dart';


class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _firestoreEvents = {};


  List<Event> _getEventsForDay(DateTime day) {
    return _firestoreEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }


  Future<void> _loadEventsFromFirestore() async {

    //final familyCode = await UserService.getFamilyCodeForCurrentUser();
    //if (familyCode == null) {
    //  print('No familyCode found for current user');
    //  return;
    //}
    //final events = await EventService.loadEvents(familyCode);

    final events = await EventService.loadEvents('12345'); // hoặc familyCode nếu có biến
    Map<DateTime, List<Event>> tempEvents = {};

    for (var event in events) {
      DateTime key = DateTime(event.day.year, event.day.month, event.day.day);
      tempEvents.putIfAbsent(key, () => []).add(event);
    }

    setState(() {
      _firestoreEvents = tempEvents;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEventsFromFirestore();
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
                            onPressed: () async {
                              await EventService.deleteEvent(event['id']);
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
                            //  final familyCode = await UserService.getFamilyCodeForCurrentUser();
                            //  if (familyCode == null) {
                            //    print("No family code, can't add event.");
                            //    return;
                            //  }
                              // Add new
                              await EventService.addEvent(
                                day: selectedDate!,
                                time: formattedTime,
                                title: title,
                                location: location,
                                //familyCode: familyCode,
                                familyCode: '12345',
                              );

                            } else {
                              // Update
                              await EventService.updateEvent(
                                eventId: event['id'],
                                time: formattedTime,
                                title: title,
                                location: location,
                              );
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
      backgroundColor: Color(0xFFF9F8FD),
      body: SafeArea(
        child: Column(
          children: [
            // Calendar (nửa trên màn hình)
            Container(
              height: screenHeight * 0.45,
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
                    color: Color(0xFFEFCB7B),
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
                )
                    : ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return GestureDetector(
                      onTap: () => _showEventDialog(selectedDate: _selectedDay, event: {
                        'id': event.id,
                        'title': event.title,
                        'location': event.location,
                        'time': event.time,
                      }),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xD0509786),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.event, color: Colors.white, size: 30),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '(${event.time}) ${event.title} - ${event.location} ',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
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
}
