import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity.dart';

class ActivityService {
  ActivityService(this._client, {required this.baseUrl});

  final http.Client _client;
  final String baseUrl; // 예: "http://43.202.149.234:8080/api/feedback/list"

  void close() => _client.close();

  Future<Map<int, List<Activity>>> fetchMonthActivities({
    required int year,
    required int month,
    required int day,                 // ✅ 필수로 변경
    required String accessToken,
  }) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: {
      'year': '$year',
      'month': '$month',
      'day': '$day',                  // ✅ 항상 포함
    });

    final resp = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken', // ✅ Spring Security 표준
        'Accept': 'application/json',
      },
    );

    final ct = resp.headers['content-type'] ?? '';
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} ($ct): ${_peek(resp.body)}');
    }
    if (!ct.toLowerCase().contains('json')) {
      throw FormatException('Non-JSON ($ct): ${_peek(resp.body)}');
    }

    // 메인 isolate에서 파싱 (전역 함수로 빼도 OK)
    return _parseMonthActivitiesFlexible(resp.body);
  }

  String _peek(String s, [int n = 200]) => s.length <= n ? s : s.substring(0, n);
}

/// 백엔드가 아래 둘 중 아무거나 내려줘도 파싱되도록 유연 처리:
///  A) {"25":[{...}], "26":[...]}            // 컨트롤러의 Map 그대로
///  B) {"monthActivity":{"25":[...], ...}}   // (이전 프론트 기대 형식)
Map<int, List<Activity>> _parseMonthActivitiesFlexible(String body) {
  final decoded = json.decode(body);

  if (decoded is! Map) return <int, List<Activity>>{};

  // B 형식 지원
  final root = (decoded['monthActivity'] is Map) ? decoded['monthActivity'] as Map : decoded;

  final result = <int, List<Activity>>{};
  for (final entry in root.entries) {
    final key = entry.key;
    final val = entry.value;

    // 키를 day(int)로 변환
    final day = int.tryParse(key.toString());
    if (day == null) continue;

    final list = (val as List?)
        ?.whereType<Map>()
        .map((e) => Activity.fromJson(e.cast<String, dynamic>()))
        .toList(growable: false) ??
        const <Activity>[];

    result[day] = list;
  }
  return result;
}
// // services/activity_service.dart
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import '../models/activity.dart';
//
// class ActivityService {
//   ActivityService(this._client, {required this.baseUrl});
//
//   final http.Client _client;
//   final String baseUrl; // 예: 'http://43.202.149.234:8080/api/feedback/list'
//
//   void close() => _client.close();
//
//   /// 월(및 선택적 일) 활동 조회
//   Future<Map<int, List<Activity>>> fetchMonthActivities({
//     required int year,
//     required int month,
//     required int day,
//     required String accessToken,
//   }) async {
//     final uri = Uri.parse(baseUrl).replace(queryParameters: {
//       'year': '$year',
//       'month': '$month',
//       if (day != null) 'day': '$day',
//     });
//
//     final resp = await http.get(
//       uri,
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//         // 'Accept': 'application/json',
//         // 'User-Agent': 'words_hanjoom/1.0 (Flutter http)',
//       },
//     )
//         .timeout(const Duration(seconds: 12));
//
//     final ct = resp.headers['content-type'] ?? '';
//     debugPrint('[ACTIVITY] GET $uri → ${resp.statusCode} $ct');
//
//     if (resp.statusCode != 200) {
//       throw Exception('HTTP ${resp.statusCode} ($ct): ${_peek(resp.body)}');
//     }
//     if (!_looksLikeJson(ct)) {
//       throw FormatException('Non-JSON ($ct): ${_peek(resp.body)}');
//     }
//
//     // 메인 isolate에서 바로 파싱(안전 파서)
//     return _parseMonthActivities(resp.body);
//   }
//
//   // ---------- 내부 헬퍼 ----------
//
//   // Content-Type이 application/json 또는 */*+json 인지 대충이라도 확인
//   bool _looksLikeJson(String ct) {
//     final lower = ct.toLowerCase();
//     return lower.contains('application/json') || lower.contains('+json');
//   }
//
//   String _peek(String s, [int n = 180]) => s.length <= n ? s : s.substring(0, n);
//
//   /// 안전 파서: monthActivity가 null/누락이어도 빈 맵 반환
//   Map<int, List<Activity>> _parseMonthActivities(String body) {
//     dynamic decoded;
//     try {
//       decoded = json.decode(body);
//     } on FormatException catch (e) {
//       throw FormatException('JSON decode 실패: ${e.message}. body=${_peek(body)}');
//     }
//
//     if (decoded is! Map) return <int, List<Activity>>{};
//
//     // 서버가 { data: {...} } 로 감싸는 경우까지 처리
//     final root = (decoded['data'] is Map) ? decoded['data'] as Map : decoded;
//
//     final raw = root;
//     // if (raw == null) return <int, List<Activity>>{};
//     // if (raw is! Map) {
//     //   throw const FormatException('`monthActivity`는 Map이어야 합니다.');
//     // }
//
//     final result = <int, List<Activity>>{};
//     raw.forEach((k, v) {
//       final day = int.tryParse(k.toString());
//       if (day == null) return;
//
//       final list = (v as List?)
//           ?.whereType<Map>()
//           .map((e) => Activity.fromJson(e.cast<String, dynamic>()))
//           .toList(growable: false) ??
//           const <Activity>[];
//
//       result[day] = list;
//     });
//
//     print(result);
//     return result;
//   }
// }
//
//
//
// // import 'dart:convert';
// // import 'package:flutter/foundation.dart';
// // import 'package:http/http.dart' as http;
// // import '../models/activity.dart';
// //
// // class ActivityService {
// //   ActivityService(this._client, {required this.baseUrl});
// //
// //   final http.Client _client;
// //   final String baseUrl;
// //
// //   void close() => _client.close();
// //
// //   Map<int, List<Activity>> _parseMonthActivities(String body) {
// //     final Map<String, dynamic> root = json.decode(body) as Map<String, dynamic>;
// //     final Map<String, dynamic> monthActivity =
// //     root['monthActivity'] as Map<String, dynamic>;
// //
// //     final result = <int, List<Activity>>{};
// //     for (final e in monthActivity.entries) {
// //       final day = int.parse(e.key);
// //       final list = (e.value as List)
// //           .map((x) => Activity.fromJson(x as Map<String, dynamic>))
// //           .toList(growable: false);
// //       result[day] = list;
// //     }
// //     return result;
// //   }
// //
// //   Future<Map<int, List<Activity>>> fetchMonthActivities({
// //     required int year,
// //     required int month,
// //     int? day,
// //     required String accessToken,
// //   }) async {
// //     final uri = Uri.parse(baseUrl).replace(queryParameters: {
// //       'year': '$year',
// //       'month': '$month',
// //       if (day != null) 'day': '$day',
// //     });
// //
// //     final resp = await _client.get(
// //       uri,
// //       headers: {
// //         'Authorization': 'Bearer $accessToken',
// //         'Accept': 'application/json',
// //       },
// //     );
// //
// //     final ct = resp.headers['content-type'] ?? '';
// //     debugPrint('[ACTIVITY] GET $uri → ${resp.statusCode} $ct');
// //
// //     if (resp.statusCode != 200) {
// //       throw Exception('HTTP ${resp.statusCode} ($ct): ${_peek(resp.body)}');
// //     }
// //     if (!ct.contains('json')) {
// //       throw FormatException('Non-JSON ($ct): ${_peek(resp.body)}');
// //     }
// //     final data = _parseMonthActivities(resp.body); // compute 없이
// //     return data;
// //   }
// //
// //   String _peek(String s, [int n = 150]) =>
// //       s.length <= n ? s : s.substring(0, n);
// //
// //
// // }