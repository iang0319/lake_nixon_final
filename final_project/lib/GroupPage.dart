import 'package:flutter/material.dart';
import 'Group.dart';
import 'calender_page.dart';
import "globals.dart";
import 'package:firebase_database/firebase_database.dart';

List<Group> groups = <Group>[
  const Group(name: "Bears"),
  const Group(name: "Koalas"),
  const Group(name: "Kangaroos")
];

class GroupPage extends StatefulWidget {
  GroupPage({super.key, required this.title});

  final String title;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  Future<void> _handleCalendar(Group group) async {
    print("Chat");
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarPage(title: group.name, group: group),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('List of groups'),
        ),
        body: Column(
          // padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: groups.map((Group) {
            return GroupItem(
              group: Group,
              onListChanged: _handleCalendar,
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              DatabaseReference test = FirebaseDatabase.instance.ref('events');
              final snapshot = await test.child('users').get();
              if (snapshot.exists) {
                print(snapshot.value);
              } else {
                print('No data available.');
              }
              DatabaseReference ref = FirebaseDatabase.instance.ref("events");
              await ref.update({
                "one": {"name": "Swimming", "age_limit": 15, "group_limit": 2}
              });
              await ref.update({
                "two": {"name": "Volleyball", "age_limit": 10, "group_limit": 3}
              });
            }));
  }
}
