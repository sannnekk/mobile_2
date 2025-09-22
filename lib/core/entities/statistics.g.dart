// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatisticsRequest _$StatisticsRequestFromJson(Map<String, dynamic> json) =>
    StatisticsRequest(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      type: StatisticsRequest.workTypeFromJson(json['type'] as String?),
    );

Map<String, dynamic> _$StatisticsRequestToJson(StatisticsRequest instance) =>
    <String, dynamic>{
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
      'type': _$WorkTypeEnumMap[instance.type],
    };

const _$WorkTypeEnumMap = {
  WorkType.test: 'test',
  WorkType.miniTest: 'miniTest',
  WorkType.phrase: 'phrase',
  WorkType.secondPart: 'secondPart',
  WorkType.trialWork: 'trialWork',
};

Statistics _$StatisticsFromJson(Map<String, dynamic> json) => Statistics(
  sections: (json['sections'] as List<dynamic>)
      .map((e) => StatisticsSection.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$StatisticsToJson(Statistics instance) =>
    <String, dynamic>{'sections': instance.sections};

StatisticsSection _$StatisticsSectionFromJson(Map<String, dynamic> json) =>
    StatisticsSection(
      name: json['name'] as String,
      description: json['description'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => StatisticsEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      plots: json['plots'] as List<dynamic>,
    );

Map<String, dynamic> _$StatisticsSectionToJson(StatisticsSection instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'entries': instance.entries,
      'plots': instance.plots,
    };

StatisticsEntry _$StatisticsEntryFromJson(Map<String, dynamic> json) =>
    StatisticsEntry(
      name: json['name'] as String,
      description: json['description'] as String?,
      value: json['value'] as num,
      percentage: json['percentage'] as num?,
      subEntries: (json['subEntries'] as List<dynamic>?)
          ?.map((e) => StatisticsSubEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StatisticsEntryToJson(StatisticsEntry instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'value': instance.value,
      'percentage': instance.percentage,
      'subEntries': instance.subEntries,
    };

StatisticsSubEntry _$StatisticsSubEntryFromJson(Map<String, dynamic> json) =>
    StatisticsSubEntry(
      name: json['name'] as String,
      description: json['description'] as String?,
      value: json['value'] as num,
      percentage: json['percentage'] as num?,
    );

Map<String, dynamic> _$StatisticsSubEntryToJson(StatisticsSubEntry instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'value': instance.value,
      'percentage': instance.percentage,
    };

Plot _$PlotFromJson(Map<String, dynamic> json) => Plot(
  name: json['name'] as String,
  color: Plot._plotColorFromJson(json['color'] as String),
  data: (json['data'] as List<dynamic>)
      .map((e) => PlotData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PlotToJson(Plot instance) => <String, dynamic>{
  'name': instance.name,
  'color': Plot._plotColorToJson(instance.color),
  'data': instance.data,
};

PlotData _$PlotDataFromJson(Map<String, dynamic> json) => PlotData(
  key: json['key'] as String,
  value: json['value'] as num,
  annotation: json['annotation'] as String?,
);

Map<String, dynamic> _$PlotDataToJson(PlotData instance) => <String, dynamic>{
  'key': instance.key,
  'value': instance.value,
  'annotation': instance.annotation,
};
