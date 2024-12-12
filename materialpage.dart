import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final String bucketName = 'jithu';
  List<Map<String, dynamic>> studies = [];

  Future<void> uploadStudy(String title, String description, List<File> files) async {
    try {
      List<String> fileUrls = [];
      for (var file in files) {
        final fileName = file.uri.pathSegments.last;
        final filePath = 'materials/$fileName';
        final uploadResponse = await supabase.storage.from(bucketName).upload(filePath, file);
        final filePublicUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);
        fileUrls.add(filePublicUrl);
      }

      final response = await supabase.from('study').insert({
        'title': title,
        'description': description,
        'files_list': fileUrls,
        'posted_by': 'Admin',
        'likes': 0
      }).execute();

      setState(() {
        studies.add({
          'title': title,
          'description': description,
          'files_list': fileUrls,
          'posted_by': 'Admin',
          'likes': 0
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Study material uploaded successfully!')));
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading study material: $e')));
    }
  }

  Future<void> fetchStudies() async {
    try {
      final response = await supabase.from('study').select('*').execute();
      setState(() {
        studies = List<Map<String, dynamic>>.from(response.data);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching study materials: $e')));
    }
  }

  Future<void> toggleLike(int studyId, int currentLikes) async {
    try {
      final newLikes = currentLikes + 1;
      final response = await supabase.from('study').update({
        'likes': newLikes,
      }).eq('id', studyId).execute();
        setState(() {
          final index = studies.indexWhere((study) => study['id'] == studyId);
          if (index != -1) {
            studies[index]['likes'] = newLikes;
          }
        });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating likes: $e')));
    }
  }

  void openUploadStudyDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    List<File> selectedFiles = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Upload Study Material'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: 'Enter Title'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Enter Description'),
                maxLines: 3,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: true, // Allow multiple files
                    type: FileType.custom,
                    allowedExtensions: ['pdf','docx'],
                  );

                  if (result != null) {
                    setState(() {
                      selectedFiles = result.files.map((e) => File(e.path!)).toList();
                    });
                  }
                },
                child: Text('Add Files'),
              ),
              if (selectedFiles.isNotEmpty) ...[
                SizedBox(height: 8),
                Text('Selected Files:'),
                ...selectedFiles.map((file) => Text(file.uri.pathSegments.last)).toList(),
              ]
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final description = descriptionController.text;

                if (title.isNotEmpty && description.isNotEmpty && selectedFiles.isNotEmpty) {
                  uploadStudy(title, description, selectedFiles);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields and select files')));
                }
              },
              child: Text('Upload'),
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
  void initState() {
    super.initState();
    fetchStudies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Study Materials')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: openUploadStudyDialog,
              child: Text('Upload Study Material'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: studies.length,
                itemBuilder: (context, index) {
                  final study = studies[index];
                  final fileUrls = List<String>.from(study['files_list'] as List);

                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.book),
                      title: Text(study['title']),
                      subtitle: Text(study['description']),
                      trailing: Text('Likes: ${study['likes']}'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(study['title']),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Description: ${study['description']}'),
                                  SizedBox(height: 10),
                                  ...fileUrls.map((fileUrl) => TextButton(
                                    onPressed: () {
                                      launch(fileUrl);
                                    },
                                    child:Text('Open ${Uri.parse(fileUrl).pathSegments.last}'),
                                  )),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
