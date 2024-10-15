import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'event_repository.dart';

class Calendar extends StatefulWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    EventRepository eventRepo = EventRepository(); // 이벤트 저장소 인스턴스화

    return CalendarControllerProvider(
      controller: EventController()..addAll(eventRepo.getEvents()), // 일정 추가
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu), // 좌측에 메뉴 아이콘 버튼
            onPressed: () {
              // 메뉴 버튼 클릭 시 동작
              Scaffold.of(context).openDrawer(); // 사이드 메뉴를 여는 동작 추가 가능
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search), // 우측에 검색 아이콘 버튼
              onPressed: () {
                // 검색 버튼 클릭 시 동작
                showSearch(
                  context: context,
                  delegate: _EventSearchDelegate(), // 커스텀 검색 동작
                );
              },
            ),
          ],
        ),
        body: MonthView(
          headerStyle: HeaderStyle(decoration: BoxDecoration(color: Colors.white)),
          weekDayStringBuilder: (p0) {
            // 요일 리스트
            List<String> weekDays = ['월', '화', '수', '목', '금', '토', '일'];

            // p0에 해당하는 요일 반환 (p0가 0~6의 값으로 전달됨)
            return weekDays[p0 % 7]; // 인덱스는 0~6 사이여야 하므로 % 7을 사용
          },
          headerStringBuilder: (date, {secondaryDate}) {
            return DateFormat('yyyy-MM월').format(date);
          },
          useAvailableVerticalSpace: true, // 화면 크기에 맞게 확장
          onCellTap: (events, date) {
            _showEventPopup(context, events, date); // 날짜 터치 시 팝업을 띄움
          },
        ),
      ),
    );
  }

  // 이벤트를 보여주는 팝업
  void _showEventPopup(BuildContext context,
      List<CalendarEventData<Object?>> events, DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(DateFormat('yyyy-MM-dd').format(date)), // 팝업 제목에 날짜 표시
          content: events.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: events
                      .map((event) => Text(event.title))
                      .toList(), // 이벤트 목록 표시
                )
              : Text("이 날짜에는 일정이 없습니다."), // 일정이 없을 경우 표시
          actions: <Widget>[
            TextButton(
              child: Text("닫기"),
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
            ),
          ],
        );
      },
    );
  }
}

// 검색 기능을 위한 간단한 SearchDelegate
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
    // 검색 결과 표시 로직
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
