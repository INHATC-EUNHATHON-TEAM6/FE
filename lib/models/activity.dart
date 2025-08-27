class Activity {
  final int articleId;
  final String category;
  final DateTime activityAt;

  Activity({
    required this.articleId,
    required this.category,
    required this.activityAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      articleId: json['articleId'] as int,
      category: json['category'] as String,
      activityAt: DateTime.parse(json['activityAt'] as String),
    );
  }
}