import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Group.dart';
import 'package:final_project/GroupPage.dart';
import 'package:final_project/globals.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    for (Group g in groups) {
      createGroup(g);
    }
    getSavedEvents();
    super.initState();
  }

  Future<void> getSavedEvents() async {
    CollectionReference schedules =
        FirebaseFirestore.instance.collection("schedules");
    final snapshot = await schedules.get();
    if (snapshot.size > 0) {
      List<QueryDocumentSnapshot<Object?>> data = snapshot.docs;
      data.forEach((element) {
        var event = element.data() as Map;
        Map apps = event["appointments"];

        apps.forEach((key, value) {
          for (var _app in value) {
            var app = _app["appointment"];
            var test = app[2];
            String valueString = test.split('(0x')[1].split(')')[0];
            int value = int.parse(valueString, radix: 16);
            Color color = new Color(value);
            print(app[6]);
            Appointment tmp = Appointment(
                startTime: app[0].toDate(),
                endTime: app[1].toDate(),
                color: color,
                startTimeZone: app[3],
                endTimeZone: app[4],
                notes: app[5],
                isAllDay: app[6],
                subject: app[7],
                resourceIds: app[8],
                recurrenceRule: app[9]);
            var group = indexGroups(key);
            events[group]!.add(tmp);
          }
        });
      });
    } else {
      print('No data available.');
    }
  }

  Future<void> groupPagePush() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupPage(title: "List of groups"),
      ),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> logoutScreenPush() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
          "Welcome to Lake Nixon!",
          style:
              TextStyle(fontFamily: 'Fruit', color: Colors.white, fontSize: 35),
        )),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                // Container(
                //     alignment: Alignment.center,
                //     padding: const EdgeInsets.all(10),
                //     child: const Text(
                //       'Welcome to Lake Nixon!',
                //       style: TextStyle(
                //           //nixonblue
                //           color: Color.fromRGBO(165, 223, 249, 1),
                //           fontFamily: 'Fruit',
                //           fontWeight: FontWeight.w500,
                //           fontSize: 35),
                //     )),
                Container(
                    child: const Image(
                  image: AssetImage('images/lakenixonlogo.png'),
                )),
                Container(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      height: 80,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll<Color>(nixongreen)),
                        child: const Text(
                          'Select Group',
                          style: TextStyle(fontSize: 60, fontFamily: 'Fruit'),
                        ),
                        onPressed: () {
                          groupPagePush();
                        },
                      ),
                    )),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll<Color>(nixonbrown)),
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontFamily: 'Fruit', fontSize: 30),
                    ),
                    onPressed: () {
                      logout();
                      logoutScreenPush();
                    },
                  ),
                ),
              ],
            )));
  }
}
