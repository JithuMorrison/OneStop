import 'package:flutter/material.dart';
import 'package:onestop/mongodb.dart';

class CGPACalculator extends StatefulWidget {
  const CGPACalculator({super.key});

  @override
  State<CGPACalculator> createState() => _CGPACalculatorState();
}

class _CGPACalculatorState extends State<CGPACalculator> {
  final deptController = TextEditingController();
  final semController = TextEditingController();
  final gradeController = TextEditingController();
  final creditController = TextEditingController();
  final subjectController = TextEditingController();

  double cgpa = 0.0;
  List<String> departments = [];
  List<String> semesters = [];
  List<List<dynamic>> subjects = [];
  String? selectedDept;
  String? selectedSem;
  final List<String> gradeOptions = ['O', 'A+', 'A', 'B+', 'B', 'C', 'D', 'F'];
  List<String?> selectedGrades = [];

  var collection;

  @override
  void initState() {
    super.initState();
    collection = MongoDatabase.cgpa;
    _loadDepartmentsAndSemesters();
  }

  Future<void> _loadDepartmentsAndSemesters() async {
    var result = await collection.find().toList();
    Set<String> deptSet = {};
    Set<String> semSet = {};
    for (var doc in result) {
      deptSet.add(doc['dept']);
      semSet.add(doc['sem']);
    }
    setState(() {
      departments = deptSet.toList();
      semesters = semSet.toList();
    });
  }

  void calculateCGPA() {
    double totalCredits = 0;
    double totalGradePoints = 0;
    for (int i = 0; i < subjects.length; i++) {
      double gradePoints = gradeToPoints(selectedGrades[i] ?? 'F');
      int credits = subjects[i][1];
      totalCredits += credits;
      totalGradePoints += gradePoints * credits;
    }
    setState(() {
      cgpa = totalGradePoints / totalCredits;
    });
  }

  double gradeToPoints(String grade) {
    switch (grade) {
      case 'O':
        return 10;
      case 'A+':
        return 9;
      case 'A':
        return 8;
      case 'B+':
        return 7;
      case 'B':
        return 6;
      case 'C':
        return 5;
      case 'D':
        return 4;
      case 'E':
        return 3;
      case 'F':
        return 2;
      default:
        return 0;
    }
  }

  void updateMongoDB() async {
    if (deptController.text.isEmpty || semController.text.isEmpty) {
      return;
    }
    List<dynamic> newSubject = [
      subjectController.text,
      int.tryParse(creditController.text) ?? 0,
    ];
    var updateData = {
      '\$set': {
        'dept': deptController.text,
        'sem': semController.text,
      },
      '\$push': {
        'subjects': newSubject,
      },
    };
    var result = await collection.updateOne(
      {'dept': deptController.text, 'sem': semController.text},
      updateData,
      upsert: true,
    );
    if (result.isAcknowledged) {
      print('Document updated/inserted successfully');
    } else {
      print('Failed to update/insert document');
    }
  }

  void handleSelection(String dept, String sem) async {
    setState(() {
      selectedDept = dept;
      selectedSem = sem;
      subjects = [];
    });
    var result = await collection.findOne({
      'dept': selectedDept,
      'sem': selectedSem,
    });
    if (result != null) {
      setState(() {
        subjects = List<List<dynamic>>.from(result['subjects']);
        selectedGrades = List<String?>.filled(subjects.length, null);
      });
    }
  }

  void openAddSubjectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Subject'),
          content: Column(
            children: [
              TextField(
                controller: deptController,
                decoration: InputDecoration(labelText: 'Department'),
              ),
              TextField(
                controller: semController,
                decoration: InputDecoration(labelText: 'Semester'),
              ),
              TextField(
                controller: subjectController,
                decoration: InputDecoration(labelText: 'Subject Name'),
              ),
              TextField(
                controller: creditController,
                decoration: InputDecoration(labelText: 'Credits'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (deptController.text.isNotEmpty &&
                    semController.text.isNotEmpty &&
                    subjectController.text.isNotEmpty &&
                    creditController.text.isNotEmpty) {
                  setState(() {
                    updateMongoDB();
                  });
                  subjectController.clear();
                  creditController.clear();
                  deptController.clear();
                  semController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CGPA Calculator'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButton<String>(
                hint: Text('Select Department'),
                value: departments.contains(selectedDept) ? selectedDept : null,
                onChanged: (value) {
                  setState(() {
                    selectedDept = value;
                    selectedSem = null; // Reset semester when department changes
                  });
                },
                items: departments
                    .map((dept) => DropdownMenuItem<String>(
                  value: dept,
                  child: Text(dept),
                ))
                    .toList(),
              ),
              DropdownButton<String>(
                hint: Text('Select Semester'),
                value: selectedSem,
                onChanged: (value) {
                  if (value != null) {
                    handleSelection(selectedDept ?? 'CSE', value);
                  }
                },
                items: semesters
                    .map((sem) => DropdownMenuItem<String>(
                  value: sem,
                  child: Text(sem),
                ))
                    .toList(),
              ),

              if (selectedDept != null && selectedSem != null)
                ...subjects.asMap().entries.map((entry) {
                  int index = entry.key;
                  var subject = entry.value;
                  return Column(
                    children: [
                      Text('${subject[0]}'),  // Subject name
                      DropdownButton<String>(
                        hint: Text('Select Grade'),
                        value: selectedGrades[index],  // Get the selected grade for this subject
                        onChanged: (value) {
                          setState(() {
                            selectedGrades[index] = value;  // Set the selected grade for this subject
                          });
                        },
                        items: gradeOptions.map((grade) {
                          return DropdownMenuItem<String>(
                            value: grade,
                            child: Text(grade),
                          );
                        }).toList(),
                      ),
                      Divider(),
                    ],
                  );
                }).toList(),

              ElevatedButton(
                onPressed: calculateCGPA,
                child: Text("Calculate CGPA"),
              ),
              Text("CGPA: $cgpa"),

              // Button to open dialog and add subjects
              IconButton(
                icon: Icon(Icons.add),
                onPressed: openAddSubjectDialog,
              ),

              // Button to update MongoDB with new subjects
              ElevatedButton(
                onPressed: updateMongoDB,
                child: Text("Update Subjects to MongoDB"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
