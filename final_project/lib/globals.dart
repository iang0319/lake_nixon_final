import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/GroupPage.dart';
import 'package:final_project/LakeNixonEvent.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Group.dart';
import "package:final_project/calender_page.dart";

FirebaseFirestore db = FirebaseFirestore.instance;

List dbEvents = [];

var events2 = {};

var events = {};

var assignments = {};

void createGroup(Group group) {
  if (events.containsKey(group)) {
  } else {
    //events[group] = <LakeNixonEvent>[];
    events[group] = <Appointment>[];
    assignments[group] = <Group>[];
  }
}
