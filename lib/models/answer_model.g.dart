// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnswerModel _$AnswerModelFromJson(Map<String, dynamic> json) => AnswerModel(
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  text: json['text'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  feedback: json['feedback'] as String,
);

Map<String, dynamic> _$AnswerModelToJson(AnswerModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'text': instance.text,
      'timestamp': instance.timestamp.toIso8601String(),
      'feedback': instance.feedback,
    };
