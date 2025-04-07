import 'package:json_annotation/json_annotation.dart';

part 'answer_feedback_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AnswerFeedbackModel {
  final String answerId;
  final double score;
  final List<String> positives;
  final List<String> negatives;
  final DateTime timestamp;
  final String feedback;

  AnswerFeedbackModel({
    required this.answerId,
    required this.score,
    required this.positives,
    required this.negatives,
    required this.timestamp,
    required this.feedback,
  });

  factory AnswerFeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerFeedbackModelFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerFeedbackModelToJson(this);
}
