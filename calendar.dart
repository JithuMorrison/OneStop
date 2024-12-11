import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'calendareventsmodel.dart' as cal;
import 'mongodb.dart';
import 'mongodbmodel.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

class CalendarPage extends StatefulWidget {
  final MongoDbModel user;
  const CalendarPage({super.key,required this.user});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Map<DateTime, List<Map<String, String>>> events = {};
  DateTime selectedDate = DateTime.now();

  var eventdb;

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

  Future<Map<DateTime, List<Map<String, String>>>> eventMapping() async {
    try {
      final events = await eventdb.find().toList();
      Map<DateTime, List<Map<String, String>>> eventMap = {};

      for (var event in events) {
        final calendarEvent = cal.CalendarEventModel.fromJson(event);
        for (var eventDetail in calendarEvent.events) {
          final eventDate = DateTime.utc(
            DateTime.parse(eventDetail.date).year,
            DateTime.parse(eventDetail.date).month,
            DateTime.parse(eventDetail.date).day,
          );

          // Add the event details to the map
          if (eventMap.containsKey(eventDate)) {
            eventMap[eventDate]?.addAll(eventDetail.details.map((detail) => {
              'title': detail.title,
              'type': calendarEvent.type,
            }).toList());
          } else {
            eventMap[eventDate] = eventDetail.details.map((detail) => {
              'title': detail.title,
              'type': calendarEvent.type,
            }).toList();
          }
        }
      }
      // Return the populated map
      return eventMap;
    } catch (e) {
      print("Error during event mapping: $e");
      return {};
    }
  }

  Future<void> updateEvents() async {
    try {
      Map<DateTime, List<Map<String, String>>> mappedEvents = await eventMapping();
      setState(() {
        mappedEvents.forEach((date, eventDetails) {
          if (events.containsKey(date)) {
            events[date]?.addAll(eventDetails);
          } else {
            events[date] = eventDetails;
          }
        });
      });
      //print("Events updated successfully");
      //print(events);
    } catch (e) {
      print("Error updating events: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    eventdb = MongoDatabase.calendarevent;
    events = convertEventsToMap(widget.user.events);
    updateEvents();
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
                if(eventType=="personal"){
                  MongoDbModel user = widget.user;
                  user.events.clear();
                  events.forEach((date, eventList) {
                    if (eventList.any((event) => event['type'] == 'personal')) {
                    user.events.add(Event(
                      date: date,
                      details: eventList
                          .where((event) => event['type'] == 'personal') // Filter for 'personal' type
                          .map((event) => Detail(
                        title: event['title'] ?? '',
                        type: event['type'] ?? '',
                      ))
                          .toList(),
                    ));
                    }
                  });
                  String result = await MongoDatabase.update(user);
                }
                else{
                  final result = await eventdb.find(mongo.where.eq('type', eventType)).toList();
                  if (result.isNotEmpty) {
                    // If event exists, create CalendarEventModel from fetched data
                    var calendarEvent = cal.CalendarEventModel.fromJson(result[0]);
                    // Create new event and add to the events list of the calendar event
                    var newEvent = cal.Event(
                      date: selectedDate.toString(),
                      details: [
                        cal.Detail(
                          title: eventController.text,
                        ),
                      ],
                    );
                    calendarEvent.events.add(newEvent);
                    String updateResult = await MongoDatabase.updateCalendarEvent(calendarEvent);
                  } else {
                    print("No event found with the given type: $eventType");
                  }
                }
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

