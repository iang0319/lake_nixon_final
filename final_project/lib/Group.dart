import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Group {
  Group({required this.name});

  final String name;

  /// Try and let each individual group have a list of appointments that are added to in the calendar
  /// Something along this line
  late List<Appointment> meetings;

  String abbrev() {
    return name.substring(0, 1);
  }
}

typedef ToDoListChangedCallback = Function(Group group);
//typedef ToDoListRemovedCallback = Function(Car car);

class GroupItem extends StatelessWidget {
  GroupItem(
      { //required this.completed,
      required this.onListChanged,
      required this.group})
      : super(key: ObjectKey(group));

  //final bool completed;
  final ToDoListChangedCallback onListChanged;
  final Group group;

  Color _getColor(BuildContext context) {
    // The theme depends on the BuildContext because different
    // parts of the tree can have different themes.
    // The BuildContext indicates where the build is
    // taking place and therefore which theme to use.
    return Colors.black;
    //return completed //
    //? Colors.black54
    //: Theme.of(context).primaryColor;
  }

  TextStyle? _getTextStyle(BuildContext context) {
    //if (!completed) return null;

    return const TextStyle(
      color: Colors.black,
      //decoration: TextDecoration.lineThrough,
    );
  }

  // _detailCounter(BuildContext)

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onListChanged(group);
      },
      leading: CircleAvatar(
        backgroundColor: _getColor(context),
        child: Text(group.abbrev()),
      ),
      title: Text(
        group.name,
        style: _getTextStyle(context),
      ),
    );
  }
}
