import 'package:flutter/material.dart';
import 'package:onestop/login.dart';
import 'package:onestop/mongodb.dart';
import 'package:onestop/mongodbmodel.dart';

class ProfilePage extends StatefulWidget {
  final MongoDbModel user;
  const ProfilePage({super.key,required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController deptController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  // Show the update dialog box
  void _showUpdateDialog() {
    nameController.text = widget.user.name;
    emailController.text = widget.user.email;
    phoneController.text = widget.user.phoneNumber;
    deptController.text = widget.user.dept;
    sectionController.text = widget.user.section;
    yearController.text = widget.user.year;
    usernameController.text = widget.user.username;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                TextField(
                  controller: deptController,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
                TextField(
                  controller: sectionController,
                  decoration: const InputDecoration(labelText: 'Section'),
                ),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                ),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Update user data
                MongoDbModel updatedUser = MongoDbModel(
                  id: widget.user.id,
                  name: nameController.text,
                  email: emailController.text,
                  phoneNumber: phoneController.text,
                  dept: deptController.text,
                  section: sectionController.text,
                  year: yearController.text,
                  username: usernameController.text,
                  credit: widget.user.credit, // Retaining existing credits
                  role: widget.user.role, // Retaining existing role
                  dob: widget.user.dob, // Retaining existing dob
                  events: widget.user.events, // Retaining existing events
                );
                MongoDatabase.update(updatedUser).then((message) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inserted")));
                });
              },
              child: const Text('Save Changes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without changes
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Show delete confirmation dialog
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Profile'),
          content: const Text('Are you sure you want to delete this profile?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                MongoDatabase.delete(widget.user.id).then((message) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                });
              },
              child: const Text('Delete'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
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
        title: const Text("Profile"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage('https://wallpapercave.com/wp/wp2034447.jpg'), // Add logic to handle the profile picture
              ),
              const SizedBox(height: 16),

              // User Name
              Text(
                widget.user.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // User Credit/Points
              Text(
                'Credits: ${widget.user.credit}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),

              // User Bio (or any other relevant information)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Email :  ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.user.email),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Ph.no :  ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.user.phoneNumber),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Dept :  ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.user.dept),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Sec :  ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.user.section),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Year :  ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.user.year),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Username :  ',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.user.username),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action buttons: Edit Profile and Logout
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _showUpdateDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _showDeleteDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
