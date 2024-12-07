import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Map<DateTime, List<Map<String, String>>> events = {
    DateTime.utc(2024, 12, 8): [
      {'title': 'Public Holiday', 'type': 'public'},
      {'title': 'Hackathon Kickoff', 'type': 'hackathon'},
    ],
    DateTime.utc(2024, 12, 10): [
      {'title': 'Midterm Exam', 'type': 'exam'},
      {'title': 'Team Meeting', 'type': 'public'},
    ],
    DateTime.utc(2024, 12, 12): [
      {'title': 'Finals Preparation', 'type': 'exam'},
    ],
    DateTime.utc(2024, 12, 15): [
      {'title': 'Coding Bootcamp', 'type': 'hackathon'},
    ],
  };
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Calendar"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: selectedDate,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            eventLoader: (date) => events[date]?.map((e) => e['title'] ?? '').toList() ?? [],
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                selectedDate = selectedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              outsideDaysVisible: false,
            ),
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, eventsForDay) {
                if (eventsForDay.isEmpty) return null;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: events[date]!
                      .take(3) // Show max 3 markers per day
                      .map((event) {
                    Color color = Colors.grey;
                    switch (event['type']) {
                      case 'public':
                        color = Colors.green;
                        break;
                      case 'hackathon':
                        color = Colors.orange;
                        break;
                      case 'exam':
                        color = Colors.yellow;
                        break;
                      case 'personal':
                        color = Colors.blue;
                        break;
                    }
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                if (events[selectedDate] != null)
                  for (var event in events[selectedDate]!)
                    ListTile(
                      title: Text(event['title']!),
                      subtitle: Text(event['type']!.toUpperCase()),
                    )
                else
                  const Center(child: Text("No events for this day")),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addEventDialog(BuildContext context) {
    TextEditingController eventController = TextEditingController();
    String eventType = 'public'; // Default event type

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Event"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: eventController,
              decoration: const InputDecoration(hintText: "Enter event title"),
            ),
            DropdownButton<String>(
              value: eventType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    eventType = value;
                  });
                }
              },
              items: const [
                DropdownMenuItem(value: 'public', child: Text("Public Event")),
                DropdownMenuItem(value: 'hackathon', child: Text("Hackathon")),
                DropdownMenuItem(value: 'exam', child: Text("Exam Date")),
                DropdownMenuItem(value: 'personal', child: Text("Personal Event")),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (eventController.text.isNotEmpty) {
                setState(() {
                  if (events[selectedDate] == null) {
                    events[selectedDate] = [];
                  }
                  events[selectedDate]!.add({
                    'title': eventController.text,
                    'type': eventType,
                  });
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

