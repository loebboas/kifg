// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_case_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneratedCaseModel _$GeneratedCaseModelFromJson(Map<String, dynamic> json) =>
    GeneratedCaseModel(
      title: json['title'] as String,
      description: json['description'] as String,
      parentId: json['parentId'] as String,
      answerShort: json['answerShort'] as String?,
      answerLong: json['answerLong'] as String?,
    );

Map<String, dynamic> _$GeneratedCaseModelToJson(GeneratedCaseModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'answerShort': instance.answerShort,
      'answerLong': instance.answerLong,
      'parentId': instance.parentId,
    };
