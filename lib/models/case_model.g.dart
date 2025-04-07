// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CaseModel _$CaseModelFromJson(Map<String, dynamic> json) => CaseModel(
  id: json['id'] as String,
  topic: json['topic'] as String,
  context: json['context'] as String,
  question: json['question'] as String,
  numberOfExamples: (json['numberOfExamples'] as num).toInt(),
);

Map<String, dynamic> _$CaseModelToJson(CaseModel instance) => <String, dynamic>{
  'id': instance.id,
  'topic': instance.topic,
  'context': instance.context,
  'question': instance.question,
  'numberOfExamples': instance.numberOfExamples,
};
