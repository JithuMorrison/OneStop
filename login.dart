import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:onestop/dashboard.dart';
import 'package:onestop/register.dart';

import 'mongodb.dart';
import 'mongodbmodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final username = _usernameController.text;

                // Check if username exists
                final user = await MongoDatabase.userCollection
                    .findOne(mongo.where.eq('username', username));
                if (user != null) {
                  print('User found: ${user['username']}');
                  final userData = MongoDbModel.fromJson(user);
                  // Do something with userData, e.g., navigate to dashboard
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard(user: userData,)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid username!')),
                  );
                }
              },
              child: Text('Login'),
            ),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterPage()));
            }, child: Text('Register'))
          ],
        ),
      ),
    );
  }
}
