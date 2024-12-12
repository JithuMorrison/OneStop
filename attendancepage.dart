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
  String? selectedYear;
  String? selectedSubject;
  List<Student> students = [];
  List<String> depts = [];
  List<String> sections = [];
  List<String> years = [];
  List<String> subjects = [];
  int selectedSubjectIndex=0;

  final TextEditingController deptController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  var dbCollection;

  @override
  void initState() {
    super.initState();
    dbCollection = MongoDatabase.attendance;
    fetchSectionsAndDepartments();
  }

  Future<void> fetchSectionsAndDepartments() async {
    final data = await dbCollection.find().toList();
    print(data);
    setState(() {
      depts = List<String>.from(Set<String>.from(data.map((e) => e['dept'].toString())));
      sections = List<String>.from(Set<String>.from(data.map((e) => e['section'].toString())));
      years = List<String>.from(Set<String>.from(data.map((e) => e['year'].toString())));
    });
  }

  Future<void> fetchStudentsForSelectedDeptAndSection() async {
    if (selectedDept != null && selectedSection != null && selectedYear !=null) {
      final data = await dbCollection
          .find({'dept': selectedDept, 'section': selectedSection,'year':selectedYear})
          .toList();
      if(data.toString()!="[]"){
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
                          return DateTime.parse(date);
                        } else if (date is DateTime) {
                          return date;
                        } else {
                          return DateTime(1970, 1, 1);
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
      else{
        print("Not Available");
      }
    }
  }

  void addOrUpdateStudents() {
    if (deptController.text.isNotEmpty && sectionController.text.isNotEmpty) {
      String dept = deptController.text;
      String section = sectionController.text;
      String year = yearController.text;
      print(subjects);
      setState(() {
        selectedDept = dept;
        selectedSection = section;
        if (!depts.contains(dept)) depts.add(dept);
        if (!sections.contains(section)) sections.add(section);
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
      });

      StudentModel stu = StudentModel(section: section, dept: dept, year: year, students: students);
      MongoDatabase.updatestudent(stu);
      print("updated");
    }
  }

  void takeAttendance(String dept, String section, String year) {
    StudentModel stu = StudentModel(section: section, dept: dept, year: year, students: students);
    MongoDatabase.updatestudentfurther(stu);
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
                          TextField(
                            controller: yearController,
                            decoration: const InputDecoration(labelText: "Year"),
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
            hint: const Text("Select Year"),
            value: selectedYear,
            onChanged: (value) {
              setState(() {
                selectedYear = value;
              });
              fetchStudentsForSelectedDeptAndSection(); // Fetch students for the selected dept & section
            },
            items: years.map((year) {
              return DropdownMenuItem(
                value: year,
                child: Text(year),
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
          if (selectedDept != null && selectedSection != null && selectedYear !=null && students.isNotEmpty)
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
                takeAttendance(selectedDept!, selectedSection!,selectedYear!);
              }
            },
            child: const Text("Mark Attendance"),
          ),
        ],
      ),
    );
  }
}
