// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEventEntity _$CalendarEventEntityFromJson(Map<String, dynamic> json) =>
    CalendarEventEntity(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      visibility: $enumDecode(
        _$CalendarEventVisibilityEnumMap,
        json['visibility'],
      ),
      type: $enumDecode(_$CalendarEventTypeEnumMap, json['type']),
      url: json['url'] as String?,
      username: json['username'] as String?,
    );

Map<String, dynamic> _$CalendarEventEntityToJson(
  CalendarEventEntity instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'title': instance.title,
  'description': instance.description,
  'date': instance.date.toIso8601String(),
  'visibility': _$CalendarEventVisibilityEnumMap[instance.visibility]!,
  'type': _$CalendarEventTypeEnumMap[instance.type]!,
  'url': instance.url,
  'username': instance.username,
};

const _$CalendarEventVisibilityEnumMap = {
  CalendarEventVisibility.all: 'all',
  CalendarEventVisibility.ownStudents: 'ownStudents',
  CalendarEventVisibility.allMentors: 'allMentors',
  CalendarEventVisibility.ownMentor: 'ownMentor',
  CalendarEventVisibility.private: 'private',
};

const _$CalendarEventTypeEnumMap = {
  CalendarEventType.studentDeadline: 'studentDeadline',
  CalendarEventType.mentorDeadline: 'mentorDeadline',
  CalendarEventType.workChecked: 'workChecked',
  CalendarEventType.workMade: 'workMade',
  CalendarEventType.event: 'event',
};
