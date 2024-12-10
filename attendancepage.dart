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
  String? selectedSubject;
  List<Student> students = [];
  List<String> depts = [];
  List<String> sections = [];
  List<String> subjects = [];
  Map<String, List<Student>> attendanceRecords = {};
  int selectedSubjectIndex=0;

  final TextEditingController deptController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

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
      Set<String> subjectos = Set<String>();
      setState(() {
          for (var attendance in studentData[0]['attendance']) {
            subjectos.add(attendance[0][0].toString());
          }
          subjects = subjectos.toList();
        students = List<Student>.from(
          studentData.map((student) => Student(
            name: student['name'].toString(),
            email: student['email'].toString(),
            attendance: List<List<List<dynamic>>>.from(
              student['attendance'].map((attendanceItem) {
                var subject = attendanceItem[0][0].toString();
                var dates = List<DateTime>.from(
                    attendanceItem[1].map((date) {
                      if (date is String) {
                        return DateTime.parse(date); // Parse string to DateTime
                      } else if (date is DateTime) {
                        return date; // If already DateTime, keep it as is
                      } else {
                        return DateTime(1970, 1, 1); // Default to a placeholder date if invalid
                      }
                    })
                );
                return [[subject], dates];
              }).toList(),
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
      print(subjects);
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
        for (var student in students) {
          student.attendance = [];
          for (var subject in subjects) {
            if (!student.attendance.any((attendance) => attendance[0][0] == subject)) {
                List<List<dynamic>> attend = [[subject],[]];
                student.attendance.add(attend);
                print(attend);
            }
          }
        }
        attendanceRecords[key]!.addAll(students);
        /*print(students.map((student) {
          return {
            "name": student.name,
            "email": student.email,
            "attendance": student.attendance.map((attendanceRecord) {
              return [
                attendanceRecord[0],
                attendanceRecord[1].map<String>((date) => date.toString()).toList(),
              ];
            }).toList()..sort((a, b) => a[0].toString().compareTo(b[0].toString())),
          };
        }).toList());*/
      });

      // Save to MongoDB
      dbCollection.update(
        {"dept": dept, "section": section},
        {
          "dept": dept,
          "section": section,
          "students": students.map((student) {
          return {
            "name": student.name,
            "email": student.email,
            "attendance": student.attendance.map((attendanceRecord) {
              return [
                attendanceRecord[0],
                attendanceRecord[1].map<String>((date) => date.toString()).toList(),
              ];
            }).toList()..sort((a, b) => a[0].toString().compareTo(b[0].toString())),
          };
        }).toList(),
        },
        upsert: true,
      );
      print("updated");
    }
  }

  void takeAttendance(String dept, String section) {

    print(students.map((student) => student.toJson()).toList());
    for (var student in students) {
      print({
        "name": student.name,
        "email": student.email,
        "attendance": [[[selectedSubject],[student.attendance[0][1].map((date) => date.toString()).toList()]]]
      });
    }
    print(selectedSubject);
    print(students[0].attendance[0][0][0]);

    // Save to MongoDB
    dbCollection.update(
      {"dept": dept, "section": section},
      {
        "dept": dept,
        "section": section,
        "students": students.map((student) {
          return {
            "name": student.name,
            "email": student.email,
            "attendance": student.attendance.map((attendanceRecord) {
              return [
                attendanceRecord[0],
                attendanceRecord[1].map<String>((date) => date.toString()).toList(),
              ];
            }).toList(),
          };
        }).toList(),
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
                    content: SingleChildScrollView(
                      child: Column(
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
                          DropdownButton<String>(
                            hint: const Text("Select Subject"),
                            value: selectedSubject,
                            onChanged: (value) {
                              setState(() {
                                selectedSubject = value;
                              });
                            },
                            items: subjects.map((subject) {
                              return DropdownMenuItem(
                                value: subject,
                                child: Text(subject),
                              );
                            }).toList(),
                          ),
                          TextField(
                            controller: subjectController,
                            decoration: const InputDecoration(labelText: "Add New Subject"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (subjectController.text.isNotEmpty &&
                                    !subjects.contains(subjectController.text)) {
                                  subjects.add(subjectController.text);
                                  selectedSubject = subjectController.text;
                                  subjectController.clear();
                                }
                              });
                            },
                            child: const Text("Add Subject"),
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
                                  attendance: [[[selectedSubject],[]]],
                                ));
                                nameController.clear();
                                emailController.clear();
                              });
                            },
                            child: const Text("Add Student"),
                          ),
                        ],
                      ),
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
          DropdownButton<String>(
            hint: const Text("Select Subject"),
            value: selectedSubject,
            onChanged: (value) {
              setState(() {
                selectedSubject = value;
                selectedSubjectIndex = subjects.indexOf(value!);
                print(selectedSubjectIndex);
              });
            },
            items: subjects.map((subject) {
              return DropdownMenuItem(
                value: subject,
                child: Text(subject),
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
                    value: student.attendance[selectedSubjectIndex][1].contains(
                      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,DateTime.now().hour),
                    ),
                    onChanged: (value) {
                      setState(() {
                        DateTime today = DateTime.now();
                        DateTime normalizedToday = DateTime(today.year, today.month, today.day,today.hour);

                        if (value == true) {
                          // Check if the date is not already in the attendance list
                          if (!student.attendance[selectedSubjectIndex][1].contains(normalizedToday)) {
                            student.attendance[selectedSubjectIndex][1].add(normalizedToday);
                          }
                        } else {
                          student.attendance[selectedSubjectIndex][1].remove(normalizedToday);
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
