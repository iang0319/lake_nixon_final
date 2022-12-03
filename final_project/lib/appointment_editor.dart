import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/Event.dart';
import 'package:final_project/Group.dart';
import 'package:final_project/LakeNixonEvent.dart';
import 'package:final_project/calender_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:syncfusion_flutter_core/core.dart';
import 'GroupPage.dart';
import "globals.dart";
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

Color theme = const Color(0xffffffff);

enum _SelectRule {
  doesNotRepeat,
  everyDay,
  everyWeek,
  everyMonth,
  everyYear,
  custom
}

class _CalendarTimeZonePicker extends StatefulWidget {
  const _CalendarTimeZonePicker(
      this.backgroundColor, this.timeZoneCollection, this.selectedTimeZoneIndex,
      {required this.onChanged});

  final Color backgroundColor;

  final List<String> timeZoneCollection;

  final int selectedTimeZoneIndex;

  final _PickerChanged onChanged;

  @override
  State<StatefulWidget> createState() {
    return _CalendarTimeZonePickerState();
  }
}

class _CalendarTimeZonePickerState extends State<_CalendarTimeZonePicker> {
  int _selectedTimeZoneIndex = -1;

  @override
  void initState() {
    _selectedTimeZoneIndex = widget.selectedTimeZoneIndex;
    super.initState();
  }

  @override
  void didUpdateWidget(_CalendarTimeZonePicker oldWidget) {
    _selectedTimeZoneIndex = widget.selectedTimeZoneIndex;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSwatch(
            backgroundColor: theme,
          ),
        ),
        child: AlertDialog(
          content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.timeZoneCollection.length,
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                      height: 50,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        leading: Icon(
                          index == _selectedTimeZoneIndex
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: widget.backgroundColor,
                        ),
                        title: Text(widget.timeZoneCollection[index]),
                        onTap: () {
                          setState(() {
                            _selectedTimeZoneIndex = index;
                            widget
                                .onChanged(_PickerChangedDetails(index: index));
                          });

                          // ignore: always_specify_types
                          Future.delayed(const Duration(milliseconds: 200), () {
                            // When task is over, close the dialog
                            Navigator.pop(context);
                          });
                        },
                      ));
                },
              )),
        ));
  }
}

class AppointmentEditor extends StatefulWidget {
  /// Holds the value of appointment editor
  const AppointmentEditor(
      this.selectedAppointment,
      this.targetElement,
      this.selectedDate,
      this.colorCollection,
      this.colorNames,
      this.events,
      this.timeZoneCollection,
      this.group,
      this.firebaseEvents,
      [this.selectedResource]);

  /// Selected appointment
  final Appointment? selectedAppointment;

  //final LakeNixonEvent? selectedAppointment;

  /// Calendar element
  final CalendarElement targetElement;

  /// Seelcted date value
  final DateTime selectedDate;

  /// Collection of colors
  final List<Color> colorCollection;

  /// List of colors name
  final List<String> colorNames;

  /// Holds the events value
  final AppointmentDataSource events;

  /// Collection of time zone values
  final List<String> timeZoneCollection;

  /// Selected calendar resource
  final CalendarResource? selectedResource;

  final Group group;

  final List<DropdownMenuItem<String>> firebaseEvents;
  @override
  _AppointmentEditorState createState() => _AppointmentEditorState();
}

Future<List<DropdownMenuItem<String>>> createDropdown() async {
  int count = 0;
  List<DropdownMenuItem<String>> menuItems = [
    const DropdownMenuItem(value: "Swimming", child: Text("Swimming"))
  ];
  const DropdownMenuItem(value: "Swimming", child: Text("Swimming"));
  DatabaseReference test = FirebaseDatabase.instance.ref();
  final snapshot = await test.child("events").get();
  if (snapshot.exists) {
    Map? test = snapshot.value as Map?;
    test?.forEach((key, value) {
      menuItems.add(DropdownMenuItem(value: value, child: Text("$value")));
      count++;
    });
  }
  return menuItems;
}

class _AppointmentEditorState extends State<AppointmentEditor> {
  int _selectedColorIndex = 0;
  int _selectedTimeZoneIndex = 0;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  bool _isAllDay = false;
  String _subject = '';
  String? _notes;
  String? _location;
  //List<Group> _groupsTest;
  List<Object>? _resourceIds;
  List<CalendarResource> _selectedResources = <CalendarResource>[];
  List<CalendarResource> _unSelectedResources = <CalendarResource>[];
  //List<DropdownMenuItem<String>> firebaseEvents = [];
  String dropdownValue = "Archery";

  RecurrenceProperties? _recurrenceProperties;
  late RecurrenceType _recurrenceType;
  RecurrenceRange? _recurrenceRange;
  late int _interval;

  _SelectRule? _rule = _SelectRule.doesNotRepeat;
  /*
  static final List<Group> _groups = [
    Group(name: "Lion"),
    Group(name: "Flamingo"),
    Group(name: "Hippo"),
    Group(name: "Owl"),
    Group(name: "Dragonfly"),
    Group(name: "Dolphin"),
  ];
  */

  final _items =
      groups.map((group) => MultiSelectItem<Group>(group, group.name)).toList();

  List<Group> _selectedGroups = [];

  final _multiSelectKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    _updateAppointmentProperties();
    _selectedGroups = assignments[widget.group];
    //getEvents();
    super.initState();
  }

  @override
  void didUpdateWidget(AppointmentEditor oldWidget) {
    _updateAppointmentProperties();
    super.didUpdateWidget(oldWidget);
  }

  /// Updates the required editor's default field
  void _updateAppointmentProperties() {
    if (widget.selectedAppointment != null) {
      _startDate = widget.selectedAppointment!.startTime;
      _endDate = widget.selectedAppointment!.endTime;
      _isAllDay = widget.selectedAppointment!.isAllDay;

      //_selectedGroups = widget.selectedAppointment!.;

      _selectedColorIndex =
          widget.colorCollection.indexOf(widget.selectedAppointment!.color);
      _selectedTimeZoneIndex =
          widget.selectedAppointment!.startTimeZone == null ||
                  widget.selectedAppointment!.startTimeZone == ''
              ? 0
              : widget.timeZoneCollection
                  .indexOf(widget.selectedAppointment!.startTimeZone!);
      _subject = widget.selectedAppointment!.subject == '(No title)'
          ? ''
          : widget.selectedAppointment!.subject;
      _notes = widget.selectedAppointment!.notes;
      _location = widget.selectedAppointment!.location;
      _resourceIds = widget.selectedAppointment!.resourceIds?.sublist(0);
      _recurrenceProperties =
          widget.selectedAppointment!.recurrenceRule != null &&
                  widget.selectedAppointment!.recurrenceRule!.isNotEmpty
              ? SfCalendar.parseRRule(
                  widget.selectedAppointment!.recurrenceRule!, _startDate)
              : null;
      if (_recurrenceProperties == null) {
        _rule = _SelectRule.doesNotRepeat;
      } else {
        _updateMobileRecurrenceProperties();
      }
    } else {
      _isAllDay = widget.targetElement == CalendarElement.allDayPanel;
      _selectedColorIndex = 0;
      _selectedTimeZoneIndex = 0;
      _subject = '';
      _notes = '';
      _location = '';

      final DateTime date = widget.selectedDate;
      _startDate = date;
      _endDate = date.add(const Duration(hours: 1));
      if (widget.selectedResource != null) {
        _resourceIds = <Object>[widget.selectedResource!.id];
      }
      _rule = _SelectRule.doesNotRepeat;
      _recurrenceProperties = null;
    }

    _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
    _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
    _selectedResources =
        _getSelectedResources(_resourceIds, widget.events.resources);
    _unSelectedResources =
        _getUnSelectedResources(_selectedResources, widget.events.resources);
  }

  void _updateMobileRecurrenceProperties() {
    _recurrenceType = _recurrenceProperties!.recurrenceType;
    _recurrenceRange = _recurrenceProperties!.recurrenceRange;
    _interval = _recurrenceProperties!.interval;
    if (_interval == 1 && _recurrenceRange == RecurrenceRange.noEndDate) {
      switch (_recurrenceType) {
        case RecurrenceType.daily:
          _rule = _SelectRule.everyDay;
          break;
        case RecurrenceType.weekly:
          if (_recurrenceProperties!.weekDays.length == 1) {
            _rule = _SelectRule.everyWeek;
          } else {
            _rule = _SelectRule.custom;
          }
          break;
        case RecurrenceType.monthly:
          _rule = _SelectRule.everyMonth;
          break;
        case RecurrenceType.yearly:
          _rule = _SelectRule.everyYear;
          break;
      }
    } else {
      _rule = _SelectRule.custom;
    }
  }

  Widget _getAppointmentEditor(
      BuildContext context, Color backgroundColor, Color defaultColor) {
    return Container(
        color: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: const Text("Events"),
              title: DropdownButton(
                value: dropdownValue,
                items: widget.firebaseEvents,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                    _subject = newValue;
                  });
                },
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: const Text("Assign Groups"),
              title: MultiSelectDialogField(
                items: _items,
                initialValue: _selectedGroups,
                onConfirm: (results) {
                  setState(() {
                    _selectedGroups = results;
                    assignments[widget.group] = _selectedGroups;
                  });
                },
              ),
            ),
            /*
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              leading: const Text(''),
              title: TextField(
                controller: TextEditingController(text: _subject),
                onChanged: (String value) {
                  _subject = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    fontSize: 25,
                    color: defaultColor,
                    fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add title',
                ),
              ),
            ),
            */
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: Icon(
                  Icons.access_time,
                  color: defaultColor,
                ),
                title: Row(children: <Widget>[
                  const Expanded(
                    child: Text('All-day'),
                  ),
                  Expanded(
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Switch(
                            value: _isAllDay,
                            onChanged: (bool value) {
                              setState(() {
                                _isAllDay = value;
                              });
                            },
                          ))),
                ])),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: const Text(''),
                title: Row(children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: _startDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData(
                                  brightness: Brightness.light,
                                  colorScheme: ColorScheme.fromSwatch(
                                    backgroundColor: theme,
                                  ),
                                ),
                                child: child!,
                              );
                            });

                        if (date != null && date != _startDate) {
                          setState(() {
                            final Duration difference =
                                _endDate.difference(_startDate);
                            _startDate = DateTime(date.year, date.month,
                                date.day, _startTime.hour, _startTime.minute);
                            _endDate = _startDate.add(difference);
                            _endTime = TimeOfDay(
                                hour: _endDate.hour, minute: _endDate.minute);
                          });
                        }
                      },
                      child: Text(
                          DateFormat('EEE, MMM dd yyyy').format(_startDate),
                          textAlign: TextAlign.left),
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: _isAllDay
                          ? const Text('')
                          : GestureDetector(
                              onTap: () async {
                                final TimeOfDay? time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                        hour: _startTime.hour,
                                        minute: _startTime.minute),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData(
                                          brightness: Brightness.light,
                                          colorScheme: ColorScheme.fromSwatch(
                                            backgroundColor:
                                                const Color(0xff4169e1),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    });

                                if (time != null && time != _startTime) {
                                  setState(() {
                                    _startTime = time;
                                    final Duration difference =
                                        _endDate.difference(_startDate);
                                    _startDate = DateTime(
                                        _startDate.year,
                                        _startDate.month,
                                        _startDate.day,
                                        _startTime.hour,
                                        _startTime.minute);
                                    _endDate = _startDate.add(difference);
                                    _endTime = TimeOfDay(
                                        hour: _endDate.hour,
                                        minute: _endDate.minute);
                                  });
                                }
                              },
                              child: Text(
                                DateFormat('hh:mm a').format(_startDate),
                                textAlign: TextAlign.right,
                              ),
                            )),
                ])),
            ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: const Text(''),
                title: Row(children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: _endDate,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData(
                                  brightness: Brightness.light,
                                  colorScheme: ColorScheme.fromSwatch(
                                    backgroundColor: const Color(0xff4169e1),
                                  ),
                                ),
                                child: child!,
                              );
                            });

                        if (date != null && date != _endDate) {
                          setState(() {
                            final Duration difference =
                                _endDate.difference(_startDate);
                            _endDate = DateTime(date.year, date.month, date.day,
                                _endTime.hour, _endTime.minute);
                            if (_endDate.isBefore(_startDate)) {
                              _startDate = _endDate.subtract(difference);
                              _startTime = TimeOfDay(
                                  hour: _startDate.hour,
                                  minute: _startDate.minute);
                            }
                          });
                        }
                      },
                      child: Text(
                        DateFormat('EEE, MMM dd yyyy').format(_endDate),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 3,
                      child: _isAllDay
                          ? const Text('')
                          : GestureDetector(
                              onTap: () async {
                                final TimeOfDay? time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay(
                                        hour: _endTime.hour,
                                        minute: _endTime.minute),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData(
                                          brightness: Brightness.light,
                                          colorScheme: ColorScheme.fromSwatch(
                                            backgroundColor:
                                                const Color(0xff4169e1),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    });

                                if (time != null && time != _endTime) {
                                  setState(() {
                                    _endTime = time;
                                    final Duration difference =
                                        _endDate.difference(_startDate);
                                    _endDate = DateTime(
                                        _endDate.year,
                                        _endDate.month,
                                        _endDate.day,
                                        _endTime.hour,
                                        _endTime.minute);
                                    if (_endDate.isBefore(_startDate)) {
                                      _startDate =
                                          _endDate.subtract(difference);
                                      _startTime = TimeOfDay(
                                          hour: _startDate.hour,
                                          minute: _startDate.minute);
                                    }
                                  });
                                }
                              },
                              child: Text(
                                DateFormat('hh:mm a').format(_endDate),
                                textAlign: TextAlign.right,
                              ),
                            )),
                ])),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(
                Icons.public,
                color: defaultColor,
              ),
              title: Text(widget.timeZoneCollection[_selectedTimeZoneIndex]),
              onTap: () {
                showDialog<Widget>(
                  context: context,
                  builder: (BuildContext context) {
                    return _CalendarTimeZonePicker(
                      const Color(0xff4169e1),
                      widget.timeZoneCollection,
                      _selectedTimeZoneIndex,
                      onChanged: (_PickerChangedDetails details) {
                        _selectedTimeZoneIndex = details.index;
                      },
                    );
                  },
                ).then((dynamic value) => setState(() {
                      /// update the time zone changes
                    }));
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(
                Icons.refresh,
                color: defaultColor,
              ),
              title: Text(_rule == _SelectRule.doesNotRepeat
                  ? 'Does not repeat'
                  : _rule == _SelectRule.everyDay
                      ? 'Every day'
                      : _rule == _SelectRule.everyWeek
                          ? 'Every week'
                          : _rule == _SelectRule.everyMonth
                              ? 'Every month'
                              : _rule == _SelectRule.everyYear
                                  ? 'Every year'
                                  : 'Custom'),
              onTap: () async {
                final dynamic properties = await showDialog<dynamic>(
                    context: context,
                    builder: (BuildContext context) {
                      return WillPopScope(
                          onWillPop: () async {
                            return true;
                          },
                          child: Theme(
                            data: ThemeData(
                                brightness: Brightness.light,
                                colorScheme: ColorScheme.fromSwatch(
                                  backgroundColor: const Color(0xff4169e1),
                                )),
                            // ignore: prefer_const_literals_to_create_immutables
                            child: _SelectRuleDialog(
                              _recurrenceProperties,
                              widget.colorCollection[_selectedColorIndex],
                              widget.events,
                              selectedAppointment: widget.selectedAppointment ??
                                  Appointment(
                                    startTime: _startDate,
                                    endTime: _endDate,
                                    isAllDay: _isAllDay,
                                    subject: _subject == ''
                                        ? '(No title)'
                                        : _subject,
                                  ),
                              onChanged: (_PickerChangedDetails details) {
                                setState(() {
                                  _rule = details.selectedRule;
                                });
                              },
                            ),
                          ));
                    });
                _recurrenceProperties = properties as RecurrenceProperties?;
              },
            ),
            if (widget.events.resources == null ||
                widget.events.resources!.isEmpty)
              Container()
            else
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                leading: Icon(Icons.people, color: defaultColor),
                title: _getResourceEditor(TextStyle(
                    fontSize: 18,
                    color: defaultColor,
                    fontWeight: FontWeight.w300)),
                onTap: () {
                  showDialog<Widget>(
                    context: context,
                    builder: (BuildContext context) {
                      return _ResourcePicker(
                        _unSelectedResources,
                        onChanged: (_PickerChangedDetails details) {
                          _resourceIds = _resourceIds == null
                              ? <Object>[details.resourceId!]
                              : (_resourceIds!.sublist(0)
                                ..add(details.resourceId!));
                          _selectedResources = _getSelectedResources(
                              _resourceIds, widget.events.resources);
                          _unSelectedResources = _getUnSelectedResources(
                              _selectedResources, widget.events.resources);
                        },
                      );
                    },
                  ).then((dynamic value) => setState(() {
                        /// update the color picker changes
                      }));
                },
              ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              leading: Icon(Icons.lens,
                  color: widget.colorCollection[_selectedColorIndex]),
              title: Text(
                widget.colorNames[_selectedColorIndex],
              ),
              onTap: () {
                showDialog<Widget>(
                  context: context,
                  builder: (BuildContext context) {
                    return _CalendarColorPicker(
                      widget.colorCollection,
                      _selectedColorIndex,
                      widget.colorNames,
                      onChanged: (_PickerChangedDetails details) {
                        _selectedColorIndex = details.index;
                      },
                    );
                  },
                ).then((dynamic value) => setState(() {
                      /// update the color picker changes
                    }));
              },
            ),
            const Divider(
              height: 1.0,
              thickness: 1,
            ),
            Container(),
            Container(),
            ListTile(
              contentPadding: const EdgeInsets.all(5),
              leading: Icon(
                Icons.subject,
                color: defaultColor,
              ),
              title: TextField(
                controller: TextEditingController(text: _notes),
                cursorColor: const Color(0xff4169e1),
                onChanged: (String value) {
                  _notes = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                style: TextStyle(
                    fontSize: 18,
                    color: defaultColor,
                    fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Add description',
                ),
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSwatch(
            backgroundColor: const Color(0xff4169e1),
          ),
        ),
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: widget.colorCollection[_selectedColorIndex],
              leading: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: <Widget>[
                IconButton(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    icon: const Icon(
                      Icons.done,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (widget.selectedAppointment != null) {
                        if (widget.selectedAppointment!.appointmentType !=
                            AppointmentType.normal) {
                          // final Appointment newAppointment = LakeNixonEvent
                          //
                          //
                          //
                          //
                          //

                          final Appointment newAppointment = Appointment(
                            startTime: _startDate,
                            endTime: _endDate,
                            color: widget.colorCollection[_selectedColorIndex],
                            startTimeZone: _selectedTimeZoneIndex == 0
                                ? ''
                                : widget
                                    .timeZoneCollection[_selectedTimeZoneIndex],
                            endTimeZone: _selectedTimeZoneIndex == 0
                                ? ''
                                : widget
                                    .timeZoneCollection[_selectedTimeZoneIndex],
                            notes: _notes,
                            isAllDay: _isAllDay,
                            subject: _subject == '' ? '(No title)' : _subject,
                            recurrenceExceptionDates: widget
                                .selectedAppointment!.recurrenceExceptionDates,
                            resourceIds: _resourceIds,
                            id: widget.selectedAppointment!.id,
                            recurrenceId:
                                widget.selectedAppointment!.recurrenceId,
                            recurrenceRule: _recurrenceProperties == null
                                ? null
                                : SfCalendar.generateRRule(
                                    _recurrenceProperties!,
                                    _startDate,
                                    _endDate),
                          );
                          /*


                          final Activity newActivity = Activity(
                              eventName: _subject,
                              from: _startDate,
                              to: _endDate,
                              background:
                                  widget.colorCollection[_selectedColorIndex],
                              isAllDay: _isAllDay,
                              numberGroupsAllowed: 3,
                              ageLimit: 3);
                */

                          showDialog<Widget>(
                              context: context,
                              builder: (BuildContext context) {
                                return WillPopScope(
                                    onWillPop: () async {
                                      return true;
                                    },
                                    child: Theme(
                                      data: ThemeData(
                                        brightness: Brightness.light,
                                        colorScheme: ColorScheme.fromSwatch(
                                          backgroundColor:
                                              const Color(0xff4169e1),
                                        ),
                                      ),
                                      // ignore: prefer_const_literals_to_create_immutables
                                      child: _EditDialog(
                                          newAppointment,
                                          widget.selectedAppointment!,
                                          _recurrenceProperties,
                                          widget.events),
                                    ));
                              });
                        } else {
                          final List<Appointment> appointment = <Appointment>[];
                          if (widget.selectedAppointment != null) {
                            widget.events.appointments!.removeAt(widget
                                .events.appointments!
                                .indexOf(widget.selectedAppointment));
                            widget.events.notifyListeners(
                                CalendarDataSourceAction.remove,
                                <Appointment>[widget.selectedAppointment!]);
                          }
                          appointment.add(Appointment(
                            startTime: _startDate,
                            endTime: _endDate,
                            color: widget.colorCollection[_selectedColorIndex],
                            startTimeZone: _selectedTimeZoneIndex == 0
                                ? ''
                                : widget
                                    .timeZoneCollection[_selectedTimeZoneIndex],
                            endTimeZone: _selectedTimeZoneIndex == 0
                                ? ''
                                : widget
                                    .timeZoneCollection[_selectedTimeZoneIndex],
                            notes: _notes,
                            isAllDay: _isAllDay,
                            subject: _subject == '' ? '(No title)' : _subject,
                            resourceIds: _resourceIds,
                            id: widget.selectedAppointment!.id,
                            recurrenceRule: _recurrenceProperties == null
                                ? null
                                : SfCalendar.generateRRule(
                                    _recurrenceProperties!,
                                    _startDate,
                                    _endDate),
                          ));
                          widget.events.appointments!.add(appointment[0]);

                          widget.events.notifyListeners(
                              CalendarDataSourceAction.add, appointment);
                          Navigator.pop(context);
                        }
                      } else {
                        final List<Appointment> appointment = <Appointment>[];
                        if (widget.selectedAppointment != null) {
                          widget.events.appointments!.removeAt(widget
                              .events.appointments!
                              .indexOf(widget.selectedAppointment));
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.remove,
                              <Appointment>[widget.selectedAppointment!]);
                        }

                        Appointment app = Appointment(
                          startTime: _startDate,
                          endTime: _endDate,
                          color: widget.colorCollection[_selectedColorIndex],
                          startTimeZone: _selectedTimeZoneIndex == 0
                              ? ''
                              : widget
                                  .timeZoneCollection[_selectedTimeZoneIndex],
                          endTimeZone: _selectedTimeZoneIndex == 0
                              ? ''
                              : widget
                                  .timeZoneCollection[_selectedTimeZoneIndex],
                          notes: _notes,
                          isAllDay: _isAllDay,
                          subject: _subject == '' ? '(No title)' : _subject,
                          resourceIds: _resourceIds,
                          recurrenceRule: _rule == _SelectRule.doesNotRepeat ||
                                  _recurrenceProperties == null
                              ? null
                              : SfCalendar.generateRRule(
                                  _recurrenceProperties!, _startDate, _endDate),
                        );
                        appointment.add(app);

                        Map<String, dynamic> appMap = {
                          "appointment": [
                            app.startTime,
                            app.endTime,
                            app.color.toString(),
                            app.startTimeZone,
                            app.endTimeZone,
                            app.notes,
                            app.isAllDay,
                            app.subject,
                            app.resourceIds,
                            app.recurrenceRule
                          ]
                        };

                        var time = app.startTime;
                        var hour = "${time.hour}";
                        var name = app.subject;
                        DateFormat formatter = DateFormat("MM-dd-yy");
                        var docName = formatter.format(time);
                        bool created = false;
                        Schedule? schedule;

                        CollectionReference schedules =
                            FirebaseFirestore.instance.collection("schedules");
                        final snapshot = await schedules.get();

                        if (snapshot.size > 0) {
                          List<QueryDocumentSnapshot<Object?>> data =
                              snapshot.docs;
                          data.forEach((element) {
                            if (docName == element.id) {
                              created = true;
                              var tmp = element.data() as Map;
                              if (tmp[name] != null) {
                                schedule =
                                    Schedule(name: name, times: tmp[name]);
                              }
                            }
                          });
                        } else {
                          print('No data available.');
                        }

                        if (created) {
                          if (schedule != null &&
                              schedule!.times[hour] != null) {
                            int i = indexEvents(schedule!.name);
                            if (dbEvents[i].groupMax <=
                                schedule!.times[hour].length) {
                              Fluttertoast.showToast(
                                  msg: "CANT ADD EVENT DUE TO RESTRICTIONS",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                              print("CANT ADD EVENT DUE TO RESTRICTIONS");
                            }
                          } else {
                            Map map = {
                              hour: [widget.group.name]
                            };
                            schedules.doc(docName).update({name: map});
                            schedules.doc(docName).update({
                              "appointments.${widget.group.name}":
                                  FieldValue.arrayUnion([appMap])
                            });
                            events[widget.group]!.add(appointment[0]);

                            widget.events.notifyListeners(
                                CalendarDataSourceAction.add, appointment);
                          }
                        } else {
                          Map map = {
                            hour: [widget.group.name]
                          };
                          schedules.doc(docName).set({dropdownValue: map});
                          schedules.doc(docName).update({
                            "appointments.${widget.group.name}":
                                FieldValue.arrayUnion([appMap])
                          });
                          events[widget.group]!.add(appointment[0]);

                          widget.events.notifyListeners(
                              CalendarDataSourceAction.add, appointment);
                        }

                        Navigator.pop(context);
                      }
                    })
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Stack(
                children: <Widget>[
                  _getAppointmentEditor(context, (Colors.white), Colors.black87)
                ],
              ),
            ),
            floatingActionButton: widget.selectedAppointment == null
                ? const Text('')
                : FloatingActionButton(
                    onPressed: () {
                      if (widget.selectedAppointment != null) {
                        if (widget.selectedAppointment!.appointmentType ==
                            AppointmentType.normal) {
                          //Another Potential Fix?

                          Map<String, dynamic> appMap = {
                            "appointment": [
                              widget.selectedAppointment?.startTime,
                              widget.selectedAppointment?.endTime,
                              widget.selectedAppointment?.color.toString(),
                              widget.selectedAppointment?.startTimeZone,
                              widget.selectedAppointment?.endTimeZone,
                              widget.selectedAppointment?.notes,
                              widget.selectedAppointment?.isAllDay,
                              widget.selectedAppointment?.subject,
                              widget.selectedAppointment?.resourceIds,
                              widget.selectedAppointment?.recurrenceRule
                            ]
                          };

                          var time = widget.selectedAppointment?.startTime;
                          var hour = "${time?.hour}";
                          var name = widget.selectedAppointment?.subject;
                          DateFormat formatter = DateFormat("MM-dd-yy");
                          var docName = formatter.format(time!);
                          bool created = false;
                          Schedule? schedule;

                          db.collection("schedules").doc(docName).delete().then(
                                (doc) => print("Document deleted"),
                                onError: (e) =>
                                    print("Error updating document $e"),
                              );

                          widget.events.appointments?.removeAt(widget
                              .events.appointments!
                              .indexOf(widget.selectedAppointment));
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.remove,
                              <Appointment>[widget.selectedAppointment!]);
                          Navigator.pop(context);
                        } else {
                          showDialog<Widget>(
                              context: context,
                              builder: (BuildContext context) {
                                return WillPopScope(
                                    onWillPop: () async {
                                      return true;
                                    },
                                    child: Theme(
                                      data: ThemeData(
                                        brightness: Brightness.light,
                                        colorScheme: ColorScheme.fromSwatch(
                                          backgroundColor:
                                              const Color(0xff4169e1),
                                        ),
                                      ),
                                      // ignore: prefer_const_literals_to_create_immutables
                                      child: _DeleteDialog(
                                          widget.selectedAppointment!,
                                          widget.events),
                                    ));
                              });
                        }
                      }
                    },
                    backgroundColor: const Color(0xff4169e1),
                    child:
                        const Icon(Icons.delete_outline, color: Colors.white),
                  )));
  }

  Widget _getResourceEditor(TextStyle hintTextStyle) {
    if (_selectedResources == null || _selectedResources.isEmpty) {
      return Text('Add people', style: hintTextStyle);
    }

    final List<Widget> chipWidgets = <Widget>[];
    for (int i = 0; i < _selectedResources.length; i++) {
      final CalendarResource selectedResource = _selectedResources[i];
      chipWidgets.add(Chip(
        padding: EdgeInsets.zero,
        avatar: CircleAvatar(
          backgroundColor: const Color(0xff4169e1),
          backgroundImage: selectedResource.image,
          child: selectedResource.image == null
              ? Text(selectedResource.displayName[0])
              : null,
        ),
        label: Text(selectedResource.displayName),
        onDeleted: () {
          _selectedResources.removeAt(i);
          _resourceIds!.removeAt(i);
          _unSelectedResources = _getUnSelectedResources(
              _selectedResources, widget.events.resources);
          setState(() {});
        },
      ));
    }

    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: chipWidgets,
    );
  }
}

List<CalendarResource> _getSelectedResources(
    List<Object>? resourceIds, List<CalendarResource>? resourceCollection) {
  final List<CalendarResource> selectedResources = <CalendarResource>[];
  if (resourceIds == null ||
      resourceIds.isEmpty ||
      resourceCollection == null ||
      resourceCollection.isEmpty) {
    return selectedResources;
  }

  for (int i = 0; i < resourceIds.length; i++) {
    final CalendarResource resourceName =
        _getResourceFromId(resourceIds[i], resourceCollection);
    selectedResources.add(resourceName);
  }

  return selectedResources;
}

/// Returns the available resource, by filtering the resource collection from
/// the selected resource collection.
List<CalendarResource> _getUnSelectedResources(
    List<CalendarResource>? selectedResources,
    List<CalendarResource>? resourceCollection) {
  if (selectedResources == null ||
      selectedResources.isEmpty ||
      resourceCollection == null ||
      resourceCollection.isEmpty) {
    return resourceCollection ?? <CalendarResource>[];
  }

  final List<CalendarResource> collection = resourceCollection.sublist(0);
  for (int i = 0; i < resourceCollection.length; i++) {
    final CalendarResource resource = resourceCollection[i];
    for (int j = 0; j < selectedResources.length; j++) {
      final CalendarResource selectedResource = selectedResources[j];
      if (resource.id == selectedResource.id) {
        collection.remove(resource);
      }
    }
  }

  return collection;
}

CalendarResource _getResourceFromId(
    Object resourceId, List<CalendarResource> resourceCollection) {
  return resourceCollection
      .firstWhere((CalendarResource resource) => resource.id == resourceId);
}

typedef _PickerChanged = void Function(
    _PickerChangedDetails pickerChangedDetails);

/// Details for the [_PickerChanged].
class _PickerChangedDetails {
  _PickerChangedDetails(
      {this.index = -1,
      this.resourceId,
      this.selectedRule = _SelectRule.doesNotRepeat});

  final int index;

  final Object? resourceId;

  final _SelectRule? selectedRule;
}

class _SelectRuleDialog extends StatefulWidget {
  _SelectRuleDialog(
      this.recurrenceProperties, this.appointmentColor, this.events,
      {required this.onChanged, this.selectedAppointment});

  final Appointment? selectedAppointment;

  RecurrenceProperties? recurrenceProperties;

  final Color appointmentColor;

  final CalendarDataSource events;

  final _PickerChanged onChanged;

  @override
  _SelectRuleDialogState createState() => _SelectRuleDialogState();
}

class _SelectRuleDialogState extends State<_SelectRuleDialog> {
  late DateTime _startDate;
  RecurrenceProperties? _recurrenceProperties;
  late RecurrenceType _recurrenceType;
  late RecurrenceRange _recurrenceRange;
  late int _interval;

  _SelectRule? _rule;

  @override
  void initState() {
    _updateAppointmentProperties();
    super.initState();
  }

  @override
  void didUpdateWidget(_SelectRuleDialog oldWidget) {
    _updateAppointmentProperties();
    super.didUpdateWidget(oldWidget);
  }

  /// Updates the required editor's default field
  void _updateAppointmentProperties() {
    _startDate = widget.selectedAppointment!.startTime;
    _recurrenceProperties = widget.recurrenceProperties;
    if (widget.recurrenceProperties == null) {
      _rule = _SelectRule.doesNotRepeat;
    } else {
      _updateRecurrenceType();
    }
  }

  void _updateRecurrenceType() {
    _recurrenceType = widget.recurrenceProperties!.recurrenceType;
    _recurrenceRange = _recurrenceProperties!.recurrenceRange;
    _interval = _recurrenceProperties!.interval;
    if (_interval == 1 && _recurrenceRange == RecurrenceRange.noEndDate) {
      switch (_recurrenceType) {
        case RecurrenceType.daily:
          _rule = _SelectRule.everyDay;
          break;
        case RecurrenceType.weekly:
          if (_recurrenceProperties!.weekDays.length == 1) {
            _rule = _SelectRule.everyWeek;
          } else {
            _rule = _SelectRule.custom;
          }
          break;
        case RecurrenceType.monthly:
          _rule = _SelectRule.everyMonth;
          break;
        case RecurrenceType.yearly:
          _rule = _SelectRule.everyYear;
          break;
      }
    } else {
      _rule = _SelectRule.custom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: 360,
        padding: const EdgeInsets.only(left: 20, top: 10),
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          Container(
            width: 360,
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              children: <Widget>[
                RadioListTile<_SelectRule>(
                  title: const Text('Does not repeat'),
                  value: _SelectRule.doesNotRepeat,
                  groupValue: _rule,
                  toggleable: true,
                  activeColor: const Color(0xff4169e1),
                  onChanged: (_SelectRule? value) {
                    setState(() {
                      if (value != null) {
                        _rule = value;
                        widget.recurrenceProperties = null;
                        widget.onChanged(
                            _PickerChangedDetails(selectedRule: _rule));
                      }
                    });
                    Navigator.pop(context, widget.recurrenceProperties);
                  },
                ),
                RadioListTile<_SelectRule>(
                  title: const Text('Every day'),
                  value: _SelectRule.everyDay,
                  toggleable: true,
                  groupValue: _rule,
                  activeColor: const Color(0xff4169e1),
                  onChanged: (_SelectRule? value) {
                    setState(() {
                      if (value != null) {
                        _rule = value;
                        widget.recurrenceProperties =
                            RecurrenceProperties(startDate: _startDate);
                        widget.recurrenceProperties!.recurrenceType =
                            RecurrenceType.daily;
                        widget.recurrenceProperties!.interval = 1;
                        widget.recurrenceProperties!.recurrenceRange =
                            RecurrenceRange.noEndDate;
                        widget.onChanged(
                            _PickerChangedDetails(selectedRule: _rule));
                      }
                    });
                    Navigator.pop(context, widget.recurrenceProperties);
                  },
                ),
                RadioListTile<_SelectRule>(
                  title: const Text('Every week'),
                  value: _SelectRule.everyWeek,
                  toggleable: true,
                  groupValue: _rule,
                  activeColor: const Color(0xff4169e1),
                  onChanged: (_SelectRule? value) {
                    setState(() {
                      if (value != null) {
                        _rule = value;
                        widget.recurrenceProperties =
                            RecurrenceProperties(startDate: _startDate);
                        widget.recurrenceProperties!.recurrenceType =
                            RecurrenceType.weekly;
                        widget.recurrenceProperties!.interval = 1;
                        widget.recurrenceProperties!.recurrenceRange =
                            RecurrenceRange.noEndDate;
                        widget.recurrenceProperties!.weekDays = _startDate
                                    .weekday ==
                                1
                            ? <WeekDays>[WeekDays.monday]
                            : _startDate.weekday == 2
                                ? <WeekDays>[WeekDays.tuesday]
                                : _startDate.weekday == 3
                                    ? <WeekDays>[WeekDays.wednesday]
                                    : _startDate.weekday == 4
                                        ? <WeekDays>[WeekDays.thursday]
                                        : _startDate.weekday == 5
                                            ? <WeekDays>[WeekDays.friday]
                                            : _startDate.weekday == 6
                                                ? <WeekDays>[WeekDays.saturday]
                                                : <WeekDays>[WeekDays.sunday];
                        widget.onChanged(
                            _PickerChangedDetails(selectedRule: _rule));
                      }
                    });
                    Navigator.pop(context, widget.recurrenceProperties);
                  },
                ),
                RadioListTile<_SelectRule>(
                  title: const Text('Every month'),
                  value: _SelectRule.everyMonth,
                  toggleable: true,
                  groupValue: _rule,
                  activeColor: const Color(0xff4169e1),
                  onChanged: (_SelectRule? value) {
                    setState(() {
                      if (value != null) {
                        _rule = value;
                        widget.recurrenceProperties =
                            RecurrenceProperties(startDate: _startDate);
                        widget.recurrenceProperties!.recurrenceType =
                            RecurrenceType.monthly;
                        widget.recurrenceProperties!.interval = 1;
                        widget.recurrenceProperties!.recurrenceRange =
                            RecurrenceRange.noEndDate;
                        widget.recurrenceProperties!.dayOfMonth =
                            widget.selectedAppointment!.startTime.day;
                        widget.onChanged(
                            _PickerChangedDetails(selectedRule: _rule));
                      }
                    });
                    Navigator.pop(context, widget.recurrenceProperties);
                  },
                ),
                RadioListTile<_SelectRule>(
                  title: const Text('Every year'),
                  value: _SelectRule.everyYear,
                  toggleable: true,
                  groupValue: _rule,
                  activeColor: const Color(0xff4169e1),
                  onChanged: (_SelectRule? value) {
                    setState(() {
                      if (value != null) {
                        _rule = value;
                        widget.recurrenceProperties =
                            RecurrenceProperties(startDate: _startDate);
                        widget.recurrenceProperties!.recurrenceType =
                            RecurrenceType.yearly;
                        widget.recurrenceProperties!.interval = 1;
                        widget.recurrenceProperties!.recurrenceRange =
                            RecurrenceRange.noEndDate;
                        widget.recurrenceProperties!.month =
                            widget.selectedAppointment!.startTime.month;
                        widget.recurrenceProperties!.dayOfMonth =
                            widget.selectedAppointment!.startTime.day;
                        widget.onChanged(
                            _PickerChangedDetails(selectedRule: _rule));
                      }
                    });
                    Navigator.pop(context, widget.recurrenceProperties);
                  },
                ),
                RadioListTile<_SelectRule>(
                  title: const Text('Custom'),
                  value: _SelectRule.custom,
                  toggleable: true,
                  groupValue: _rule,
                  activeColor: const Color(0xff4169e1),
                  onChanged: (_SelectRule? value) async {
                    final dynamic properties = await Navigator.push<dynamic>(
                      context,
                      MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => _CustomRule(
                              widget.selectedAppointment!,
                              widget.appointmentColor,
                              widget.events,
                              widget.recurrenceProperties)),
                    );
                    if (properties != widget.recurrenceProperties) {
                      setState(() {
                        _rule = _SelectRule.custom;
                        widget.onChanged(
                            _PickerChangedDetails(selectedRule: _rule));
                      });
                    }
                    if (!mounted) {
                      return;
                    }
                    Navigator.pop(context, properties);
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ResourcePicker extends StatefulWidget {
  const _ResourcePicker(this.resourceCollection, {required this.onChanged});

  final List<CalendarResource> resourceCollection;

  final _PickerChanged onChanged;

  @override
  State<StatefulWidget> createState() => _ResourcePickerState();
}

class _ResourcePickerState extends State<_ResourcePicker> {
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSwatch(
              backgroundColor: const Color(0xff4169e1),
            )),
        child: AlertDialog(
          content: SizedBox(
              width: double.maxFinite,
              height: (widget.resourceCollection.length * 50).toDouble(),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.resourceCollection.length,
                itemBuilder: (BuildContext context, int index) {
                  final CalendarResource resource =
                      widget.resourceCollection[index];
                  return SizedBox(
                      height: 50,
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xff4169e1),
                          backgroundImage: resource.image,
                          child: resource.image == null
                              ? Text(resource.displayName[0])
                              : null,
                        ),
                        title: Text(resource.displayName),
                        onTap: () {
                          setState(() {
                            widget.onChanged(
                                _PickerChangedDetails(resourceId: resource.id));
                          });

                          // ignore: always_specify_types
                          Future.delayed(const Duration(milliseconds: 200), () {
                            // When task is over, close the dialog
                            Navigator.pop(context);
                          });
                        },
                      ));
                },
              )),
        ));
  }
}

class _CalendarColorPicker extends StatefulWidget {
  const _CalendarColorPicker(
      this.colorCollection, this.selectedColorIndex, this.colorNames,
      {required this.onChanged});

  final List<Color> colorCollection;

  final int selectedColorIndex;

  final List<String> colorNames;

  final _PickerChanged onChanged;

  @override
  State<StatefulWidget> createState() => _CalendarColorPickerState();
}

class _CalendarColorPickerState extends State<_CalendarColorPicker> {
  int _selectedColorIndex = -1;

  @override
  void initState() {
    _selectedColorIndex = widget.selectedColorIndex;
    super.initState();
  }

  @override
  void didUpdateWidget(_CalendarColorPicker oldWidget) {
    _selectedColorIndex = widget.selectedColorIndex;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSwatch(
            backgroundColor: const Color(0xff4169e1),
          )),
      child: AlertDialog(
        content: SizedBox(
            width: double.maxFinite,
            height: (widget.colorCollection.length * 50).toDouble(),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: widget.colorCollection.length,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                    height: 50,
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      leading: Icon(
                          index == _selectedColorIndex
                              ? Icons.lens
                              : Icons.trip_origin,
                          color: widget.colorCollection[index]),
                      title: Text(widget.colorNames[index]),
                      onTap: () {
                        setState(() {
                          _selectedColorIndex = index;
                          widget.onChanged(_PickerChangedDetails(index: index));
                        });

                        // ignore: always_specify_types
                        Future.delayed(const Duration(milliseconds: 200), () {
                          // When task is over, close the dialog
                          Navigator.pop(context);
                        });
                      },
                    ));
              },
            )),
      ),
    );
  }
}

enum _Edit { event, series }

enum _Delete { event, series }

class _EditDialog extends StatefulWidget {
  const _EditDialog(this.newAppointment, this.selectedAppointment,
      this.recurrenceProperties, this.events);

  final Appointment newAppointment, selectedAppointment;
  final RecurrenceProperties? recurrenceProperties;
  final CalendarDataSource events;

  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  _Edit _edit = _Edit.event;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const Color defaultTextColor = Colors.white;
    return SimpleDialog(
      children: <Widget>[
        Container(
          width: 380,
          height: 210,
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            width: 370,
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 30,
                  padding: const EdgeInsets.only(left: 25, top: 5),
                  child: Text(
                    'Save recurring event',
                    style: TextStyle(
                        color: defaultTextColor, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  width: 20,
                ),
                RadioListTile<_Edit>(
                  title: const Text('This event'),
                  value: _Edit.event,
                  groupValue: _edit,
                  activeColor: const Color(0xff4169e1),
                  onChanged: (_Edit? value) {
                    setState(() {
                      _edit = value!;
                    });
                  },
                ),
                RadioListTile<_Edit>(
                  title: const Text('All events'),
                  value: _Edit.series,
                  groupValue: _edit,
                  activeColor: const Color(0xff4169e1),
                  onChanged: (_Edit? value) {
                    setState(() {
                      _edit = value!;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RawMaterialButton(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: const Color(0xff4169e1),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    RawMaterialButton(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      onPressed: () {
                        if (_edit == _Edit.event) {
                          final Appointment? parentAppointment = widget.events
                                  .getPatternAppointment(
                                      widget.selectedAppointment, '')
                              as Appointment?;

                          final Appointment newAppointment = Appointment(
                              startTime: widget.newAppointment.startTime,
                              endTime: widget.newAppointment.endTime,
                              color: widget.newAppointment.color,
                              notes: widget.newAppointment.notes,
                              isAllDay: widget.newAppointment.isAllDay,
                              location: widget.newAppointment.location,
                              subject: widget.newAppointment.subject,
                              resourceIds: widget.newAppointment.resourceIds,
                              id: widget.selectedAppointment.appointmentType ==
                                      AppointmentType.changedOccurrence
                                  ? widget.selectedAppointment.id
                                  : null,
                              recurrenceId: parentAppointment!.id,
                              startTimeZone:
                                  widget.newAppointment.startTimeZone,
                              endTimeZone: widget.newAppointment.endTimeZone);

                          parentAppointment.recurrenceExceptionDates != null
                              ? parentAppointment.recurrenceExceptionDates!
                                  .add(widget.selectedAppointment.startTime)
                              : parentAppointment.recurrenceExceptionDates =
                                  <DateTime>[
                                  widget.selectedAppointment.startTime
                                ];
                          widget.events.appointments!.removeAt(widget
                              .events.appointments!
                              .indexOf(parentAppointment));
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.remove,
                              <Appointment>[parentAppointment]);
                          widget.events.appointments!.add(parentAppointment);
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.add,
                              <Appointment>[parentAppointment]);
                          if (widget.selectedAppointment.appointmentType ==
                              AppointmentType.changedOccurrence) {
                            widget.events.appointments!.removeAt(widget
                                .events.appointments!
                                .indexOf(widget.selectedAppointment));
                            widget.events.notifyListeners(
                                CalendarDataSourceAction.remove,
                                <Appointment>[widget.selectedAppointment]);
                          }
                          widget.events.appointments!.add(newAppointment);
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.add,
                              <Appointment>[newAppointment]);
                        } else {
                          Appointment? parentAppointment = widget.events
                                  .getPatternAppointment(
                                      widget.selectedAppointment, '')
                              as Appointment?;
                          final List<DateTime>? exceptionDates =
                              parentAppointment!.recurrenceExceptionDates;
                          if (exceptionDates != null &&
                              exceptionDates.isNotEmpty) {
                            for (int i = 0; i < exceptionDates.length; i++) {
                              final Appointment? changedOccurrence =
                                  widget.events.getOccurrenceAppointment(
                                      parentAppointment, exceptionDates[i], '');
                              if (changedOccurrence != null) {
                                widget.events.appointments!
                                    .remove(changedOccurrence);
                                widget.events.notifyListeners(
                                    CalendarDataSourceAction.remove,
                                    <Appointment>[changedOccurrence]);
                              }
                            }
                          }

                          widget.events.appointments!.removeAt(widget
                              .events.appointments!
                              .indexOf(parentAppointment));
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.remove,
                              <Appointment>[parentAppointment]);
                          DateTime startDate, endDate;
                          if ((widget.newAppointment.startTime)
                              .isBefore(parentAppointment.startTime)) {
                            startDate = widget.newAppointment.startTime;
                            endDate = widget.newAppointment.endTime;
                          } else {
                            startDate = DateTime(
                                parentAppointment.startTime.year,
                                parentAppointment.startTime.month,
                                parentAppointment.startTime.day,
                                widget.newAppointment.startTime.hour,
                                widget.newAppointment.startTime.minute);
                            endDate = DateTime(
                                parentAppointment.endTime.year,
                                parentAppointment.endTime.month,
                                parentAppointment.endTime.day,
                                widget.newAppointment.endTime.hour,
                                widget.newAppointment.endTime.minute);
                          }
                          parentAppointment = Appointment(
                              startTime: startDate,
                              endTime: endDate,
                              color: widget.newAppointment.color,
                              notes: widget.newAppointment.notes,
                              isAllDay: widget.newAppointment.isAllDay,
                              location: widget.newAppointment.location,
                              subject: widget.newAppointment.subject,
                              resourceIds: widget.newAppointment.resourceIds,
                              id: parentAppointment.id,
                              recurrenceRule:
                                  widget.recurrenceProperties == null
                                      ? null
                                      : SfCalendar.generateRRule(
                                          widget.recurrenceProperties!,
                                          startDate,
                                          endDate),
                              startTimeZone:
                                  widget.newAppointment.startTimeZone,
                              endTimeZone: widget.newAppointment.endTimeZone);
                          widget.events.appointments!.add(parentAppointment);
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.add,
                              <Appointment>[parentAppointment]);
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff4169e1),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog(this.selectedAppointment, this.events);

  final Appointment selectedAppointment;
  final CalendarDataSource events;

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  _Delete _delete = _Delete.event;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const Color defaultTextColor = Colors.black87;
    return SimpleDialog(
      children: <Widget>[
        Container(
          width: 380,
          height: 210,
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            width: 370,
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 30,
                  padding: const EdgeInsets.only(left: 25, top: 5),
                  child: Text(
                    'Delete recurring event',
                    style: TextStyle(
                        color: defaultTextColor, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  width: 20,
                ),
                RadioListTile<_Delete>(
                  title: const Text('This event'),
                  value: _Delete.event,
                  groupValue: _delete,
                  activeColor: const Color(0xff4169e1),
                  onChanged: (_Delete? value) {
                    setState(() {
                      _delete = value!;
                    });
                  },
                ),
                RadioListTile<_Delete>(
                  title: const Text('All events'),
                  value: _Delete.series,
                  groupValue: _delete,
                  activeColor: const Color(0xff4169e1),
                  onChanged: (_Delete? value) {
                    setState(() {
                      _delete = value!;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RawMaterialButton(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: const Color(0xff4169e1),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    RawMaterialButton(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                      onPressed: () async {
                        ////Need to start the delete section here
                        ///Look at the firebase code

                        Navigator.pop(context);
                        final Appointment? parentAppointment = widget.events
                            .getPatternAppointment(
                                widget.selectedAppointment, '') as Appointment?;

                        Map<String, dynamic> appMap = {
                          "appointment": [
                            parentAppointment?.startTime,
                            parentAppointment?.endTime,
                            parentAppointment?.color.toString(),
                            parentAppointment?.startTimeZone,
                            parentAppointment?.endTimeZone,
                            parentAppointment?.notes,
                            parentAppointment?.isAllDay,
                            parentAppointment?.subject,
                            parentAppointment?.resourceIds,
                            parentAppointment?.recurrenceRule
                          ]
                        };

                        var time = parentAppointment?.startTime;
                        var hour = "${time?.hour}";
                        var name = parentAppointment?.subject;
                        DateFormat formatter = DateFormat("MM-dd-yy");
                        var docName = formatter.format(time!);
                        bool created = false;
                        Schedule? schedule;

                        CollectionReference schedules =
                            FirebaseFirestore.instance.collection("schedules");
                        final snapshot = await schedules.get();
                        if (_delete == _Delete.event) {
                          if (widget.selectedAppointment.recurrenceId != null) {
                            schedules.doc(docName).delete();
                            widget.events.appointments!
                                .remove(widget.selectedAppointment);
                            widget.events.notifyListeners(
                                CalendarDataSourceAction.remove,
                                <Appointment>[widget.selectedAppointment]);
                          }
                          widget.events.appointments!.removeAt(widget
                              .events.appointments!
                              .indexOf(parentAppointment));
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.remove,
                              <Appointment>[parentAppointment!]);
                          parentAppointment.recurrenceExceptionDates != null
                              ? parentAppointment.recurrenceExceptionDates!
                                  .add(widget.selectedAppointment.startTime)
                              : parentAppointment.recurrenceExceptionDates =
                                  <DateTime>[
                                  widget.selectedAppointment.startTime
                                ];
                          widget.events.appointments!.add(parentAppointment);
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.add,
                              <Appointment>[parentAppointment]);
                        } else {
                          if (parentAppointment!.recurrenceExceptionDates ==
                              null) {
                            schedules.doc(docName).delete();
                            widget.events.appointments!.removeAt(widget
                                .events.appointments!
                                .indexOf(parentAppointment));
                            widget.events.notifyListeners(
                                CalendarDataSourceAction.remove,
                                <Appointment>[parentAppointment]);
                          } else {
                            final List<DateTime>? exceptionDates =
                                parentAppointment.recurrenceExceptionDates;
                            for (int i = 0; i < exceptionDates!.length; i++) {
                              final Appointment? changedOccurrence =
                                  widget.events.getOccurrenceAppointment(
                                      parentAppointment, exceptionDates[i], '');
                              if (changedOccurrence != null) {
                                widget.events.appointments!
                                    .remove(changedOccurrence);
                                widget.events.notifyListeners(
                                    CalendarDataSourceAction.remove,
                                    <Appointment>[changedOccurrence]);
                              }
                            }
                            widget.events.appointments!.removeAt(widget
                                .events.appointments!
                                .indexOf(parentAppointment));
                            widget.events.notifyListeners(
                                CalendarDataSourceAction.remove,
                                <Appointment>[parentAppointment]);
                          }
                          //final docRef =
                          //  db.collection("schedules").doc(docName);

                          //CollectionReference schedules =
                          //FirebaseFirestore.instance.collection("schedules");
                          // Remove the field from the document
                          //final updates = <String, dynamic>{
                          //"appointments": FieldValue.delete(),
                          //};

                          //docRef.update(updates);
                          db.collection("schedules").doc(docName).delete().then(
                                (doc) => print("Document deleted"),
                                onError: (e) =>
                                    print("Error updating document $e"),
                              );

                          //schedules.collection.

                          //schedules.doc(docName).update({
                          ///  "appointments.${widget.selectedAppointment.subject}":
                          //      FieldValue.arrayUnion([appMap])
                          //  });
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff4169e1),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum _EndRule { never, endDate, count }

List<String> _weekDay = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday'
];

List<String> _weekDayPosition = <String>[
  'first',
  'second',
  'third',
  'fourth',
  'last'
];

List<String> _mobileRecurrence = <String>['day', 'week', 'month', 'year'];

class _CustomRule extends StatefulWidget {
  const _CustomRule(this.selectedAppointment, this.appointmentColor,
      this.events, this.recurrenceProperties);

  final Appointment selectedAppointment;

  final Color appointmentColor;

  final CalendarDataSource events;

  final RecurrenceProperties? recurrenceProperties;

  @override
  _CustomRuleState createState() => _CustomRuleState();
}

class _CustomRuleState extends State<_CustomRule> {
  late DateTime _startDate;
  _EndRule? _endRule;
  RecurrenceProperties? _recurrenceProperties;
  String? _selectedRecurrenceType, _monthlyRule, _weekNumberDay;
  int? _count, _interval, _month, _week;
  late int _dayOfWeek, _weekNumber, _dayOfMonth;
  late DateTime _selectedDate, _firstDate;
  late RecurrenceType _recurrenceType;
  late RecurrenceRange _recurrenceRange;
  List<WeekDays>? _days;
  late double _width;
  bool _isLastDay = false;

  @override
  void initState() {
    _updateAppointmentProperties();
    super.initState();
  }

  void _updateAppointmentProperties() {
    _width = 180;
    _startDate = widget.selectedAppointment.startTime;
    _selectedDate = _startDate.add(const Duration(days: 30));
    _count = 1;
    _interval = 1;
    _selectedRecurrenceType = _selectedRecurrenceType ?? 'day';
    _dayOfMonth = _startDate.day;
    _dayOfWeek = _startDate.weekday;
    _monthlyRule = 'Monthly on day ' + _startDate.day.toString() + 'th';
    _endRule = _EndRule.never;
    _month = _startDate.month;
    _weekNumber = _getWeekNumber(_startDate);
    _weekNumberDay = _weekDayPosition[_weekNumber == -1 ? 4 : _weekNumber - 1] +
        ' ' +
        _weekDay[_dayOfWeek - 1];
    if (_days == null) {
      _mobileInitialWeekdays(_startDate.weekday);
    }
    final Appointment? parentAppointment = widget.events
        .getPatternAppointment(widget.selectedAppointment, '') as Appointment?;
    if (parentAppointment == null) {
      _firstDate = _startDate;
    } else {
      _firstDate = parentAppointment.startTime;
    }
    _recurrenceProperties = widget.selectedAppointment.recurrenceRule != null &&
            widget.selectedAppointment.recurrenceRule!.isNotEmpty
        ? SfCalendar.parseRRule(
            widget.selectedAppointment.recurrenceRule!, _firstDate)
        : null;
    _recurrenceProperties == null
        ? _recurrenceProperties = RecurrenceProperties(startDate: _firstDate)
        : _updateCustomRecurrenceProperties();
  }

  void _updateCustomRecurrenceProperties() {
    _recurrenceType = _recurrenceProperties!.recurrenceType;
    _week = _recurrenceProperties!.week;
    _weekNumber = _recurrenceProperties!.week == 0
        ? _weekNumber
        : _recurrenceProperties!.week;
    _month = _recurrenceProperties!.month;
    _dayOfMonth = _recurrenceProperties!.dayOfMonth == 1
        ? _startDate.day
        : _recurrenceProperties!.dayOfMonth;
    _dayOfWeek = _recurrenceProperties!.dayOfWeek;

    switch (_recurrenceType) {
      case RecurrenceType.daily:
        _dayRule();
        break;
      case RecurrenceType.weekly:
        _days = _recurrenceProperties!.weekDays;
        _weekRule();
        break;
      case RecurrenceType.monthly:
        _monthRule();
        break;
      case RecurrenceType.yearly:
        _month = _recurrenceProperties!.month;
        _yearRule();
        break;
    }
    _recurrenceRange = _recurrenceProperties!.recurrenceRange;
    switch (_recurrenceRange) {
      case RecurrenceRange.noEndDate:
        _endRule = _EndRule.never;
        _rangeNoEndDate();
        break;
      case RecurrenceRange.endDate:
        _endRule = _EndRule.endDate;
        final Appointment? parentAppointment =
            widget.events.getPatternAppointment(widget.selectedAppointment, '')
                as Appointment?;
        _firstDate = parentAppointment!.startTime;
        _rangeEndDate();
        break;
      case RecurrenceRange.count:
        _endRule = _EndRule.count;
        _rangeCount();
        break;
    }
  }

  void _dayRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties = RecurrenceProperties(startDate: _startDate);
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.daily;
      _selectedRecurrenceType = 'day';
    });
  }

  void _weekRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties = RecurrenceProperties(startDate: _startDate);
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.weekly;
      _selectedRecurrenceType = 'week';
      _recurrenceProperties!.weekDays = _days!;
    });
  }

  void _monthRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties = RecurrenceProperties(startDate: _startDate);
        _monthlyDay();
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
        _week == 0 || _week == null ? _monthlyDay() : _monthlyWeek();
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.monthly;
      _selectedRecurrenceType = 'month';
    });
  }

  void _yearRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties = RecurrenceProperties(startDate: _startDate);
        _monthlyDay();
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
        _week == 0 || _week == null ? _monthlyDay() : _monthlyWeek();
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.yearly;
      _selectedRecurrenceType = 'year';
      _recurrenceProperties!.month = _month!;
    });
  }

  void _rangeNoEndDate() {
    _recurrenceProperties!.recurrenceRange = RecurrenceRange.noEndDate;
  }

  void _rangeEndDate() {
    _recurrenceProperties!.recurrenceRange = RecurrenceRange.endDate;
    _selectedDate = _recurrenceProperties!.endDate ??
        _startDate.add(const Duration(days: 30));
    _recurrenceProperties!.endDate = _selectedDate;
  }

  void _rangeCount() {
    _recurrenceProperties!.recurrenceRange = RecurrenceRange.count;
    _count = _recurrenceProperties!.recurrenceCount == 0
        ? 1
        : _recurrenceProperties!.recurrenceCount;
    _recurrenceProperties!.recurrenceCount = _count!;
  }

  void _monthlyWeek() {
    setState(() {
      _monthlyRule = 'Monthly on the ' + _weekNumberDay!;
      _recurrenceProperties!.week = _weekNumber;
      _recurrenceProperties!.dayOfWeek = _dayOfWeek;
    });
  }

  void _monthlyDay() {
    setState(() {
      _monthlyRule = 'Monthly on day ' + _startDate.day.toString() + 'th';
      _recurrenceProperties!.dayOfWeek = 0;
      _recurrenceProperties!.week = 0;
      _recurrenceProperties!.dayOfMonth = _dayOfMonth;
    });
  }

  void _lastDayOfMonth() {
    setState(() {
      _monthlyRule = 'Last day of month';
      _recurrenceProperties!.dayOfWeek = 0;
      _recurrenceProperties!.week = 0;
      _recurrenceProperties!.dayOfMonth = -1;
    });
  }

  int _getWeekNumber(DateTime startDate) {
    int weekOfMonth;
    weekOfMonth = (startDate.day / 7).ceil();
    if (weekOfMonth == 5) {
      return -1;
    }
    return weekOfMonth;
  }

  void _mobileSelectWeekDays(WeekDays day) {
    switch (day) {
      case WeekDays.sunday:
        if (_days!.contains(WeekDays.sunday) && _days!.length > 1) {
          _days!.remove(WeekDays.sunday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.sunday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.monday:
        if (_days!.contains(WeekDays.monday) && _days!.length > 1) {
          _days!.remove(WeekDays.monday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.monday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.tuesday:
        if (_days!.contains(WeekDays.tuesday) && _days!.length > 1) {
          _days!.remove(WeekDays.tuesday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.tuesday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.wednesday:
        if (_days!.contains(WeekDays.wednesday) && _days!.length > 1) {
          _days!.remove(WeekDays.wednesday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.wednesday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.thursday:
        if (_days!.contains(WeekDays.thursday) && _days!.length > 1) {
          _days!.remove(WeekDays.thursday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.thursday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.friday:
        if (_days!.contains(WeekDays.friday) && _days!.length > 1) {
          _days!.remove(WeekDays.friday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.friday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.saturday:
        if (_days!.contains(WeekDays.saturday) && _days!.length > 1) {
          _days!.remove(WeekDays.saturday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.saturday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
    }
  }

  void _mobileInitialWeekdays(int day) {
    switch (_startDate.weekday) {
      case DateTime.monday:
        _days = <WeekDays>[WeekDays.monday];
        break;
      case DateTime.tuesday:
        _days = <WeekDays>[WeekDays.tuesday];
        break;
      case DateTime.wednesday:
        _days = <WeekDays>[WeekDays.wednesday];
        break;
      case DateTime.thursday:
        _days = <WeekDays>[WeekDays.thursday];
        break;
      case DateTime.friday:
        _days = <WeekDays>[WeekDays.friday];
        break;
      case DateTime.saturday:
        _days = <WeekDays>[WeekDays.saturday];
        break;
      case DateTime.sunday:
        _days = <WeekDays>[WeekDays.sunday];
        break;
    }
  }

  double _textSize(String text) {
    const TextStyle textStyle =
        TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout();
    return textPainter.width + 60;
  }

  Widget _getCustomRule(
      BuildContext context, Color backgroundColor, Color defaultColor) {
    const Color defaultTextColor = Colors.black87;
    const Color defaultButtonColor = Colors.white;
    return Container(
        color: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15, bottom: 15),
              child: Text('REPEATS EVERY'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 15),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 40,
                    width: 60,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: TextField(
                      controller: TextEditingController.fromValue(
                          TextEditingValue(
                              text: _interval.toString(),
                              selection: TextSelection.collapsed(
                                  offset: _interval.toString().length))),
                      cursorColor: const Color(0xff4169e1),
                      onChanged: (String value) {
                        if (value != null && value.isNotEmpty) {
                          _interval = int.parse(value);
                          if (_interval == 0) {
                            _interval = 1;
                          } else if (_interval! >= 999) {
                            setState(() {
                              _interval = 999;
                            });
                          }
                        } else if (value.isEmpty || value == null) {
                          _interval = 1;
                        }
                        _recurrenceProperties!.interval = _interval!;
                      },
                      keyboardType: TextInputType.number,
                      // ignore: always_specify_types
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                          fontSize: 13,
                          color: defaultTextColor,
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                  Container(
                    height: 40,
                    width: 100,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: DropdownButton<String>(
                        focusColor: Colors.transparent,
                        isExpanded: true,
                        underline: Container(),
                        style: TextStyle(
                            fontSize: 13,
                            color: defaultTextColor,
                            fontWeight: FontWeight.w400),
                        value: _selectedRecurrenceType,
                        items: _mobileRecurrence.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            if (value == 'day') {
                              _selectedRecurrenceType = 'day';
                              _dayRule();
                            } else if (value == 'week') {
                              _selectedRecurrenceType = 'week';
                              _weekRule();
                            } else if (value == 'month') {
                              _selectedRecurrenceType = 'month';
                              _monthRule();
                            } else if (value == 'year') {
                              _selectedRecurrenceType = 'year';
                              _yearRule();
                            }
                          });
                        }),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
            ),
            Visibility(
                visible: _selectedRecurrenceType == 'week',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(left: 15, top: 15),
                      child: Text('REPEATS ON'),
                    ),
                    Padding(
                        padding:
                            const EdgeInsets.only(left: 8, bottom: 15, top: 5),
                        child: Row(
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _mobileSelectWeekDays(WeekDays.sunday);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(5, 5),
                                backgroundColor:
                                    _days!.contains(WeekDays.sunday)
                                        ? const Color(0xff4169e1)
                                        : defaultButtonColor,
                                foregroundColor:
                                    _days!.contains(WeekDays.sunday)
                                        ? Colors.white
                                        : defaultTextColor,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Text('S'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _mobileSelectWeekDays(WeekDays.monday);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(7, 7),
                                disabledForegroundColor: Colors.black26,
                                disabledBackgroundColor: Colors.black26,
                                backgroundColor:
                                    _days!.contains(WeekDays.monday)
                                        ? const Color(0xff4169e1)
                                        : defaultButtonColor,
                                foregroundColor:
                                    _days!.contains(WeekDays.monday)
                                        ? Colors.white
                                        : defaultTextColor,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(10),
                              ),
                              child: const Text('M'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _mobileSelectWeekDays(WeekDays.tuesday);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(7, 7),
                                disabledForegroundColor: Colors.black26,
                                disabledBackgroundColor: Colors.black26,
                                backgroundColor:
                                    _days!.contains(WeekDays.tuesday)
                                        ? const Color(0xff4169e1)
                                        : defaultButtonColor,
                                foregroundColor:
                                    _days!.contains(WeekDays.tuesday)
                                        ? Colors.white
                                        : defaultTextColor,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Text('T'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _mobileSelectWeekDays(WeekDays.wednesday);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(7, 7),
                                disabledForegroundColor: Colors.black26,
                                disabledBackgroundColor: Colors.black26,
                                backgroundColor:
                                    _days!.contains(WeekDays.wednesday)
                                        ? const Color(0xff4169e1)
                                        : defaultButtonColor,
                                foregroundColor:
                                    _days!.contains(WeekDays.wednesday)
                                        ? Colors.white
                                        : defaultTextColor,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(10),
                              ),
                              child: const Text('W'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _mobileSelectWeekDays(WeekDays.thursday);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(7, 7),
                                disabledForegroundColor: Colors.black26,
                                disabledBackgroundColor: Colors.black26,
                                backgroundColor:
                                    _days!.contains(WeekDays.thursday)
                                        ? const Color(0xff4169e1)
                                        : defaultButtonColor,
                                foregroundColor:
                                    _days!.contains(WeekDays.thursday)
                                        ? Colors.white
                                        : defaultTextColor,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Text('T'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _mobileSelectWeekDays(WeekDays.friday);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(7, 7),
                                disabledForegroundColor: Colors.black26,
                                disabledBackgroundColor: Colors.black26,
                                backgroundColor:
                                    _days!.contains(WeekDays.friday)
                                        ? const Color(0xff4169e1)
                                        : defaultButtonColor,
                                foregroundColor:
                                    _days!.contains(WeekDays.friday)
                                        ? Colors.white
                                        : defaultTextColor,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Text('F'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _mobileSelectWeekDays(WeekDays.saturday);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(7, 7),
                                disabledForegroundColor: Colors.black26,
                                disabledBackgroundColor: Colors.black26,
                                backgroundColor:
                                    _days!.contains(WeekDays.saturday)
                                        ? const Color(0xff4169e1)
                                        : defaultButtonColor,
                                foregroundColor:
                                    _days!.contains(WeekDays.saturday)
                                        ? Colors.white
                                        : defaultTextColor,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12),
                              ),
                              child: const Text('S'),
                            ),
                          ],
                        )),
                    const Divider(
                      thickness: 1,
                    ),
                  ],
                )),
            Visibility(
              visible: _selectedRecurrenceType == 'month',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 40,
                    width: _width,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    margin: const EdgeInsets.all(15),
                    child: DropdownButton<String>(
                        focusColor: Colors.transparent,
                        isExpanded: true,
                        underline: Container(),
                        style: TextStyle(
                            fontSize: 13,
                            color: defaultTextColor,
                            fontWeight: FontWeight.w400),
                        value: _monthlyRule,
                        items: <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: 'Monthly on day ' +
                                _startDate.day.toString() +
                                'th',
                            child: Text('Monthly on day ' +
                                _startDate.day.toString() +
                                'th'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Monthly on the ' + _weekNumberDay!,
                            child: Text('Monthly on the ' + _weekNumberDay!),
                          ),
                          const DropdownMenuItem<String>(
                            value: 'Last day of month',
                            child: Text('Last day of month'),
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            if (value ==
                                'Monthly on day ' +
                                    _startDate.day.toString() +
                                    'th') {
                              _width = _textSize('Monthly on day ' +
                                  _startDate.day.toString() +
                                  'th');
                              _monthlyDay();
                            } else if (value ==
                                'Monthly on the ' + _weekNumberDay!) {
                              _width = _textSize(
                                  'Monthly on the ' + _weekNumberDay!);
                              _monthlyWeek();
                            } else if (value == 'Last day of month') {
                              _width = _textSize('Last day of month');
                              _lastDayOfMonth();
                            }
                          });
                        }),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: _selectedRecurrenceType == 'year',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Checkbox(
                    focusColor: const Color(0xff4169e1),
                    activeColor: const Color(0xff4169e1),
                    value: _isLastDay,
                    onChanged: (bool? value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _isLastDay = value;
                        _lastDayOfMonth();
                      });
                    },
                  ),
                  const Text(
                    'Last day of month',
                  ),
                ],
              ),
            ),
            if (_selectedRecurrenceType == 'year')
              const Divider(
                thickness: 1,
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(left: 15, top: 15),
                  child: Text('ENDS'),
                ),
                RadioListTile<_EndRule>(
                  contentPadding: const EdgeInsets.only(left: 7),
                  title: const Text('Never'),
                  value: _EndRule.never,
                  groupValue: _endRule,
                  activeColor: const Color(0xff4169e1),
                  onChanged: (_EndRule? value) {
                    setState(() {
                      _endRule = _EndRule.never;
                      _rangeNoEndDate();
                    });
                  },
                ),
                const Divider(
                  indent: 50,
                  height: 1.0,
                  thickness: 1,
                ),
                RadioListTile<_EndRule>(
                  contentPadding: const EdgeInsets.only(left: 7),
                  title: Row(
                    children: <Widget>[
                      const Text('On'),
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        width: 110,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: ButtonTheme(
                            minWidth: 30.0,
                            child: MaterialButton(
                                elevation: 0,
                                focusElevation: 0,
                                highlightElevation: 0,
                                disabledElevation: 0,
                                hoverElevation: 0,
                                onPressed: () async {
                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                          context: context,
                                          initialDate: _selectedDate,
                                          firstDate:
                                              _startDate.isBefore(_firstDate)
                                                  ? _startDate
                                                  : _firstDate,
                                          currentDate: _selectedDate,
                                          lastDate: DateTime(2050),
                                          builder: (BuildContext context,
                                              Widget? child) {
                                            return Theme(
                                              data: ThemeData(
                                                brightness: Brightness.light,
                                                colorScheme:
                                                    ColorScheme.fromSwatch(
                                                  backgroundColor:
                                                      const Color(0xff4169e1),
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          });
                                  if (pickedDate == null) {
                                    return;
                                  }
                                  setState(() {
                                    _endRule = _EndRule.endDate;
                                    _recurrenceProperties!.recurrenceRange =
                                        RecurrenceRange.endDate;
                                    _selectedDate = DateTime(pickedDate.year,
                                        pickedDate.month, pickedDate.day);
                                    _recurrenceProperties!.endDate =
                                        _selectedDate;
                                  });
                                },
                                shape: const CircleBorder(),
                                child: Text(
                                  DateFormat('MM/dd/yyyy')
                                      .format(_selectedDate),
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: defaultTextColor,
                                      fontWeight: FontWeight.w400),
                                ))),
                      ),
                    ],
                  ),
                  value: _EndRule.endDate,
                  groupValue: _endRule,
                  activeColor: const Color(0xff4169e1),
                  onChanged: (_EndRule? value) {
                    setState(() {
                      _endRule = value;
                      _rangeEndDate();
                    });
                  },
                ),
                const Divider(
                  indent: 50,
                  height: 1.0,
                  thickness: 1,
                ),
                SizedBox(
                  height: 40,
                  child: RadioListTile<_EndRule>(
                    contentPadding: const EdgeInsets.only(left: 7),
                    title: Row(
                      children: <Widget>[
                        const Text('After'),
                        Container(
                          height: 40,
                          width: 60,
                          padding: const EdgeInsets.only(left: 5, bottom: 10),
                          margin: const EdgeInsets.only(left: 5),
                          alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: TextField(
                            readOnly: _endRule != _EndRule.count,
                            controller: TextEditingController.fromValue(
                                TextEditingValue(
                                    text: _count.toString(),
                                    selection: TextSelection.collapsed(
                                        offset: _count.toString().length))),
                            cursorColor: const Color(0xff4169e1),
                            onTap: () {
                              setState(() {
                                _endRule = _EndRule.count;
                              });
                            },
                            onChanged: (String value) async {
                              if (value != null && value.isNotEmpty) {
                                _count = int.parse(value);
                                if (_count == 0) {
                                  _count = 1;
                                } else if (_count! >= 999) {
                                  setState(() {
                                    _count = 999;
                                  });
                                }
                              } else if (value.isEmpty || value == null) {
                                _count = 1;
                              }
                              _endRule = _EndRule.count;
                              _recurrenceProperties!.recurrenceRange =
                                  RecurrenceRange.count;
                              _recurrenceProperties!.recurrenceCount = _count!;
                            },
                            keyboardType: TextInputType.number,
                            // ignore: always_specify_types
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: TextStyle(
                                fontSize: 13,
                                color: defaultTextColor,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                          ),
                        ),
                        Container(
                          width: 10,
                        ),
                        const Text('occurrence'),
                      ],
                    ),
                    value: _EndRule.count,
                    groupValue: _endRule,
                    activeColor: const Color(0xff4169e1),
                    onChanged: (_EndRule? value) {
                      setState(() {
                        _endRule = value;
                        _recurrenceProperties!.recurrenceRange =
                            RecurrenceRange.count;
                        _recurrenceProperties!.recurrenceCount = _count!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSwatch(
            backgroundColor: const Color(0xff4169e1),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Custom Recurrence'),
            backgroundColor: widget.appointmentColor,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, widget.recurrenceProperties);
              },
            ),
            actions: <Widget>[
              IconButton(
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  icon: const Icon(
                    Icons.done,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context, _recurrenceProperties);
                  })
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: Stack(
              children: <Widget>[
                _getCustomRule(context, (Colors.white), Colors.black87)
              ],
            ),
          ),
        ));
  }
}

bool _canAddRecurrenceAppointment(
    List<DateTime> visibleDates,
    CalendarDataSource dataSource,
    Appointment occurrenceAppointment,
    DateTime startTime) {
  final Appointment parentAppointment = dataSource.getPatternAppointment(
      occurrenceAppointment, '')! as Appointment;
  final List<DateTime> recurrenceDates =
      SfCalendar.getRecurrenceDateTimeCollection(
          parentAppointment.recurrenceRule ?? '', parentAppointment.startTime,
          specificStartDate: visibleDates[0],
          specificEndDate: visibleDates[visibleDates.length - 1]);

  for (int i = 0; i < dataSource.appointments!.length; i++) {
    final Appointment calendarApp = dataSource.appointments![i] as Appointment;
    if (calendarApp.recurrenceId != null &&
        calendarApp.recurrenceId == parentAppointment.id) {
      recurrenceDates.add(calendarApp.startTime);
    }
  }

  if (parentAppointment.recurrenceExceptionDates != null) {
    for (int i = 0;
        i < parentAppointment.recurrenceExceptionDates!.length;
        i++) {
      recurrenceDates.remove(parentAppointment.recurrenceExceptionDates![i]);
    }
  }

  recurrenceDates.sort();
  bool canAddRecurrence =
      isSameDate(occurrenceAppointment.startTime, startTime);
  if (!_isDateInDateCollection(recurrenceDates, startTime)) {
    final int currentRecurrenceIndex =
        recurrenceDates.indexOf(occurrenceAppointment.startTime);
    if (currentRecurrenceIndex == 0 ||
        currentRecurrenceIndex == recurrenceDates.length - 1) {
      canAddRecurrence = true;
    } else if (currentRecurrenceIndex < 0) {
      canAddRecurrence = false;
    } else {
      final DateTime previousRecurrence =
          recurrenceDates[currentRecurrenceIndex - 1];
      final DateTime nextRecurrence =
          recurrenceDates[currentRecurrenceIndex + 1];
      canAddRecurrence = (isDateWithInDateRange(
                  previousRecurrence, nextRecurrence, startTime) &&
              !isSameDate(previousRecurrence, startTime) &&
              !isSameDate(nextRecurrence, startTime)) ||
          canAddRecurrence;
    }
  }

  return canAddRecurrence;
}

bool _isDateInDateCollection(List<DateTime>? dates, DateTime date) {
  if (dates == null || dates.isEmpty) {
    return false;
  }

  for (final DateTime currentDate in dates) {
    if (isSameDate(currentDate, date)) {
      return true;
    }
  }

  return false;
}
