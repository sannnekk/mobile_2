import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/entities/enum_helpers.dart';
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
  @JsonKey(fromJson: _dateFromJson)
  final DateTime date;
  final CalendarEventVisibility visibility;
  @JsonKey(fromJson: eventTypeFromJson, toJson: eventTypeToJson)
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

  static DateTime _dateFromJson(String dateString) {
    final utcDate = DateTime.parse(dateString);
    // If the parsed date is in UTC (has 'Z' suffix or +00:00), convert to local
    if (dateString.endsWith('Z') || dateString.contains('+00:00')) {
      return utcDate.toLocal();
    }
    // Otherwise, assume it's already in local time
    return utcDate;
  }

  static String eventTypeToJson(CalendarEventType type) => enumToString(type);

  static CalendarEventType eventTypeFromJson(String type) =>
      enumFromString(CalendarEventType.values, type);
}
