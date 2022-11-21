import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/GroupPage.dart';
import 'package:final_project/LakeNixonEvent.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Group.dart';
import "package:final_project/calender_page.dart";
import "Event.dart";

FirebaseFirestore db = FirebaseFirestore.instance;

List<Event> dbEvents = [];

int indexEvents(String name) {
  int count = 0;
  for (Event element in dbEvents) {
    if (element.name == name) {
      return count;
    }
    count++;
  }
  return -1;
}

var events2 = {};

Map<Group, List<Appointment>> events = {};

Group? indexGroups(String name) {
  int count = 0;
  int index = -1;
  Group? group;
  events.forEach((key, value) {
    if (key.name == name) {
      index = count;
      group = key;
    }
    count++;
  });
  return group;
}

var assignments = {};

void createGroup(Group group) {
  if (events.containsKey(group)) {
  } else {
    //events[group] = <LakeNixonEvent>[];
    events[group] = <Appointment>[];
    assignments[group] = <Group>[];
  }
}
