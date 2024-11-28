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
    // 그룹 정보가 없는 상태에서 이벤트를 로드하면 그룹 색상을 가져올 수 없음 (캘린더에 일정 표시 안 되던 문제 생김)
    // 비동기 작업의 순서를 보장하기 위해 await 키워드 사용
    // 즉 작업 순서는 중요하단 소리! 그룹정보 가져오기도 전에 ui 그려버리면 아무것도 안 뜬다
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchGroups(); // 그룹 정보 먼저 로드
      await _loadEvents(); // 이벤트 로드
    });
  }

  Future<void> _loadEvents() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.uid;
    // userProvider.groups.isNotEmpty 체크를 통해 그룹 정보 로드 완료 보장
    if (userId != null && userProvider.groups.isNotEmpty) {
      _eventController.removeWhere((element) => true);
      List<FirebaseEventData> events =
          await _eventService.getEventsByUser(userId);
      for (var event in events) {
        // 선택된 그룹의 일정만 표시
        if (userProvider.isGroupSelected(event.groupId)) {
          Color eventColor = userProvider.getGroupColor(event.groupId);
          _eventController.add(
            CalendarEventData(
              title: event.title,
              date: event.date,
              event: event,
              color: eventColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: _eventController,
      child: Scaffold(
        endDrawer: _buildGroupFilterDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.white, // 상단바 색상을 흰색으로 설정
          title: Text("캘린더"),
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
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer(); // endDrawer 열기
                },
              ),
            ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('오류 발생: $_error'))
                : MonthView(
                    headerStyle: HeaderStyle(
                        decoration: BoxDecoration(color: Colors.white)),
                    weekDayStringBuilder: (p0) {
                      List<String> weekDays = [
                        '월',
                        '화',
                        '수',
                        '목',
                        '금',
                        '토',
                        '일'
                      ];
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
          backgroundColor: Colors.black,
          foregroundColor: Colors.white, // 아이콘 색상
// 배경색 검은색
          child: const Icon(Icons.add), // 아이콘 색상 흰색
          onPressed: () => _showAddEventDialog(context),
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, [DateTime? initialDate]) {
    String task = '';
    DateTime selectedDate = initialDate ?? DateTime.now(); // 선택된 날짜 사용
    String? selectedGroupId;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final groups = userProvider.groups;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white, // 배경 색상을 흰색으로 설정
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
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        builder: (BuildContext context, Widget? child) {
                          //showDatePicker(날짜선택 달력) 스타일 설정
                          return Theme(
                            data: Theme.of(context).copyWith(
                              dialogBackgroundColor:
                                  Colors.white, // 다이얼로그 배경을 흰색으로 설정
                              colorScheme: ColorScheme.light(
                                primary: Colors.purple, // 선택된 날짜의 강조 색상
                                onPrimary: Colors.white, // 선택된 날짜 텍스트 색상
                                onSurface: Colors.black, // 기본 텍스트 색상
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Colors.black, // "Cancel", "OK" 버튼 색상
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
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
                    dropdownColor: Colors.white, // 드롭다운 전체 배경색 설정
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroupId = newValue;
                      });
                    },
                    items: groups.map<DropdownMenuItem<String>>((group) {
                      return DropdownMenuItem<String>(
                        value: group['group_id'],
                        child: Text(
                          group['group_name'],
                          style: TextStyle(color: Colors.black), // 텍스트 색상 조정
                        ),
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
                      await _eventService.createEvent(
                          selectedGroupId!, task, selectedDate);
                      await _loadEvents();
                      Navigator.of(context).pop();
                      // 현재 표시된 모든 다이얼로그를 닫고 새로운 팝업 표시
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      _showEventPopup(
                          context,
                          _eventController.getEventsOnDay(selectedDate),
                          selectedDate);
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

  Widget _buildGroupFilterDrawer() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Colors.black),
                child: Center(
                  child: Text(
                    '그룹 필터',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
              ListTile(
                tileColor: Colors.white, // ListTile 배경색 흰색으로 설정
                title: Text('전체 선택'),
                trailing: IconButton(
                  icon: Icon(Icons.select_all),
                  onPressed: () {
                    userProvider.selectAllGroups();
                    _loadEvents();
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white, // 하단 리스트의 배경을 흰색으로 설정
                  child: ListView.builder(
                    itemCount: userProvider.groups.length,
                    itemBuilder: (context, index) {
                      final group = userProvider.groups[index];
                      final groupId = group['group_id'] as String;
                      return ListTile(
                        leading: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: userProvider.getGroupColor(groupId),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(group['group_name']),
                        trailing: Checkbox(
                          value: userProvider.isGroupSelected(groupId),
                          onChanged: (bool? value) {
                            userProvider.toggleGroupSelection(groupId);
                            _loadEvents();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEventPopup(BuildContext context,
      List<CalendarEventData<Object?>> events, DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white, // 배경 색상을 흰색으로 설정
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('yyyy-MM-dd').format(date)),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _showAddEventDialog(context, date),
                  ),
                ],
              ),
              content: FutureBuilder(
                future: _loadEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    events = _eventController.getEventsOnDay(date);
                    return events.isNotEmpty
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
                                                _showUpdateEventDialog(
                                                    context, event),
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
                                    ))
                                .toList(),
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

  void _showUpdateEventDialog(
      BuildContext context, CalendarEventData<Object?> event) {
    String newTask = event.title;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // 배경 색상을 흰색으로 설정
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
                  FirebaseEventData firebaseEvent =
                      event.event as FirebaseEventData;
                  await _eventService.updateEvent(
                      firebaseEvent.groupId, firebaseEvent.id, newTask);
                  await _loadEvents();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  _showEventPopup(context,
                      _eventController.getEventsOnDay(event.date), event.date);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvent(CalendarEventData<Object?> event) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // 배경 색상을 흰색으로 설정
          title: Text('일정 삭제'),
          content: Text('정말로 이 일정을 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('삭제'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      FirebaseEventData firebaseEvent = event.event as FirebaseEventData;
      await _eventService.deleteEvent(firebaseEvent.groupId, firebaseEvent.id);
      await _loadEvents();
    }
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
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: _buildSearchResults(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: _buildSearchResults(),
    );
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
            // 검색 결과를 눌렀을 때 동작 정의
          },
        );
      },
    );
  }
}
