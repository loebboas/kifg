import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article_short_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ArticleShortModel {
  final String id;
  final String title;
  final String text;

  ArticleShortModel({
    required this.id,
    required this.title,
    required this.text,
  });

  factory ArticleShortModel.fromJson(Map<String, dynamic> json) =>
      _$ArticleShortModelFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleShortModelToJson(this);

  factory ArticleShortModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleShortModel.fromJson(data);
  }
}
