import 'package:flutter/material.dart';
import 'package:onestop/dbhelper.dart';
import 'package:onestop/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'mongodb.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect();
  await Supabase.initialize(
    url: SUPABASEURL,
    anonKey: SUPABASEKEY,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneStop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
