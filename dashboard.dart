import 'package:flutter/material.dart';
import 'package:onestop/calendar.dart';
import 'package:onestop/examschedules.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currencyCount = 100;
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
                '$currencyCount',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 16), // Space between icon and edge
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
            const Card(
              elevation: 5,
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Hello",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>CalendarPage()));
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
