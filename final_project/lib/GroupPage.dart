import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/userCalendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Group.dart';
import 'calender_page.dart';
import "globals.dart";
import 'package:firebase_database/firebase_database.dart';
import "create_event.dart" as Event;

class GroupPage extends StatefulWidget {
  GroupPage({super.key, required this.title});

  final String title;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  String role = "user";
  var eventController = TextEditingController();
  var ageLimitController = TextEditingController();
  var groupSizeController = TextEditingController();
  var descriptionController = TextEditingController();

  Future<void> UserPush(Group group) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => UserCalendarPage(
                title: group.name,
                group: group,
                isUser: true,
                master: false,
              )),
    );
    //await Navigator.of(context).push(
    //MaterialPageRoute(builder: (context) => const StartPage()),
    //);
  }

  Future<void> AdminPush(Group group) async {
    //await Navigator.of(context).push(
    // MaterialPageRoute(builder: (context) => const SplashScreen()),
    //);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarPage(
          title: group.name,
          group: group,
          isUser: false,
          master: false,
        ),
      ),
    );
    //await Navigator.of(context).push(
    //MaterialPageRoute(builder: (context) => const StartPage()),
    //);
  }

  void _checkAuth(Group group) async {
    User? user = FirebaseAuth.instance.currentUser;

    final DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .get();

    setState(() {
      role = snap['role'];
    });

    if (role == 'user') {
      UserPush(group);
    } else {
      AdminPush(group);
    }
  }

  Future<void> _handleCalendar(Group group) async {
    print("Chat");

    _checkAuth(group);
    //await Navigator.of(context).push(
    //MaterialPageRoute(
    //builder: (context) => CalendarPage(title: group.name, group: group),
    //),
    //);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List of Groups",
            style: TextStyle(
                //check here later --- can't insert nixonbrown for some reason?
                color: Color.fromRGBO(137, 116, 73, 1),
                fontFamily: 'Fruit')),
        backgroundColor: nixonblue,
      ),
      body: Container(
          padding: const EdgeInsets.fromLTRB(10, 20, 40, 0),
          child: ListView(
            // padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: groups.map((Group) {
              return GroupItem(
                group: Group,
                onListChanged: _handleCalendar,
              );
            }).toList(),
          )),
      // floatingActionButton: FloatingActionButton(
      //     child: const Icon(Icons.add),
      //     onPressed: () async {
      //       //_EventInfoPopupForm(context);
      //     })
    );
  }

  Future<void> _EventInfoPopupForm(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Event'),
          content: SingleChildScrollView(
            child: SizedBox(
              height: 200,
              width: 200,
              child: Column(
                children: [
                  // call FormFieldTemplate for each
                  // will allow for easier universal use for future code iterations
                  FormFieldTemplate(
                      controller: eventController,
                      decoration: 'Event',
                      formkey: "EventField"),
                  FormFieldTemplate(
                      controller: ageLimitController,
                      decoration: 'Age Limit',
                      formkey: "MarkField"),
                  FormFieldTemplate(
                      controller: groupSizeController,
                      decoration: 'Group Size',
                      formkey: "YearField"),
                  FormFieldTemplate(
                      controller: descriptionController,
                      decoration: 'Description',
                      formkey: "MeetField"),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              key: const Key("OKButton"),
              onPressed: () async {
                // This is how you get the database from Firebase
                CollectionReference events =
                    FirebaseFirestore.instance.collection("events");
                final snapshot = await events.get();

                // Example of reading in a collection and getting each doc

                // if (snapshot.size > 0) {
                //   List<QueryDocumentSnapshot<Object?>> data = snapshot.docs;
                //   data.forEach((element) {
                //     print(element.data());
                //   });
                // } else {
                //   print('No data available.');
                // }

                //This is where we write database, specfically to the event collection. You can change collection just up a couple lines
                int count = snapshot.size;
                events.doc("$count").set({
                  "name": eventController.text,
                  "ageMin": int.parse(ageLimitController.text),
                  "groupMax": int.parse(groupSizeController.text)
                });
                eventController.clear();
                ageLimitController.clear();
                groupSizeController.clear();
                descriptionController.clear();
                Navigator.pop(context);
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }
}

// standard template for FormFields when adding events
class FormFieldTemplate extends StatelessWidget {
  const FormFieldTemplate(
      {super.key,
      required this.controller,
      required this.decoration,
      required this.formkey});

  // key for field, controller, and string decoration
  final String formkey;
  final TextEditingController controller;
  final String decoration;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key(formkey),
      controller: controller,
      decoration: InputDecoration(hintText: decoration),
    );
  }
}
