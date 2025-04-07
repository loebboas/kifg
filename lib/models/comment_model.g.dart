// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) => CommentModel(
  id: json['id'] as String,
  parentId: json['parentId'] as String,
  caseTitle: json['caseTitle'] as String,
  exampleTitle: json['exampleTitle'] as String,
  answerId: json['answerId'] as String?,
  text: json['text'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  requiresTeacherResponse: json['requiresTeacherResponse'] as bool? ?? false,
  resolved: json['resolved'] as bool? ?? false,
  timestamp: DateTime.parse(json['timestamp'] as String),
  upvotes:
      (json['upvotes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  downvotes:
      (json['downvotes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$CommentModelToJson(CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentId': instance.parentId,
      'caseTitle': instance.caseTitle,
      'exampleTitle': instance.exampleTitle,
      'answerId': instance.answerId,
      'text': instance.text,
      'userId': instance.userId,
      'userName': instance.userName,
      'timestamp': instance.timestamp.toIso8601String(),
      'requiresTeacherResponse': instance.requiresTeacherResponse,
      'resolved': instance.resolved,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
    };
