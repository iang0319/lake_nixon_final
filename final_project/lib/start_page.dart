import 'package:final_project/Group.dart';
import 'package:final_project/GroupPage.dart';
import 'package:final_project/calender_page.dart';
import 'package:final_project/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  Future<void> groupPagePush() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GroupPage(title: "List of groups"),
      ),
    );
  }

  Future<void> masterCalendar(Group group) async {
    //print("Chat");
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarPage(title: group.name, group: group),
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
        appBar: AppBar(title: const Text("Action Page")),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Lake Nixon',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(fontSize: 20),
                    )),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    child: const Text("Groups"),
                    onPressed: () {
                      groupPagePush();
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    child: const Text("Master Calendar"),
                    onPressed: () {
                      masterCalendar(const Group(name: "Master"));
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    child: const Text("Logout"),
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
