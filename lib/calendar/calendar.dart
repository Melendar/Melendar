import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_manage/user_provider.dart';
import '../service/event_service.dart';
import 'firebase_event_data.dart';
import 'package:provider/provider.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final EventService _eventService = EventService();
  final EventController _eventController = EventController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.uid;
    if (userId != null) {
      _eventController.removeWhere((element) => true);
      List<FirebaseEventData> events = await _eventService.getEventsByUser(userId);
      for (var event in events) {
        _eventController.add(
          CalendarEventData(
            title: event.title,
            date: event.date,
            event: event,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: _eventController,
      child: Scaffold(
        appBar: AppBar(
          leading: 
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _loadEvents();
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: _EventSearchDelegate(_eventController),
                );
              },
            ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('오류 발생: $_error'))
                : MonthView(
                    headerStyle: HeaderStyle(decoration: BoxDecoration(color: Colors.white)),
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
                    onEventTap: (event, date) {
                      _showEventPopup(context, [event], date);
                    },
                  ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => _showAddEventDialog(context),
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    String task = '';
    DateTime selectedDate = DateTime.now();
    String? selectedGroupId;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groups = userProvider.groups;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('새 일정 추가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) => task = value,
                    decoration: InputDecoration(labelText: '일정'),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
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
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedGroupId,
                    hint: Text('그룹 선택'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroupId = newValue;
                      });
                    },
                    items: groups.map<DropdownMenuItem<String>>((group) {
                      return DropdownMenuItem<String>(
                        value: group['group_id'],
                        child: Text(group['group_name']),
                      );
                    }).toList(),
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
                    if (task.isNotEmpty && selectedGroupId != null) {
                      await _eventService.createEvent(selectedGroupId!, task, selectedDate);
                      await _loadEvents();
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEventPopup(BuildContext context, List<CalendarEventData<Object?>> events, DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(DateFormat('yyyy-MM-dd').format(date)),
              content: FutureBuilder(
                future: _loadEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    events = _eventController.getEventsOnDay(date);
                    return events.isNotEmpty
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: events.map((event) => ListTile(
                              title: Text(event.title),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _showUpdateEventDialog(context, event),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      await _deleteEvent(event);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            )).toList(),
                          )
                        : Text("이 날짜에는 일정이 없습니다.");
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
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
      },
    );
  }

  void _showUpdateEventDialog(BuildContext context, CalendarEventData<Object?> event) {
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
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('수정'),
              onPressed: () async {
                if (newTask.isNotEmpty) {
                  FirebaseEventData firebaseEvent = event.event as FirebaseEventData;
                  await _eventService.updateEvent(firebaseEvent.groupId, firebaseEvent.id, newTask);
                  await _loadEvents();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  _showEventPopup(context, _eventController.getEventsOnDay(event.date), event.date);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvent(CalendarEventData<Object?> event) async {
    FirebaseEventData firebaseEvent = event.event as FirebaseEventData;
    await _eventService.deleteEvent(firebaseEvent.groupId, firebaseEvent.id);
    await _loadEvents();
  }
}

class _EventSearchDelegate extends SearchDelegate {
  final EventController eventController;

  _EventSearchDelegate(this.eventController);

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
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final events = eventController.events.where((event) {
      return event.title.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (query.isEmpty) {
      return Center(child: Text('검색어를 입력하세요'));
    }

    if (events.isEmpty) {
      return Center(child: Text('검색 결과가 없습니다.'));
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text(DateFormat('yyyy-MM-dd').format(event.date)),
          onTap: () {
            // 이벤트 상세 정보를 보여주거나 해당 날짜로 이동하는 등의 동작 추가
          },
        );
      },
    );
  }
}