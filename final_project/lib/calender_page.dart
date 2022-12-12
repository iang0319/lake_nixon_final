import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Event.dart';
import 'package:final_project/Group.dart';
import 'package:final_project/LakeNixonEvent.dart';
import 'package:final_project/appointment_editor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:final_project/globals.dart';

List<LakeNixonEvent> appointments = <LakeNixonEvent>[];

//late bool isUser;

class CalendarPage extends StatefulWidget {
  CalendarPage(
      {super.key,
      required this.title,
      required this.group,
      required this.isUser,
      required this.master});

  final String title;
  final Group group;
  final bool isUser;
  final bool master;
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

final List<CalendarView> _allowedViews = <CalendarView>[
  CalendarView.workWeek,
  CalendarView.day,
  CalendarView.timelineDay,
  CalendarView.timelineWorkWeek,
];

class _CalendarPageState extends State<CalendarPage> {
  _CalendarPageState();

  //AppointmentDataSource _events = AppointmentDataSource(<Appointment>[]);
  late CalendarView _currentView;

  /// Global key used to maintain the state, when we change the parent of the
  /// widget
  final GlobalKey _globalKey = GlobalKey();
  final ScrollController _controller = ScrollController();
  final CalendarController _calendarController = CalendarController();
  //LakeNixonEvent? _selectedAppointment;
  Appointment? _selectedAppointment;
  final List<String> _colorNames = <String>[];
  final List<Color> _colorCollection = <Color>[];
  final List<String> _timeZoneCollection = <String>[];
  late AppointmentDataSource _events;
  List<DropdownMenuItem<String>> firebaseEvents = [];
  List<Appointment> savedEvents = [];

  @override
  void initState() {
    _currentView = CalendarView.workWeek;
    _calendarController.view = _currentView;
    bool user = widget.isUser;
    getEvents();
    _events = AppointmentDataSource(_getDataSource(widget.group));

    super.initState();
  }

  Future<void> getEvents() async {
    CollectionReference events =
        FirebaseFirestore.instance.collection("events");
    final snapshot = await events.get();
    if (snapshot.size > 0 && dbEvents.length == 0) {
      List<QueryDocumentSnapshot<Object?>> data = snapshot.docs;
      for (var element in data) {
        var event = element.data() as Map;
        var tmp = Event(
            name: event["name"],
            ageMin: event["ageMin"],
            groupMax: event["groupMax"]);
        dbEvents.add(tmp);
      }
    } else {
      print('No data available.3');
    }
    for (Event event in dbEvents) {
      firebaseEvents
          .add(DropdownMenuItem(value: event.name, child: Text(event.name)));
    }
    print(dbEvents);
  }

  List<Appointment> _getDataSource(Group group) {
    _colorNames.add('Green');
    _colorNames.add('Purple');
    _colorNames.add('Red');
    _colorNames.add('Orange');
    _colorNames.add('Caramel');
    _colorNames.add('Light Green');
    _colorNames.add('Blue');
    _colorNames.add('Peach');
    _colorNames.add('Gray');
    _colorNames.add('Light Blue');
    _colorNames.add('Light Orange');
    _colorNames.add('Violet');
    _colorNames.add('Light Gray');
    _colorNames.add('Green2');
    _colorNames.add('Navy');
    _colorNames.add('Yellow');
    _colorNames.add('Pink');
    _colorNames.add('Blue2');
    _colorNames.add('Brown');
    _colorNames.add('Dark Navy');
    _colorNames.add('Lighter Green');
    _colorNames.add('Orange2');
    _colorNames.add('Blue3');
    _colorNames.add('Fade Blue');
    _colorNames.add('Orange3');
    _colorNames.add('Light Green2');
    _colorNames.add('Admin');

    //_colorNames.add("Green");

    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF36B37B));
    _colorCollection.add(const Color(0xFF01A1EF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));
    _colorCollection.add(const Color(0xFF5DADE2));
    _colorCollection.add(const Color(0xFFDC7633));
    _colorCollection.add(const Color(0xFFDEB6F1));
    _colorCollection.add(const Color(0xFF909497));
    _colorCollection.add(const Color(0xFF117864));
    _colorCollection.add(const Color(0xFF2E4053));
    _colorCollection.add(const Color(0xFFF4D03F));
    _colorCollection.add(const Color(0xFFEA45E1));
    _colorCollection.add(const Color(0xFF2471A3));
    _colorCollection.add(const Color(0xFF504040));
    _colorCollection.add(const Color(0xFF1C2833));
    _colorCollection.add(const Color(0xFF60EA7A));
    _colorCollection.add(const Color(0xFFD35400));
    _colorCollection.add(const Color(0xFF456CEA));
    _colorCollection.add(const Color(0xFF566573));
    _colorCollection.add(const Color(0xFFD68910));
    _colorCollection.add(const Color(0xFFABEBC6));
    _colorCollection.add(const Color(0xFFFFFFFF));

    //_colorCollection.add(const Color(0xFF0A8043));

    if (widget.master) {
      List<Appointment> appointments = <Appointment>[];
      events.forEach((key, value) {
        appointments.insertAll(appointments.length, value);
      });
      return appointments;
    } else {
      return events[group] as List<Appointment>;
    }
  }

  void _onViewChanged(ViewChangedDetails viewChangedDetails) {
    if (_currentView != CalendarView.month &&
        _calendarController.view != CalendarView.month) {
      _currentView = _calendarController.view!;
      return;
    }

    _currentView = _calendarController.view!;
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      setState(() {
        // Update the scroll view when view changes.
      });
    });
  }

  void _onCalendarTapped(CalendarTapDetails calendarTapDetails) {
    /// Condition added to open the editor, when the calendar elements tapped
    /// other than the header.
    if (calendarTapDetails.targetElement == CalendarElement.header ||
        calendarTapDetails.targetElement == CalendarElement.viewHeader) {
      return;
    }

    _selectedAppointment = null;

    /// Navigates the calendar to day view,
    /// when we tap on month cells in mobile.
    if (_calendarController.view == CalendarView.month) {
      _calendarController.view = CalendarView.day;
    } else {
      if (calendarTapDetails.appointments != null &&
          calendarTapDetails.targetElement == CalendarElement.appointment) {
        final dynamic appointment = calendarTapDetails.appointments![0];
        if (appointment is Appointment) {
          _selectedAppointment = appointment;
        }
      }

      final DateTime selectedDate = calendarTapDetails.date!;
      final CalendarElement targetElement = calendarTapDetails.targetElement;
      Navigator.push<Widget>(
        context,
        MaterialPageRoute<Widget>(
            builder: (BuildContext context) => AppointmentEditor(
                _selectedAppointment,
                targetElement,
                selectedDate,
                _colorCollection,
                _colorNames,
                _events,
                _timeZoneCollection,
                widget.group,
                firebaseEvents)),
      ).then((value) {
        setState(() {});
      });
    }
  }

  Widget _getCalendar() {
    if (widget.master) {
      return _getMasterCalender(
          _calendarController, _events, _onViewChanged, _onCalendarTapped);
    } else {
      return _getLakeNixonCalender(
          _calendarController, _events, _onViewChanged, _onCalendarTapped);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget calendar = Theme(

        /// The key set here to maintain the state, when we change
        /// the parent of the widget
        key: _globalKey,
        data: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSwatch(
            backgroundColor: theme,
          ),
        ),
        child: _getCalendar());

    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.group.name} calendar",
            style: TextStyle(color: nixonbrown, fontFamily: 'Fruit')),
        backgroundColor: nixonblue,
      ),
      body: Row(children: <Widget>[
        Expanded(
          child: Container(color: theme, child: calendar),
        )
      ]),
    );
  }
}

dynamic tapped(bool user, dynamic tap) {
  if (user == true) {
    return null;
  } else {
    return tap;
  }
}

SfCalendar _getLakeNixonCalender(
    [CalendarController? calendarController,
    CalendarDataSource? calendarDataSource,
    ViewChangedCallback? viewChangedCallback,
    dynamic calendarTapCallback]) {
  return SfCalendar(
    controller: calendarController,
    dataSource: calendarDataSource,
    allowedViews: _allowedViews,
    onViewChanged: viewChangedCallback,
    allowDragAndDrop: true,
    showDatePickerButton: true,
    monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
    timeSlotViewSettings: const TimeSlotViewSettings(
        minimumAppointmentDuration: Duration(minutes: 60),
        startHour: 7,
        endHour: 18,
        nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday]),
    onTap: tapped(false, calendarTapCallback),
  );
}

SfCalendar _getMasterCalender(
    [CalendarController? calendarController,
    CalendarDataSource? calendarDataSource,
    ViewChangedCallback? viewChangedCallback,
    dynamic calendarTapCallback]) {
  return SfCalendar(
    controller: calendarController,
    dataSource: calendarDataSource,
    allowedViews: _allowedViews,
    onViewChanged: viewChangedCallback,
    allowDragAndDrop: true,
    showDatePickerButton: true,
    monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
    timeSlotViewSettings: const TimeSlotViewSettings(
        minimumAppointmentDuration: Duration(minutes: 60),
        startHour: 7,
        endHour: 18,
        nonWorkingDays: <int>[DateTime.saturday, DateTime.sunday]),
    onTap: tapped(false, calendarTapCallback),
  );
}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class AppointmentDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  AppointmentDataSource(List<Appointment> source) {
    this.appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).endTime;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).subject;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).color;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Appointment _getMeetingData(int index) {
    final dynamic meeting = appointments[index];
    late final Appointment meetingData;
    if (meeting is Appointment) {
      meetingData = meeting;
    }

    return meetingData;
  }
}
