import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/activity.dart';

class ActivityService {
  ActivityService(this._client, {required this.baseUrl});

  final http.Client _client;
  final String baseUrl;

  void close() => _client.close();

  Future<Map<int, List<Activity>>> fetchMonthActivities({
    required int year,
    required int month,
    int? day,
    required String accessToken,
  }) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      'year': '$year',
      'month': '$month',
      if (day != null) 'day': '$day',
    });

    final resp = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    final ct = resp.headers['content-type'] ?? '';
    debugPrint('[ACTIVITY] GET $uri → ${resp.statusCode} $ct');

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} ($ct): ${_peek(resp.body)}');
    }
    if (!ct.contains('json')) {
      throw FormatException('Non-JSON ($ct): ${_peek(resp.body)}');
    }
    return compute(_parseMonthActivities, resp.body);
  }

  String _peek(String s, [int n = 150]) =>
      s.length <= n ? s : s.substring(0, n);

  Map<int, List<Activity>> _parseMonthActivities(String body) {
    final Map<String, dynamic> root = json.decode(body) as Map<String, dynamic>;
    final Map<String, dynamic> monthActivity =
    root['monthActivity'] as Map<String, dynamic>;

    final result = <int, List<Activity>>{};
    for (final e in monthActivity.entries) {
      final day = int.parse(e.key);
      final list = (e.value as List)
          .map((x) => Activity.fromJson(x as Map<String, dynamic>))
          .toList(growable: false);
      result[day] = list;
    }
    return result;
  }


}
// import 'dart:convert';
// import 'package:flutter/foundation.dart'; // compute
// import 'package:http/http.dart' as http;
// import '../models/activity.dart';
//
// class ActivityService {
//   ActivityService(this._client, {required this.baseUrl});
//
//   final http.Client _client;
//   final String baseUrl; // e.g. 'https://yourapi.com/api/feedback/list'
//
//   Future<Map<int, List<Activity>>> fetchMonthActivities({
//     required int year,
//     required int month,
//     required int day,
//     required String accessToken,
//   }) async {
//     final uri = Uri.parse(baseUrl).replace(queryParameters: {
//       'year': '$year',
//       'month': '$month',
//       'day' : '$day',
//     });
//
//     final response = await _client
//         .get(
//       uri,
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         'Accept': 'application/json',
//       },
//     )
//         .timeout(const Duration(seconds: 10));
//
//     if (response.statusCode != 200) {
//       throw Exception('활동 조회 실패: ${response.statusCode} ${response.body}');
//     }
//
//     // 무거운 파싱은 별도 아이솔레이트에서
//     return compute(parseMonthActivities, response.body);
//   }
// }
//
// // 반드시 탑레벨 함수여야 compute 사용 가능
// Map<int, List<Activity>> parseMonthActivities(String body) {
//   final Map<String, dynamic> root = json.decode(body) as Map<String, dynamic>;
//   final Map<String, dynamic> monthActivity =
//   root['monthActivity'] as Map<String, dynamic>;
//
//   final result = <int, List<Activity>>{};
//   for (final entry in monthActivity.entries) {
//     final day = int.parse(entry.key); // 키가 "1","2" 같은 문자열일 때 대비
//     final list = (entry.value as List)
//         .map((e) => Activity.fromJson(e as Map<String, dynamic>))
//         .toList(growable: false);
//     result[day] = list;
//   }
//   return result;
// }