import 'package:json_annotation/json_annotation.dart';
import 'package:mobile_2/core/entities/enum_helpers.dart';

part 'statistics.g.dart';

enum PlotColor {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
  light,
  dark,
}

enum WorkType { test, miniTest, phrase, secondPart, trialWork }

@JsonSerializable()
class StatisticsRequest {
  final DateTime from;
  final DateTime to;
  @JsonKey(fromJson: StatisticsRequest.workTypeFromJson)
  final WorkType? type;

  StatisticsRequest({required this.from, required this.to, this.type});

  factory StatisticsRequest.fromJson(Map<String, dynamic> json) =>
      _$StatisticsRequestFromJson(json);

  Map<String, dynamic> toJson() {
    final map = {'from': from.toIso8601String(), 'to': to.toIso8601String()};
    if (type != null) {
      map['type'] = enumToString(type!);
    }
    return map;
  }

  static WorkType? workTypeFromJson(String? json) =>
      json != null ? enumFromString(WorkType.values, json) : null;

  static String? workTypeToJson(WorkType? type) =>
      type != null ? enumToString(type) : null;
}

@JsonSerializable()
class Statistics {
  final List<StatisticsSection> sections;

  Statistics({required this.sections});

  factory Statistics.fromJson(Map<String, dynamic> json) =>
      _$StatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$StatisticsToJson(this);
}

@JsonSerializable()
class StatisticsSection {
  final String name;
  final String description;
  final List<StatisticsEntry> entries;
  final List<dynamic> plots; // Can be Plot or List<Plot>

  StatisticsSection({
    required this.name,
    required this.description,
    required this.entries,
    required this.plots,
  });

  factory StatisticsSection.fromJson(Map<String, dynamic> json) {
    final plotsJson = json['plots'] as List<dynamic>;
    final plots = plotsJson.map((plotJson) {
      if (plotJson is Map<String, dynamic>) {
        // Single plot
        return Plot.fromJson(plotJson);
      } else if (plotJson is List) {
        // List of plots
        return plotJson
            .map((p) => Plot.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid plot format');
      }
    }).toList();

    return StatisticsSection(
      name: json['name'] as String,
      description: json['description'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => StatisticsEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      plots: plots,
    );
  }

  Map<String, dynamic> toJson() => _$StatisticsSectionToJson(this);
}

@JsonSerializable()
class StatisticsEntry {
  final String name;
  final String? description;
  final num value;
  final num? percentage;
  final List<StatisticsSubEntry>? subEntries;

  StatisticsEntry({
    required this.name,
    this.description,
    required this.value,
    this.percentage,
    this.subEntries,
  });

  factory StatisticsEntry.fromJson(Map<String, dynamic> json) =>
      _$StatisticsEntryFromJson(json);

  Map<String, dynamic> toJson() => _$StatisticsEntryToJson(this);
}

@JsonSerializable()
class StatisticsSubEntry {
  final String name;
  final String? description;
  final num value;
  final num? percentage;

  StatisticsSubEntry({
    required this.name,
    this.description,
    required this.value,
    this.percentage,
  });

  factory StatisticsSubEntry.fromJson(Map<String, dynamic> json) =>
      _$StatisticsSubEntryFromJson(json);

  Map<String, dynamic> toJson() => _$StatisticsSubEntryToJson(this);
}

@JsonSerializable()
class Plot {
  final String name;
  @JsonKey(fromJson: _plotColorFromJson, toJson: _plotColorToJson)
  final PlotColor color;
  final List<PlotData> data;

  Plot({required this.name, required this.color, required this.data});

  factory Plot.fromJson(Map<String, dynamic> json) => _$PlotFromJson(json);

  Map<String, dynamic> toJson() => _$PlotToJson(this);

  static PlotColor _plotColorFromJson(String json) {
    return PlotColor.values.firstWhere((e) => e.name == json);
  }

  static String _plotColorToJson(PlotColor color) {
    return color.name;
  }
}

@JsonSerializable()
class PlotData {
  final String key;
  final num value;
  final String? annotation;

  PlotData({required this.key, required this.value, this.annotation});

  factory PlotData.fromJson(Map<String, dynamic> json) =>
      _$PlotDataFromJson(json);

  Map<String, dynamic> toJson() => _$PlotDataToJson(this);
}
