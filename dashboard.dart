import 'package:flutter/material.dart';
import 'package:onestop/calendar.dart';
import 'package:onestop/examschedules.dart';
import 'package:onestop/login.dart';
import 'mongodbmodel.dart';

class Dashboard extends StatefulWidget {
  final MongoDbModel user;
  const Dashboard({super.key,required this.user});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        backgroundColor: Colors.blue,
        elevation: 3,
        centerTitle: true,
        actions: [
          Row(
            children: [
              const Icon(Icons.currency_exchange),
              const SizedBox(width: 4),
              Text(
                '${widget.user.credit}',
                style: const TextStyle(fontSize: 18),
              ),
              ElevatedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
              }, child: Icon(Icons.logout),
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent),
              elevation: MaterialStateProperty.all(0),
              )),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Card(
              elevation: 5,
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Hello, ${widget.user.name}!!",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CalendarPage(user: widget.user,)));
            }, child: const Text("Click")),
            Card(
              elevation: 3,
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SchedulePage()));
                }, child: Text("data")),
              ),
            )
          ],
        ),
      ),
    );
  }
}
