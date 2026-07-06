import 'package:freezed_annotation/freezed_annotation.dart';

part 'university_model.freezed.dart';
part 'university_model.g.dart';

/// A university option shown in the login screen's dropdown.
///
/// Fed by `GET /universities`, which returns only universities that currently
/// have at least one login-eligible intern.
@freezed
abstract class University with _$University {
  const factory University({required int id, required String name}) =
      _University;

  factory University.fromJson(Map<String, dynamic> json) =>
      _$UniversityFromJson(json);
}
