import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'mongodb.dart';
import 'mongodbmodel.dart';

class CalendarPage extends StatefulWidget {
  final MongoDbModel user;
  const CalendarPage({super.key,required this.user});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Map<DateTime, List<Map<String, String>>> events = {};
  DateTime selectedDate = DateTime.now();

  Map<DateTime, List<Map<String, String>>> convertEventsToMap(List<Event> events) {
    Map<DateTime, List<Map<String, String>>> eventMap = {};

    for (var event in events) {
      if (eventMap.containsKey(event.date)) {
        eventMap[DateTime.utc(event.date.year,event.date.month,event.date.day)]?.addAll(event.details.map((detail) => {
          'title': detail.title,
          'type': detail.type,
        }).toList());
      } else {
        eventMap[DateTime.utc(event.date.year,event.date.month,event.date.day)] = event.details.map((detail) => {
          'title': detail.title,
          'type': detail.type,
        }).toList();
      }
    }

    return eventMap;
  }

  @override
  void initState() {
    super.initState();
    events = convertEventsToMap(widget.user.events);
  }

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
            onPressed: () async{
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
              try{
                MongoDbModel user = widget.user;
                user.events.clear();
                events.forEach((date, eventList) {
                  user.events.add(Event(
                    date: date,
                    details: eventList.map((event) => Detail(
                      title: event['title'] ?? '',
                      type: event['type'] ?? '',
                    )).toList(),
                  ));
                });
                String result = await MongoDatabase.update(user);
                print(result);  // Output the result of the update operation

                // Optionally, display a success message to the user
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Event added successfully")));
              }
              catch(e){
                print("Error updating database: $e");
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding event")));
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

