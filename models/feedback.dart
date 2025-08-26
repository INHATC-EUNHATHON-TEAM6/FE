class FeedbackDto {
  final String activityType;
  final String userAnswer;
  final String aiAnswer;
  final String aiFeedback;
  final String evaluationScore;

  FeedbackDto({
    required this.activityType,
    required this.userAnswer,
    required this.aiAnswer,
    required this.aiFeedback,
    required this.evaluationScore,
  });

  factory FeedbackDto.fromJson(Map<String, dynamic> json) {
    return FeedbackDto(
      activityType: json['activityType'] ?? '',
      userAnswer: json['userAnswer'] ?? '',
      aiAnswer: json['aiAnswer'] ?? '',
      aiFeedback: json['aiFeedback'] ?? '',
      evaluationScore: json['evaluationScore'] ?? '',
    );
  }
}

class FeedbacksDto {
  final String articleBody;
  final String categoryName;
  final List<FeedbackDto> feedbacks;

  FeedbacksDto({
    required this.articleBody,
    required this.categoryName,
    required this.feedbacks,
  });

  factory FeedbacksDto.fromJson(Map<String, dynamic> json) {
    var feedbackList = (json['feedbacks'] as List<dynamic>?)
        ?.map((item) => FeedbackDto.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];
    return FeedbacksDto(
      articleBody: json['articleBody'] ?? '',
      categoryName: json['categoryName'] ?? '',
      feedbacks: feedbackList,
    );
  }
}
