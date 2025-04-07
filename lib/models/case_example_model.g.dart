// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_example_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaseExampleModel _$CaseExampleModelFromJson(
  Map<String, dynamic> json,
) => CaseExampleModel(
  id: json['id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String,
  parentId: json['parentId'] as String,
  answer: json['answer'] as String?,
  expectations: json['expectations'] as String?,
  upvotes:
      (json['upvotes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  downvotes:
      (json['downvotes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$CaseExampleModelToJson(CaseExampleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'expectations': instance.expectations,
      'answer': instance.answer,
      'parentId': instance.parentId,
      'upvotes': instance.upvotes,
      'downvotes': instance.downvotes,
    };
