import 'package:final_project/GroupPage.dart';
import 'package:final_project/LakeNixonEvent.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'Group.dart';

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
