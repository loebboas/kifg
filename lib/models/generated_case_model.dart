import 'package:json_annotation/json_annotation.dart';

part 'generated_case_model.g.dart';

@JsonSerializable()
class GeneratedCaseModel {
  final String title;
  final String description;
  final String? answerShort;
  final String? answerLong;
  final String parentId;

  GeneratedCaseModel({
    required this.title,
    required this.description,
    required this.parentId,
    this.answerShort,
    this.answerLong,
  });

  factory GeneratedCaseModel.fromJson(Map<String, dynamic> json) =>
      _$GeneratedCaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedCaseModelToJson(this);
}
