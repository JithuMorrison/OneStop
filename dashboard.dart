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
import 'package:onestop/materialpage.dart';
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
              const Icon(Icons.currency_exchange,color: Colors.white60,),
              const SizedBox(width: 4),
              Text(
                '${widget.user.credit}',
                style: const TextStyle(fontSize: 18),
              ),
              SizedBox(width: 5,),
              SizedBox(
                width: 40,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(user: widget.user)));
                }, child: SizedBox(width: 30,height: 30,child: Image(image: NetworkImage('https://i1.wp.com/cdn-icons-png.flaticon.com/512/306/306473.png')),),
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0),
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                    )),
              ),
              SizedBox(
                width: 40,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                }, child: Icon(Icons.logout,color: Colors.white,),
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
      body: SingleChildScrollView(
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
                offset: Offset(25, 0),
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
                    SizedBox(width: 7,),
                    SizedBox(
                      width: 50, // Set the desired width
                      height: 50, // Set the desired height
                      child: Image(
                        image: NetworkImage('https://cdn.iconscout.com/icon/free/png-256/grinning-face-smile-emoji-happy-37705.png'),
                      ),
                    ),
                    SizedBox(width: 7,),
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
              Transform.translate(
                offset: Offset(25, 0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 16),
                        child: InkWell( // Makes the Card clickable
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SchedulePage()),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://img.rawpixel.com/s3fs-private/rawpixel_images/website_content/k-26-nat-2846-lyj0758-1-exam_1.jpg?w=1200&h=1200&dpr=1&fit=clip&crop=default&fm=jpg&q=75&vib=3&con=3&usm=15&cs=srgb&bg=F4F4F3&ixlib=js-2.2.1&s=e11492eec5c6a0b6ae68e1a90810d491', // Background image URL
                                  ),
                                  fit: BoxFit.cover, // Adjust image to cover the container
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 210,
                      height: 110,
                      child: Card(
                        elevation: 3,
                        margin: EdgeInsets.all(16),
                        child: InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>AnnouncementPage()));
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.announcement_outlined),
                              SizedBox(width: 5,),
                              Text("Announcement"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: Offset(10, 0),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 170,
                          height: 60,
                          child: Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            child: InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>AttendancePage()));
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.data_saver_on),
                                  SizedBox(width: 5,),
                                  Text("Attendance"),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          height: 90,
                          child: Card(
                            elevation: 3,
                            margin: EdgeInsets.all(16),
                            child: InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>TrackAttendance()));
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.track_changes),
                                  SizedBox(width: 5,),
                                  Text("Track Att"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Transform.translate(
                      offset: Offset(0, -7),
                      child: SizedBox(
                        width: 150,
                        height: 133,
                        child: Card(
                          elevation: 3,
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          child: InkWell( // Makes the Card clickable
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => StudyPage()),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://image.freepik.com/free-vector/flat-university-concept-background_23-2148187599.jpg?w=1060', // Background image URL
                                    ),
                                    fit: BoxFit.cover, // Adjust image to cover the container
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>CGPACalculator()));
                  }, child: Text("Calculate CGPA")),
                ),
              ),
            ],
          ),
        ),
      );

  }
}
