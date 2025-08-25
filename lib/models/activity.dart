class Activity {
  final int articleId;
  final String category;
  final String activityAt;

  Activity({
    required this.articleId,
    required this.category,
    required this.activityAt,
  });

  // JSON 파싱
  factory Activity.fromJson(Map json) {
    return Activity(
      articleId: json['articleId'],
      category: json['category'],
      activityAt: json['activityAt'],
    );
  }
}
