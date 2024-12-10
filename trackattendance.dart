import 'package:flutter/material.dart';

import 'mongodb.dart';

class TrackAttendance extends StatefulWidget {
  const TrackAttendance({super.key});

  @override
  State<TrackAttendance> createState() => _TrackAttendanceState();
}

class _TrackAttendanceState extends State<TrackAttendance> {
  final TextEditingController emailController = TextEditingController();
  List<String> subject = [];
  List<List<DateTime>> attendance = [];

  var dbCollection;

  @override
  void initState() {
    super.initState();
    dbCollection = MongoDatabase.attendance;
  }

  void searchAttendance() async {
    final result = await dbCollection.findOne({
      "students.email": emailController.text
    });

    if (result != null) {
      // Find the specific student in the "students" array
      var student = (result["students"] as List)
          .firstWhere((s) => s["email"] == emailController.text, orElse: () => null);

      if (student != null) {
        setState(() {
          for (var record in student["attendance"]) {
            var subjectAttendance = (record[1] as List)
                .map((x) => DateTime.parse(x));
            String subjectname = record[0][0].toString();
            print(subjectAttendance);
            attendance.add(subjectAttendance.toList());
            print(attendance);
            subject.add(subjectname);
          }
        });
      } else {
        print("Student not found in the list");
      }
    } else {
      print("No record found for the given email");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Attendance by Email"),
      ),
      body: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: "Enter Student Email"),
          ),
          ElevatedButton(
            onPressed: searchAttendance,
            child: Text("Search Attendance"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: attendance.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Column(
                    children: [
                      Text("${subject[index]}"),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: attendance[index].length > 3 ? 150.0 : attendance[index].length * 50.0,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true, // Ensures the ListView takes only the required height
                          physics: attendance[index].length > 3
                              ? ScrollPhysics() // Enables scrolling when the number of items exceeds the limit
                              : NeverScrollableScrollPhysics(), // Disables scrolling for fewer items
                          itemCount: attendance[index].length,
                          itemBuilder: (context, attIndex) {
                            return Center(child: Text("${attendance[index][attIndex]}"));
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
