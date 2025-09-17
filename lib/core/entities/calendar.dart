import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/types/api_entity.dart';

part 'calendar.g.dart';

enum CalendarEventVisibility {
  all,
  ownStudents,
  allMentors,
  ownMentor,
  private,
}

enum CalendarEventType {
  studentDeadline,
  mentorDeadline,
  workChecked,
  workMade,
  event,
}

@JsonSerializable()
class CalendarEventEntity extends ApiEntity {
  final String title;
  final String description;
  final DateTime date;
  final CalendarEventVisibility visibility;
  final CalendarEventType type;
  final String? url;
  final String? username;

  CalendarEventEntity({
    required super.id,
    required super.createdAt,
    super.updatedAt,
    required this.title,
    required this.description,
    required this.date,
    required this.visibility,
    required this.type,
    this.url,
    this.username,
  });

  factory CalendarEventEntity.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventEntityFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarEventEntityToJson(this);
}
