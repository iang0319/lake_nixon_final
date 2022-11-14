import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Group.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

var events = {};

void createGroup(Group group) {
  if (events.containsKey(group)) {
  } else {
    events[group] = <Appointment>[];
  }
}
