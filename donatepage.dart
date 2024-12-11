import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:onestop/announcementpage.dart';
import 'package:onestop/attendancepage.dart';
import 'package:onestop/blogpage.dart';
import 'package:onestop/calendar.dart';
import 'package:onestop/cgpacalculator.dart';
import 'package:onestop/donatepage.dart';
import 'package:onestop/examschedules.dart';
import 'package:onestop/login.dart';
import 'package:onestop/profile.dart';
import 'package:onestop/trackattendance.dart';
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
        actions: [
          Row(
            children: [
              const Icon(Icons.currency_exchange),
              const SizedBox(width: 4),
              Text(
                '${widget.user.credit}',
                style: const TextStyle(fontSize: 18),
              ),
              SizedBox(
                width: 40,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(user: widget.user)));
                }, child: Icon(Icons.supervised_user_circle_outlined),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    )),
              ),
              SizedBox(
                width: 40,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                }, child: Icon(Icons.logout),
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  elevation: MaterialStateProperty.all(0),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                )),
              ),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              Transform.translate(
                offset: Offset(10, 0),
                child: Row(
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
                SizedBox(
                  width: 60,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CalendarPage(user: widget.user,))
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 3,
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      size: 24, // Optional: adjust size if needed
                    ),
                  ),
                ),
                  ],
                ),
              ),
              Transform.translate(
                offset: Offset(40, 0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => BlogPage())
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 3,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 24, // Optional: adjust size if needed
                            ),
                            Text("Blog Page"),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 30,),
                    SizedBox(
                      width: 120,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DonatePage(user: widget.user))
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 3,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.monetization_on_outlined,
                              size: 24, // Optional: adjust size if needed
                            ),
                            Text("Donate"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 3,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SchedulePage()));
                  }, child: Text("data")),
                ),
              ),
              Card(
                elevation: 3,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AnnouncementPage()));
                  }, child: Text("Announcement")),
                ),
              ),
              Card(
                elevation: 3,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>AttendancePage()));
                  }, child: Text("Attendance")),
                ),
              ),
              Card(
                elevation: 3,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>TrackAttendance()));
                  }, child: Text("Track Attendance")),
                ),
              ),
              Card(
                elevation: 3,
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>CGPACalculator()));
                  }, child: Text("Calculate CGPA")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
