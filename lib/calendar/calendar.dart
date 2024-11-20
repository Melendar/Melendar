import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_service.dart';
import 'firebase_event_data.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final EventService _eventService = EventService();
  final EventController _eventController = EventController();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (_currentUser != null) {
      List<FirebaseEventData> events =
          await _eventService.getEventsByUser(_currentUser!.uid);
      for (var event in events) {
        _eventController.add(
          CalendarEventData(
            title: event.title,
            date: event.date,
            event: event,
          ),
        );
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: _eventController,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _EventSearchDelegate(),
                );
              },
            ),
          ],
        ),
        body: MonthView(
          headerStyle:
              HeaderStyle(decoration: BoxDecoration(color: Colors.white)),
          weekDayStringBuilder: (p0) {
            List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];
            return weekDays[p0 % 7];
          },
          headerStringBuilder: (date, {secondaryDate}) {
            return DateFormat('yyyy-MM월').format(date);
          },
          useAvailableVerticalSpace: true,
          onCellTap: (events, date) {
            _showEventPopup(context, events, date);
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _showAddEventDialog(context),
        ),
      ),
    );
  }

  void _showEventPopup(BuildContext context,
      List<CalendarEventData<Object?>> events, DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(DateFormat('yyyy-MM-dd').format(date)),
          content: events.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: events
                      .map((event) => ListTile(
                            title: Text(event.title),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () =>
                                      _showUpdateEventDialog(context, event),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteEvent(event),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                )
              : Text("이 날짜에는 일정이 없습니다."),
          actions: <Widget>[
            TextButton(
              child: Text("닫기"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddEventDialog(BuildContext context) {
    String task = '';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('새 일정 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => task = value,
                decoration: InputDecoration(labelText: '일정'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('날짜 선택'),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate) {
                    selectedDate = picked;
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('추가'),
              onPressed: () async {
                if (task.isNotEmpty && _currentUser != null) {
                  await _eventService.createEvent(
                      _currentUser!.uid, task, selectedDate);
                  _loadEvents();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateEventDialog(
      BuildContext context, CalendarEventData<Object?> event) {
    String newTask = event.title;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('일정 수정'),
          content: TextField(
            onChanged: (value) => newTask = value,
            decoration: InputDecoration(labelText: '새 일정'),
            controller: TextEditingController(text: event.title),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('수정'),
              onPressed: () async {
                if (newTask.isNotEmpty && _currentUser != null) {
                  FirebaseEventData firebaseEvent =
                      event.event as FirebaseEventData;
                  await _eventService.updateEvent(
                      _currentUser!.uid, firebaseEvent.id, newTask);
                  _loadEvents();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(CalendarEventData<Object?> event) async {
    if (_currentUser != null) {
      FirebaseEventData firebaseEvent = event.event as FirebaseEventData;
      await _eventService.deleteEvent(_currentUser!.uid, firebaseEvent.id);
      _loadEvents();
    }
  }
}

class _EventSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('검색 결과: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text('검색어를 입력하세요'),
    );
  }
}
