import 'package:final_project/calender_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'GroupPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:final_project/login_page.dart';

class Event {
  const Event(
      {required this.name, required this.ageMin, required this.groupMax});
  final String name;
  final int ageMin;
  final int groupMax;

  @override
  String toString() {
    return name;
  }
}

class Schedule {
  const Schedule({required this.name, required this.times});
  final String name;
  final Map<String, List<dynamic>> times;

  @override
  String toString() {
    return "$name : $times";
  }

  int getList(String hour) {
    return times[hour]!.length;
  }

  void newGroup(String time, String groupName) {
    times[time] = [groupName];
  }

  void addGroup(String time, String groupName) {
    times[time]!.add(groupName);
  }
}
