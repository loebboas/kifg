// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  email: json['email'] as String,
  creationDate: DateTime.parse(json['creationDate'] as String),
  isTeacher: json['isTeacher'] as bool? ?? false,
)..points = (json['points'] as num?)?.toInt();

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'email': instance.email,
  'creationDate': instance.creationDate.toIso8601String(),
  'isTeacher': instance.isTeacher,
  'points': instance.points,
};
