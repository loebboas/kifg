import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'case_example_model.g.dart';

@JsonSerializable()
class CaseExampleModel {
  final String? id; // nullable, to distinguish new vs. saved
  final String title;
  final String description;
  final String? expectations;
  final String? answer;
  final String parentId;
  final List<String> upvotes;
  final List<String> downvotes;

  CaseExampleModel({
    this.id,
    required this.title,
    required this.description,
    required this.parentId,
    this.answer,
    this.expectations,
    this.upvotes = const [],
    this.downvotes = const [],
  });

  factory CaseExampleModel.fromJson(Map<String, dynamic> json) =>
      _$CaseExampleModelFromJson(json);

  Map<String, dynamic> toJson() => _$CaseExampleModelToJson(this);

  factory CaseExampleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CaseExampleModel.fromJson({...data, 'id': doc.id});
  }
}
