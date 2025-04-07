import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'answer_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AnswerModel {
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;
  final String feedback;

  AnswerModel({
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
    required this.feedback,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerModelToJson(this);

  factory AnswerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnswerModel.fromJson({...data, 'id': doc.id});
  }
}
