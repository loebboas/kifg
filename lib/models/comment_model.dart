import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comment_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CommentModel {
  final String id;
  final String parentId; // caseExampleId
  final String caseTitle;
  final String exampleTitle;
  final String? answerId;
  final String text;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final bool requiresTeacherResponse;
  bool resolved;
  final List<String>? upvotes; // List of user IDs who upvoted
  final List<String>? downvotes; // List of user IDs who downvoted

  CommentModel({
    required this.id,
    required this.parentId,
    required this.caseTitle,
    required this.exampleTitle,
    this.answerId,
    required this.text,
    required this.userId,
    required this.userName,
    this.requiresTeacherResponse = false,
    this.resolved = false,
    required this.timestamp,
    this.upvotes = const [],
    this.downvotes = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommentModelToJson(this);

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel.fromJson({...data, 'id': doc.id});
  }
}
