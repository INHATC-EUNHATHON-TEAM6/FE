import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../widgets/modal_widget.dart';

class RecordPage extends StatefulWidget {
  final String accessToken;
  const RecordPage({super.key, required this.accessToken});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

void _showMainMenuDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => ConfirmDialog(
      message: '메인메뉴로 이동합니다.',
      onYes: () {
        Navigator.of(context).pop(); // 다이얼로그 닫기
        Navigator.of(context).pop(); // 메인화면 등으로 이동 로직 추가
      },
      onNo: () => Navigator.of(context).pop(),
    ),
  );
}

class _RecordPageState extends State<RecordPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;
  Map<int, List<Activity>> _calendarData = {};
  bool _isLoading = false;
  late final ActivityService _activityService;

  // @override
  // void initState() {
  //   super.initState();
  //   final now = DateTime.now();
  //   _focusedDay = now;
  //   _selectedDay = now;
  //   _initCalendar(now.year, now.month);
  // }

  @override
  void initState() {
    super.initState();
    _activityService = ActivityService(
      http.Client(),
      baseUrl: "http://43.202.149.234:8080/api/feedback/list",
    );

    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = now;
    _initCalendar(now.year, now.month, now.day);
  }

  /// 월이동‧스와이프 시 항상 1일로 포커싱!
  // void _initCalendar(int year, int month) async {
  //   setState(() => _isLoading = true);
  //   final data = await _activityService.fetchMonthActivities(
  //     year: year,
  //     month: month,
  //     accessToken: widget.accessToken,
  //   );
  // }

  // void _initCalendar(int year, int month, int day) async {
  //   if (!mounted) return;
  //   setState(() => _isLoading = true);
  //   try {
  //     final data = await _activityService.fetchMonthActivities(
  //       year: year,
  //       month: month,
  //       day: day,
  //       accessToken: widget.accessToken,
  //     );
  //     if (!mounted) return;
  //     setState(() {
  //       _currentYear = year;
  //       _currentMonth = month;
  //       _selectedDay = DateTime(year, month, 1);
  //       _focusedDay  = DateTime(year, month, 1);
  //       _calendarData = data;        // ✅ 데이터 반영
  //     });
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('활동 불러오기 실패: $e')),
  //     );
  //     print(e);
  //   } finally {
  //     if (!mounted) return;
  //     setState(() => _isLoading = false);  // ✅ 로딩 해제
  //   }
  // }

  void _initCalendar(int year, int month, int day) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _activityService.fetchMonthActivities(
        year: year,
        month: month,
        day: day, // ← day 전달(백엔드가 무시해도 OK)
        accessToken: widget.accessToken,
      );
      if (!mounted) return;
      setState(() {
        _currentYear = year;
        _currentMonth = month;
        _selectedDay = DateTime(year, month, day); // ← day 반영
        _focusedDay = DateTime(year, month, day);
        _calendarData = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('활동 불러오기 실패: $e')));
      // 콘솔에서도 상위 몇 글자 확인 가능
      // print(e);
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _goNextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentYear += 1;
        _currentMonth = 1;
      } else {
        _currentMonth += 1;
      }
      _focusedDay = DateTime(_currentYear, _currentMonth, 1);
      _selectedDay = _focusedDay;
    });
    _initCalendar(_currentYear, _currentMonth, 1); // 데이터 로드
  }

  void _goPrevMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentYear -= 1;
        _currentMonth = 12;
      } else {
        _currentMonth -= 1;
      }
      _focusedDay = DateTime(_currentYear, _currentMonth, 1);
      _selectedDay = _focusedDay;
    });
    _initCalendar(_currentYear, _currentMonth, 1); // 데이터 로드
  }

  Future<void> _fetchForDay(DateTime day) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _activityService.fetchMonthActivities(
        year: day.year,
        month: day.month,
        day: day.day, // ← 선택한 날짜 전달 (백엔드 day 필수)
        accessToken: widget.accessToken,
      );
      if (!mounted) return;
      setState(() {
        _currentYear = day.year;
        _currentMonth = day.month;
        _selectedDay = day;
        _focusedDay = day;
        _calendarData = data; // ← 새 데이터 반영
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('활동 불러오기 실패: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<Activity> get _selectedActivities =>
      _calendarData[_selectedDay.day] ?? [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF733E17),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 22, bottom: 8),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                            onPressed: () => _showMainMenuDialog(context),
                          ),
                        ),
                        const Text(
                          '스크랩 활동 기록',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: 'Jalnan2',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBFAF3),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: Column(
                          children: [
                            // 달력 카드
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16,
                                bottom: 8,
                              ),
                              child: Container(
                                width: double.infinity,
                                height: 375,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.13),
                                      blurRadius: 10,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // 헤더 with 화살표
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 26.2,
                                        vertical: 13.1,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            splashRadius: 18,
                                            icon: const Icon(
                                              Icons.arrow_back_ios_rounded,
                                              size: 19.7,
                                              color: Color(0xFF733E17),
                                            ),
                                            onPressed: _goPrevMonth,
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                '${_currentYear}년 ${_currentMonth}월',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontFamily: 'Jalnan2',
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF733E17),
                                                ),
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            splashRadius: 18,
                                            icon: const Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 19.7,
                                              color: Color(0xFF733E17),
                                            ),
                                            onPressed: _goNextMonth,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 0.85,
                                      color: const Color(0xffBDBDBD),
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: TableCalendar(
                                        locale: 'ko_KR',
                                        firstDay: DateTime.utc(2020),
                                        lastDay: DateTime.utc(2030),
                                        focusedDay: _focusedDay,
                                        selectedDayPredicate: (d) =>
                                            d.year == _selectedDay.year &&
                                            d.month == _selectedDay.month &&
                                            d.day == _selectedDay.day,
                                        onDaySelected: (selected, focused) {
                                          // 같은 날짜를 또 탭해도 중복 호출 안 하도록 가드
                                          if (isSameDay(
                                            selected,
                                            _selectedDay,
                                          )) {
                                            setState(() {
                                              _selectedDay = selected;
                                              _focusedDay = focused;
                                            });
                                            return;
                                          }
                                          _fetchForDay(
                                            selected,
                                          ); // ← 날짜 탭 시 API 재호출
                                        },
                                        onPageChanged: (focusedDay) {
                                          _initCalendar(
                                            focusedDay.year,
                                            focusedDay.month,
                                            focusedDay.day,
                                          );
                                        },
                                        eventLoader: (day) =>
                                            (_calendarData[day.day] ?? [])
                                                .isNotEmpty
                                            ? ["활동"]
                                            : [],
                                        headerVisible: false,
                                        rowHeight: 41,
                                        daysOfWeekStyle: DaysOfWeekStyle(
                                          weekendStyle: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Noto Sans KR',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            height: 1,
                                            letterSpacing: 0.3,
                                          ),
                                          weekdayStyle: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Noto Sans KR',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            height: 1,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        calendarStyle: CalendarStyle(
                                          markersMaxCount: 0,
                                          defaultTextStyle: TextStyle(
                                            fontFamily: 'Noto Sans KR',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                          outsideTextStyle: TextStyle(
                                            fontFamily: 'Noto Sans KR',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: Colors.black.withOpacity(
                                              0.4,
                                            ),
                                          ),
                                        ),
                                        calendarBuilders: CalendarBuilders(
                                          defaultBuilder: (context, date, _) {
                                            final hasActivity =
                                                (_calendarData[date.day] ?? [])
                                                    .isNotEmpty;
                                            final isSelected = isSameDay(
                                              date,
                                              _selectedDay,
                                            );
                                            final isToday = isSameDay(
                                              date,
                                              DateTime.now(),
                                            );
                                            Color? bg;
                                            if (hasActivity &&
                                                !isSelected &&
                                                !isToday &&
                                                date.month == _currentMonth) {
                                              bg = const Color(0x33FF872F);
                                            }
                                            return _calendarCell(
                                              text: '${date.day}',
                                              color: isSelected || isToday
                                                  ? Colors.white
                                                  : Colors.black,
                                              background: isSelected
                                                  ? const Color(0xFF733E17)
                                                  : isToday
                                                  ? const Color(0xFFF7F8FA)
                                                  : bg ?? Colors.transparent,
                                              border: isToday && !isSelected
                                                  ? Border.all(
                                                      color: const Color(
                                                        0xFF733E17,
                                                      ),
                                                      width: 1.4,
                                                    )
                                                  : null,
                                            );
                                          },
                                          outsideBuilder: (context, date, _) {
                                            return _calendarCell(
                                              text: '${date.day}',
                                              color: Colors.black.withOpacity(
                                                0.4,
                                              ),
                                              background: Colors.transparent,
                                              border: null,
                                            );
                                          },
                                          selectedBuilder: (context, date, _) {
                                            return _calendarCell(
                                              text: '${date.day}',
                                              color: Colors.white,
                                              background: const Color(
                                                0xFF733E17,
                                              ),
                                              border: null,
                                            );
                                          },
                                          todayBuilder: (context, date, _) {
                                            final hasActivity =
                                                (_calendarData[date.day] ?? [])
                                                    .isNotEmpty;
                                            // 활동이 있으면 주황색 배경 + 갈색 테두리, 없으면 기존 스타일 적용
                                            return _calendarCell(
                                              text: '${date.day}',
                                              color: const Color(0xFF733E17),
                                              background: hasActivity
                                                  ? const Color(
                                                      0x33FF872F,
                                                    ) // ← 활동 있으면 주황색(불투명도 조정)
                                                  : const Color(
                                                      0xFFF7F8FA,
                                                    ), // 없으면 기존 밝은 배경
                                              border: Border.all(
                                                color: const Color(0xFF733E17),
                                                width: 1.4,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 오늘의 활동 카드
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              child: Container(
                                width: double.infinity,
                                height: 350,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.09),
                                      blurRadius: 10,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 24,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: const Color(0xFF733E17),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 9),
                                          const Text(
                                            '오늘의 활동',
                                            style: TextStyle(
                                              color: Color(0xFF733E17),
                                              fontFamily: 'Jalnan2',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              letterSpacing: 0.15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        DateFormat(
                                          'yyyy년 M월 d일',
                                          'ko_KR',
                                        ).format(_selectedDay),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'Noto Sans KR',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 22),
                                      Expanded(
                                        child: _selectedActivities.isEmpty
                                            ? Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0x14A1783F,
                                                        ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .sentiment_dissatisfied,
                                                        size: 29,
                                                        color: const Color(
                                                          0xFFA1783F,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 14),
                                                    const Text(
                                                      '오늘 한 활동이 없어요',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF364153,
                                                        ),
                                                        fontFamily:
                                                            'Noto Sans KR',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    const Text(
                                                      '새로운 스크랩 활동을 시작해보세요!',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Color(
                                                          0xFF6A7282,
                                                        ),
                                                        fontFamily:
                                                            'Noto Sans KR',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Scrollbar(
                                                thumbVisibility:
                                                    true, // ⬅︎ 스크롤바(선택)
                                                child: ListView.builder(
                                                  primary:
                                                      false, // ⬅︎ 부모 스크롤과 분리(카드 내부 전용 스크롤)
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(), // ⬅︎ 스크롤 활성화

                                                  // shrinkWrap: false 가 기본값 (고정 높이에 적합)
                                                  itemCount: _selectedActivities
                                                      .length,
                                                  itemBuilder: (context, index) {
                                                    final activity =
                                                        _selectedActivities[index];
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.symmetric(
                                                            vertical: 8,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                            vertical: 13,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              13,
                                                            ),
                                                        border: Border.all(
                                                          color: const Color(
                                                            0xFFECE7DC,
                                                          ),
                                                          width: 1.1,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${activity.category} · ${index + 1}번째 활동',
                                                            style: const TextStyle(
                                                              color: Color(
                                                                0xFF663813,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Noto Sans KR',
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            DateFormat(
                                                              'yyyy.MM.dd HH:mm',
                                                              'ko_KR',
                                                            ).format(
                                                              activity
                                                                  .activityAt
                                                                  .toLocal(),
                                                            ),
                                                            style: const TextStyle(
                                                              color: Color(
                                                                0xFF86837F,
                                                              ),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 12.5,
                                                              fontFamily:
                                                                  'Noto Sans KR',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Container(
        height: 32, // 원하는 높이로 조절
        color: const Color(0xFFFBFAF3), // 연한 베이지
      ),
    );
  }

  Widget _calendarCell({
    required String text,
    required Color color,
    required Color background,
    Border? border,
  }) {
    return Container(
      width: 34.5,
      height: 34.5,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Noto Sans KR',
          fontWeight: FontWeight.w600,
          fontSize: 15,
          height: 1.2,
        ).copyWith(color: color),
      ),
    );
  }
}
