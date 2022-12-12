import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/GroupPage.dart';
import 'package:final_project/LakeNixonEvent.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Group.dart';
import "package:final_project/calender_page.dart";
import "Event.dart";

Color nixonblue = const Color.fromRGBO(165, 223, 249, 1);
Color nixonyellow = const Color.fromRGBO(255, 248, 153, 1);
Color nixonbrown = const Color.fromRGBO(137, 116, 73, 1);
Color nixongreen = const Color.fromRGBO(81, 146, 78, 1);

FirebaseFirestore db = FirebaseFirestore.instance;

List<Event> dbEvents = [];

Map<Group, List<Appointment>> events = {};

var assignments = {};

var events2 = {};

List<Group> groups = <Group>[
  const Group(name: "Chipmunks", color: Color(0xFF0F8644), age: 1),
  const Group(name: "Hummingbirds", color: Color(0xFF8B1FA9), age: 1),
  const Group(name: "Tadpoles", color: Color(0xFFD20100), age: 1),
  const Group(name: "Sparrows", color: Color(0xFF5DADE2), age: 1),
  const Group(name: "Salamanders", color: Color(0xFFDC7633), age: 1),
  const Group(name: "Robins", color: Color(0xFFDEB6F1), age: 1),
  const Group(name: "Minks", color: Color(0xFF909497), age: 3),
  const Group(name: "Otters", color: Color(0xFF117864), age: 3),
  const Group(name: "Raccoons", color: Color(0xFF2E4053), age: 3),
  const Group(name: "Kingfishers", color: Color(0xFFF4D03F), age: 3),
  const Group(name: "Squirrels", color: Color(0xFFEA45E1), age: 3),
  const Group(name: "Blue Jays", color: Color(0xFF2471A3), age: 3),
  const Group(name: "Deer", color: Color(0xFF504040), age: 5),
  const Group(name: "Crows", color: Color(0xFF1C2833), age: 5),
  const Group(name: "Bears", color: Color(0xFF60EA7A), age: 5),
  const Group(name: "Foxes", color: Color(0xFFD35400), age: 5),
  const Group(name: "Herons", color: Color(0xFF456CEA), age: 5),
  const Group(name: "Wolves", color: Color(0xFF566573), age: 5),
  const Group(name: "Copperheads", color: Color(0xFFD68910), age: 6),
  const Group(name: "Timber Rattlers", color: Color(0xFFABEBC6), age: 8),
  const Group(name: "Admin", color: Color.fromARGB(255, 0, 0, 0), age: 9999)
];

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

void createGroup(Group group) {
  if (events.containsKey(group)) {
  } else {
    //events[group] = <LakeNixonEvent>[];
    events[group] = <Appointment>[];
    assignments[group] = <Group>[];
  }
}
