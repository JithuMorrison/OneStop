import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:onestop/mongodb.dart';

import 'announcementmodel.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  List<dynamic> announcements = [];

  // Assume collection has been initialized and connected elsewhere

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  // Fetch announcements from the database
  void _fetchAnnouncements() async {
    var result = await MongoDatabase.announcements.find().toList(); // MongoDB collection is available here
    setState(() {
      announcements = result
          .map((json) => AnnouncementModel.fromJson(json))
          .toList();
    });
  }

  // Add announcement to the database
  void _addAnnouncement(String title, String desc, DateTime date, String time) async {
    final newAnnouncement = AnnouncementModel(
      id: mongo.ObjectId(),
      title: title,
      desc: desc,
      date: date,
      time: time,
    );
    await MongoDatabase.insertannouncement(newAnnouncement);
    _fetchAnnouncements();
  }

  // Show dialog to create new announcement
  void _showAddAnnouncementDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Date (yyyy-mm-dd)'),
              ),
              TextField(
                controller: timeController,
                decoration: InputDecoration(labelText: 'Time (HH:mm)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final desc = descController.text;
                final date = DateTime.parse(dateController.text);
                final time = timeController.text;

                if (title.isNotEmpty && desc.isNotEmpty && dateController.text.isNotEmpty && time.isNotEmpty) {
                  _addAnnouncement(title, desc, date, time);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
        title: Text("Announcements"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddAnnouncementDialog,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];
          return ListTile(
            title: Text(announcement.title),
            subtitle: Text(announcement.desc),
            trailing: Text("${announcement.date.toLocal()} ${announcement.time}"),
          );
        },
      ),
    );
  }
}
