// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnswerFeedbackModel _$AnswerFeedbackModelFromJson(Map<String, dynamic> json) =>
    AnswerFeedbackModel(
      answerId: json['answerId'] as String,
      score: (json['score'] as num).toDouble(),
      positives:
          (json['positives'] as List<dynamic>).map((e) => e as String).toList(),
      negatives:
          (json['negatives'] as List<dynamic>).map((e) => e as String).toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      feedback: json['feedback'] as String,
    );

Map<String, dynamic> _$AnswerFeedbackModelToJson(
  AnswerFeedbackModel instance,
) => <String, dynamic>{
  'answerId': instance.answerId,
  'score': instance.score,
  'positives': instance.positives,
  'negatives': instance.negatives,
  'timestamp': instance.timestamp.toIso8601String(),
  'feedback': instance.feedback,
};
