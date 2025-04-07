import 'package:json_annotation/json_annotation.dart';

part 'case_model.g.dart';

@JsonSerializable()
class CaseModel {
  String id;
  final String topic;
  final String context;
  final String question;
  final int numberOfExamples;

  CaseModel({
    required this.id,
    required this.topic,
    required this.context,
    required this.question,
    required this.numberOfExamples,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) =>
      _$CaseModelFromJson(json);
  Map<String, dynamic> toJson() => _$CaseModelToJson(this);
}
