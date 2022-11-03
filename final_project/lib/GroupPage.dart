import 'package:flutter/material.dart';
import 'Group.dart';
import 'calender_page.dart';

List<Group> groups = <Group>[Group(name: "Bears"), Group(name: "Koalas")];

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
            child: const Icon(Icons.add), onPressed: () {}));
  }
}
