import 'package:flutter/material.dart';
import 'package:onestop/studentmodel.dart';
import 'mongodb.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String? selectedDept;
  String? selectedSection;
  String? selectedSubject='se';
  List<Student> students = [];
  List<String> depts = [];
  List<String> sections = [];
  List<String> subject = [];
  Map<String, List<Student>> attendanceRecords = {};

  final TextEditingController deptController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  var dbCollection; // MongoDB collection for storing attendance

  @override
  void initState() {
    super.initState();
    dbCollection = MongoDatabase.attendance; // Example MongoDB setup
    fetchSectionsAndDepartments();
  }

  Future<void> fetchSectionsAndDepartments() async {
    // Fetch available departments and sections from MongoDB
    final data = await dbCollection.find().toList();
    print(data);
    setState(() {
      depts = List<String>.from(Set<String>.from(data.map((e) => e['dept'].toString())));
      sections = List<String>.from(Set<String>.from(data.map((e) => e['section'].toString())));
    });
  }

  Future<void> fetchStudentsForSelectedDeptAndSection() async {
    if (selectedDept != null && selectedSection != null) {
      final data = await dbCollection
          .find({'dept': selectedDept, 'section': selectedSection})
          .toList();
      final studentData = data.isNotEmpty
          ? data[0]['students'] // Assuming 'students' is in the first document
          : [];
      setState(() {
        students = List<Student>.from(
          studentData.map((student) => Student(
            name: student['name'].toString(),
            email: student['email'].toString(),
            attendance: Attendance(
              se: (student['attendance']['se'] ?? [])
                  .map<DateTime>((dateString) => DateTime.parse(dateString))
                  .toList(),
            ),
          )),
        );
      });
    }
  }

  void addOrUpdateStudents() {
    if (deptController.text.isNotEmpty && sectionController.text.isNotEmpty) {
      String dept = deptController.text;
      String section = sectionController.text;

      setState(() {
        selectedDept = dept;
        selectedSection = section;

        // Update department and section lists
        if (!depts.contains(dept)) depts.add(dept);
        if (!sections.contains(section)) sections.add(section);

        // Add or update students in the map
        String key = "$dept-$section";
        if (!attendanceRecords.containsKey(key)) {
          attendanceRecords[key] = [];
        }
        attendanceRecords[key]!.addAll(students);
        print(attendanceRecords);
        // Clear input fields
        students = [];
      });

      // Save to MongoDB
      dbCollection.update(
        {"dept": dept, "section": section},
        {
          "dept": dept,
          "section": section,
          "students": attendanceRecords["$dept-$section"]!
              .map((e) => e.toJson())
              .toList()
        },
        upsert: true,
      );
    }
  }

  void takeAttendance(String dept, String section) {
    DateTime today = DateTime.now();
    DateTime normalizedToday = DateTime(today.year, today.month, today.day);

    print("Updated Students List:");
    for (var student in students) {
      print({
        "name": student.name,
        "email": student.email,
        "attendance": {
          "se": student.attendance.se.map((date) => date.toIso8601String()).toList()
        },
      });
    }

    // Save to MongoDB
    dbCollection.update(
      {"dept": dept, "section": section},
      {
        "dept": dept,
        "section": section,
        "students": students.map((student) => student.toJson()).toList(),
      },
      upsert: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Add/Update Students"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: deptController,
                          decoration: const InputDecoration(labelText: "Department"),
                        ),
                        TextField(
                          controller: sectionController,
                          decoration: const InputDecoration(labelText: "Section"),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(students[index].name),
                              subtitle: Text(students[index].email),
                            );
                          },
                        ),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: "Name"),
                        ),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: "Email"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              students.add(Student(
                                name: nameController.text,
                                email: emailController.text,
                                attendance: Attendance(se: []),
                              ));
                              nameController.clear();
                              emailController.clear();
                            });
                          },
                          child: const Text("Add Student"),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          addOrUpdateStudents();
                          Navigator.pop(context);
                        },
                        child: const Text("Save"),
                      )
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            hint: const Text("Select Department"),
            value: selectedDept,
            onChanged: (value) {
              setState(() {
                selectedDept = value;
                selectedSection = null; // Reset section when department changes
                students.clear(); // Clear students when dept changes
              });
              fetchStudentsForSelectedDeptAndSection(); // Fetch students for the selected dept & section
            },
            items: depts.map((dept) {
              return DropdownMenuItem(
                value: dept,
                child: Text(dept),
              );
            }).toList(),
          ),
          DropdownButton<String>(
            hint: const Text("Select Section"),
            value: selectedSection,
            onChanged: (value) {
              setState(() {
                selectedSection = value;
              });
              fetchStudentsForSelectedDeptAndSection(); // Fetch students for the selected dept & section
            },
            items: sections.map((section) {
              return DropdownMenuItem(
                value: section,
                child: Text(section),
              );
            }).toList(),
          ),
          if (selectedDept != null && selectedSection != null && students.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  var student = students[index];
                  return CheckboxListTile(
                    title: Text(student.name),
                    subtitle: Text(student.email),
                    value: student.attendance.se.contains(
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                    ),
                    onChanged: (value) {
                      setState(() {
                        DateTime today = DateTime.now();
                        DateTime normalizedToday = DateTime(today.year, today.month, today.day);

                        if (value == true) {
                          if (!student.attendance.se.contains(normalizedToday)) {
                            student.attendance.se.add(normalizedToday);
                          }
                        } else {
                          student.attendance.se.remove(normalizedToday);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ElevatedButton(
            onPressed: () {
              if (selectedDept != null && selectedSection != null) {
                takeAttendance(selectedDept!, selectedSection!);
              }
            },
            child: const Text("Mark Attendance"),
          ),
        ],
      ),
    );
  }
}
