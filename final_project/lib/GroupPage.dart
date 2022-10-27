import 'package:flutter/material.dart';
import 'Group.dart';
import 'calender_page.dart';

List<Group> groups = <Group>[
  const Group(name: "Bears"),
  const Group(name: "Koalas")
];

class GroupPage extends StatefulWidget {
  GroupPage({super.key, required this.title});

  final String title;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
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
              //completed: ,
              //onListChanged: _handleListChanged,
            );
          }).toList(),
        ),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add), onPressed: () {}));
  }
}
