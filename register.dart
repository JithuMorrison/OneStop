import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:onestop/dashboard.dart';

import 'mongodb.dart';
import 'mongodbmodel.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final username = _usernameController.text;
                final name = _nameController.text;
                final email = _emailController.text;
                final phone = _phoneController.text;

                // Check if username already exists
                final existingUser = await MongoDatabase.userCollection
                    .findOne(mongo.where.eq('username', username));
                if (existingUser != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Username already exists!')),
                  );
                  return;
                }

                // Insert the new user data
                final user = MongoDbModel(
                  id: mongo.ObjectId(), // MongoDB will auto-generate the ID
                  username: username,
                  name: name,
                  email: email,
                  phoneNumber: phone,
                  role: 'user', // Default role
                  dob: '',
                  dept: '',
                  section: '',
                  year: '',
                  credit: 1000, // Default credit
                  events: [], // Empty events for now
                );

                final response = await MongoDatabase.insert(user);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response)),
                );
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard(user: user,)));
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
