import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Map<String, String>> examSchedule = [];

  // Controllers for exam details input
  TextEditingController subjectController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exam Schedule"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(  // Wrapping the body with SingleChildScrollView to prevent overflow
        child: Column(
          children: [
            // Calendar to select the date for the exam
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TableCalendar(
                focusedDay: selectedDate,
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                },
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Month',
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Exam creation form
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Create Exam Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: subjectController,
                    decoration: const InputDecoration(labelText: "Subject"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (subjectController.text.isNotEmpty) {
                        // Add the schedule to the list with the selected date
                        setState(() {
                          examSchedule.add({
                            'subject': subjectController.text,
                            'date': selectedDate.toIso8601String(),
                          });
                        });
                        // Clear the input fields after adding
                        subjectController.clear();
                      }
                    },
                    child: const Text("Add Exam"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Save timetable button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Implement your save logic here
                  // You can save the examSchedule to a file, database, or server
                  print("Timetable Saved: $examSchedule");
                },
                child: const Text("Save Timetable"),
              ),
            ),

            // Display exam schedule in a table format
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Scheduled Exams", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SingleChildScrollView(  // Adding scrolling for the data table
              scrollDirection: Axis.horizontal,  // Horizontal scroll for the table
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Subject')),
                  DataColumn(label: Text('Date')),
                ],
                rows: examSchedule.map((exam) {
                  return DataRow(cells: [
                    DataCell(Text(exam['subject']!)),
                    DataCell(Text(exam['date']!.split('T')[0])), // Display only the date part
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
