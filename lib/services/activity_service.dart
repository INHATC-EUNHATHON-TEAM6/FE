import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity.dart';

class ActivityService {
  final String _baseUrl = 'https://yourapi.com/api/feedback/list';

  // accessToken은 로그인 시 받아 프로젝트 어딘가에 저장 or 인자로 전달
  Future<Map<int, List<Activity>>> fetchMonthActivities(
      int year, int month, String accessToken) async {
    // day는 월별 조회엔 필요없으니 생략 (필요하면 파라미터 추가)
    final url = '$_baseUrl?year=$year&month=$month';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final Map monthActivity = jsonBody['monthActivity'];
      Map<int, List<Activity>> result = {};
      monthActivity.forEach((day, list) {
        result[int.parse(day.toString())] = (list as List)
            .map((item) => Activity.fromJson(item))
            .toList();
      });
      return result;
    } else {
      throw Exception('스크랩 활동 데이터를 불러오지 못했습니다');
    }
  }
}
