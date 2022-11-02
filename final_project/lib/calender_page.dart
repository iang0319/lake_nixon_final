import 'package:final_project/Group.dart';
import 'package:final_project/appointment_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

List<Appointment> appointments = <Appointment>[];

class CalendarPage extends StatefulWidget {
  CalendarPage({super.key, required this.title, required this.group});

  final String title;
  final Group group;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

final List<CalendarView> _allowedViews = <CalendarView>[
  CalendarView.day,
  CalendarView.week,
  CalendarView.workWeek,
  CalendarView.month,
  CalendarView.timelineDay,
  CalendarView.timelineWeek,
  CalendarView.timelineWorkWeek,
  CalendarView.timelineMonth,
];

class _CalendarPageState extends State<CalendarPage> {
  _CalendarPageState();

  AppointmentDataSource _events = AppointmentDataSource(<Appointment>[]);
  late CalendarView _currentView;

  /// Global key used to maintain the state, when we change the parent of the
  /// widget
  final GlobalKey _globalKey = GlobalKey();
  final ScrollController _controller = ScrollController();
  final CalendarController _calendarController = CalendarController();
  Appointment? _selectedAppointment;
  final List<String> _colorNames = <String>[];
  final List<Color> _colorCollection = <Color>[];
  final List<String> _timeZoneCollection = <String>[];

  @override
  void initState() {
    _currentView = CalendarView.week;
    _calendarController.view = _currentView;
    _events = AppointmentDataSource(_getDataSource());
    super.initState();
  }

  List<Appointment> _getDataSource() {
    _colorNames.add('Green');
    _colorNames.add('Purple');
    _colorNames.add('Red');
    _colorNames.add('Orange');
    _colorNames.add('Caramel');
    _colorNames.add('Light Green');
    _colorNames.add('Blue');
    _colorNames.add('Peach');
    _colorNames.add('Gray');

    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF36B37B));
    _colorCollection.add(const Color(0xFF01A1EF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));
    _colorCollection.add(const Color(0xFF0A8043));

    _timeZoneCollection.add('Default Time');
    _timeZoneCollection.add('AUS Central Standard Time');
    _timeZoneCollection.add('AUS Eastern Standard Time');
    _timeZoneCollection.add('Afghanistan Standard Time');
    _timeZoneCollection.add('Alaskan Standard Time');
    _timeZoneCollection.add('Arab Standard Time');
    _timeZoneCollection.add('Arabian Standard Time');
    _timeZoneCollection.add('Arabic Standard Time');
    _timeZoneCollection.add('Argentina Standard Time');
    _timeZoneCollection.add('Atlantic Standard Time');
    _timeZoneCollection.add('Azerbaijan Standard Time');
    _timeZoneCollection.add('Azores Standard Time');
    _timeZoneCollection.add('Bahia Standard Time');
    _timeZoneCollection.add('Bangladesh Standard Time');
    _timeZoneCollection.add('Belarus Standard Time');
    _timeZoneCollection.add('Canada Central Standard Time');
    _timeZoneCollection.add('Cape Verde Standard Time');
    _timeZoneCollection.add('Caucasus Standard Time');
    _timeZoneCollection.add('Cen. Australia Standard Time');
    _timeZoneCollection.add('Central America Standard Time');
    _timeZoneCollection.add('Central Asia Standard Time');
    _timeZoneCollection.add('Central Brazilian Standard Time');
    _timeZoneCollection.add('Central Europe Standard Time');
    _timeZoneCollection.add('Central European Standard Time');
    _timeZoneCollection.add('Central Pacific Standard Time');
    _timeZoneCollection.add('Central Standard Time');
    _timeZoneCollection.add('China Standard Time');
    _timeZoneCollection.add('Dateline Standard Time');
    _timeZoneCollection.add('E. Africa Standard Time');
    _timeZoneCollection.add('E. Australia Standard Time');
    _timeZoneCollection.add('E. South America Standard Time');
    _timeZoneCollection.add('Eastern Standard Time');
    _timeZoneCollection.add('Egypt Standard Time');
    _timeZoneCollection.add('Ekaterinburg Standard Time');
    _timeZoneCollection.add('FLE Standard Time');
    _timeZoneCollection.add('Fiji Standard Time');
    _timeZoneCollection.add('GMT Standard Time');
    _timeZoneCollection.add('GTB Standard Time');
    _timeZoneCollection.add('Georgian Standard Time');
    _timeZoneCollection.add('Greenland Standard Time');
    _timeZoneCollection.add('Greenwich Standard Time');
    _timeZoneCollection.add('Hawaiian Standard Time');
    _timeZoneCollection.add('India Standard Time');
    _timeZoneCollection.add('Iran Standard Time');
    _timeZoneCollection.add('Israel Standard Time');
    _timeZoneCollection.add('Jordan Standard Time');
    _timeZoneCollection.add('Kaliningrad Standard Time');
    _timeZoneCollection.add('Korea Standard Time');
    _timeZoneCollection.add('Libya Standard Time');
    _timeZoneCollection.add('Line Islands Standard Time');
    _timeZoneCollection.add('Magadan Standard Time');
    _timeZoneCollection.add('Mauritius Standard Time');
    _timeZoneCollection.add('Middle East Standard Time');
    _timeZoneCollection.add('Montevideo Standard Time');
    _timeZoneCollection.add('Morocco Standard Time');
    _timeZoneCollection.add('Mountain Standard Time');
    _timeZoneCollection.add('Mountain Standard Time (Mexico)');
    _timeZoneCollection.add('Myanmar Standard Time');
    _timeZoneCollection.add('N. Central Asia Standard Time');
    _timeZoneCollection.add('Namibia Standard Time');
    _timeZoneCollection.add('Nepal Standard Time');
    _timeZoneCollection.add('New Zealand Standard Time');
    _timeZoneCollection.add('Newfoundland Standard Time');
    _timeZoneCollection.add('North Asia East Standard Time');
    _timeZoneCollection.add('North Asia Standard Time');
    _timeZoneCollection.add('Pacific SA Standard Time');
    _timeZoneCollection.add('Pacific Standard Time');
    _timeZoneCollection.add('Pacific Standard Time (Mexico)');
    _timeZoneCollection.add('Pakistan Standard Time');
    _timeZoneCollection.add('Paraguay Standard Time');
    _timeZoneCollection.add('Romance Standard Time');
    _timeZoneCollection.add('Russia Time Zone 10');
    _timeZoneCollection.add('Russia Time Zone 11');
    _timeZoneCollection.add('Russia Time Zone 3');
    _timeZoneCollection.add('Russian Standard Time');
    _timeZoneCollection.add('SA Eastern Standard Time');
    _timeZoneCollection.add('SA Pacific Standard Time');
    _timeZoneCollection.add('SA Western Standard Time');
    _timeZoneCollection.add('SE Asia Standard Time');
    _timeZoneCollection.add('Samoa Standard Time');
    _timeZoneCollection.add('Singapore Standard Time');
    _timeZoneCollection.add('South Africa Standard Time');
    _timeZoneCollection.add('Sri Lanka Standard Time');
    _timeZoneCollection.add('Syria Standard Time');
    _timeZoneCollection.add('Taipei Standard Time');
    _timeZoneCollection.add('Tasmania Standard Time');
    _timeZoneCollection.add('Tokyo Standard Time');
    _timeZoneCollection.add('Tonga Standard Time');
    _timeZoneCollection.add('Turkey Standard Time');
    _timeZoneCollection.add('US Eastern Standard Time');
    _timeZoneCollection.add('US Mountain Standard Time');
    _timeZoneCollection.add('UTC');
    _timeZoneCollection.add('UTC+12');
    _timeZoneCollection.add('UTC-02');
    _timeZoneCollection.add('UTC-11');
    _timeZoneCollection.add('Ulaanbaatar Standard Time');
    _timeZoneCollection.add('Venezuela Standard Time');
    _timeZoneCollection.add('Vladivostok Standard Time');
    _timeZoneCollection.add('W. Australia Standard Time');
    _timeZoneCollection.add('W. Central Africa Standard Time');
    _timeZoneCollection.add('W. Europe Standard Time');
    _timeZoneCollection.add('West Asia Standard Time');
    _timeZoneCollection.add('West Pacific Standard Time');
    _timeZoneCollection.add('Yakutsk Standard Time');

    final List<Appointment> meetings = <Appointment>[];

    // final DateTime today = DateTime.now();
    // final DateTime startTime = DateTime(today.year, today.month, today.day, 9);
    // final DateTime endTime = startTime.add(const Duration(hours: 2));
    // meetings.add(Meeting(
    //     'Conference', startTime, endTime, const Color(0xFF0F8644), false));

    return meetings;
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

      /// To open the appointment editor for web,
      /// when the screen width is greater than 767.
      // if (model.isWebFullView && !model.isMobileResolution) {
      //   final bool isAppointmentTapped =
      //       calendarTapDetails.targetElement == CalendarElement.appointment;
      //   showDialog<Widget>(
      //       context: context,
      //       builder: (BuildContext context) {
      //         final List<Appointment> appointment = <Appointment>[];
      //         Appointment? newAppointment;

      //         /// Creates a new appointment, which is displayed on the tapped
      //         /// calendar element, when the editor is opened.
      //         if (_selectedAppointment == null) {
      //           _isAllDay = calendarTapDetails.targetElement ==
      //               CalendarElement.allDayPanel;
      //           _selectedColorIndex = 0;
      //           _subject = '';
      //           final DateTime date = calendarTapDetails.date!;

      //           newAppointment = Appointment(
      //             startTime: date,
      //             endTime: date.add(const Duration(hours: 1)),
      //             color: _colorCollection[_selectedColorIndex],
      //             isAllDay: _isAllDay,
      //             subject: _subject == '' ? '(No title)' : _subject,
      //           );
      //           appointment.add(newAppointment);

      //           _dataSource.appointments.add(appointment[0]);

      //           SchedulerBinding.instance
      //               .addPostFrameCallback((Duration duration) {
      //             _dataSource.notifyListeners(
      //                 CalendarDataSourceAction.add, appointment);
      //           });

      //           _selectedAppointment = newAppointment;
      //         }

      //         return WillPopScope(
      //           onWillPop: () async {
      //             if (newAppointment != null) {
      //               /// To remove the created appointment when the pop-up closed
      //               /// without saving the appointment.
      //               _dataSource.appointments.removeAt(
      //                   _dataSource.appointments.indexOf(newAppointment));
      //               _dataSource.notifyListeners(CalendarDataSourceAction.remove,
      //                   <Appointment>[newAppointment]);
      //             }
      //             return true;
      //           },
      //           child: Center(
      //               child: SizedBox(
      //                   width: isAppointmentTapped ? 400 : 500,
      //                   height: isAppointmentTapped
      //                       ? (_selectedAppointment!.location == null ||
      //                               _selectedAppointment!.location!.isEmpty
      //                           ? 150
      //                           : 200)
      //                       : 400,
      //                   child: Theme(
      //                       data: model.themeData,
      //                       child: Card(
      //                         margin: EdgeInsets.zero,
      //                         color: model.cardThemeColor,
      //                         shape: const RoundedRectangleBorder(
      //                             borderRadius:
      //                                 BorderRadius.all(Radius.circular(4))),
      //                         child: isAppointmentTapped
      //                             ? displayAppointmentDetails(
      //                                 context,
      //                                 targetElement,
      //                                 selectedDate,
      //                                 model,
      //                                 _selectedAppointment!,
      //                                 _colorCollection,
      //                                 _colorNames,
      //                                 _dataSource,
      //                                 _timeZoneCollection,
      //                                 _visibleDates)
      //                             : PopUpAppointmentEditor(
      //                                 model,
      //                                 newAppointment,
      //                                 appointment,
      //                                 _dataSource,
      //                                 _colorCollection,
      //                                 _colorNames,
      //                                 _selectedAppointment!,
      //                                 _timeZoneCollection,
      //                                 _visibleDates),
      //                       )))),
      //         );
      //       });
      // } else {
      /// Navigates to the appointment editor page on mobile
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
                _timeZoneCollection)),
      );
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
        child: _getLakeNixonCalender(
            _calendarController, _events, _onViewChanged, _onCalendarTapped));

    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title}'s calendr"),
      ),
      body: Row(children: <Widget>[
        Expanded(
          child: Container(color: theme, child: calendar),
        )
      ]),
    );
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
    //showNavigationArrow: model.isWebFullView,
    onViewChanged: viewChangedCallback,
    allowDragAndDrop: true,
    showDatePickerButton: true,
    monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
    timeSlotViewSettings: const TimeSlotViewSettings(
        minimumAppointmentDuration: Duration(minutes: 60)),
    onTap: calendarTapCallback,
  );
}

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class AppointmentDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
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

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
// class Meeting {
//   /// Creates a meeting class with required details.
//   Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

//   /// Event name which is equivalent to subject property of [Appointment].
//   String eventName;

//   /// From which is equivalent to start time property of [Appointment].
//   DateTime from;

//   /// To which is equivalent to end time property of [Appointment].
//   DateTime to;

//   /// Background which is equivalent to color property of [Appointment].
//   Color background;

//   /// IsAllDay which is equivalent to isAllDay property of [Appointment].
//   bool isAllDay;
// }
