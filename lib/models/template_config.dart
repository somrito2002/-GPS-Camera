import 'dart:convert';
import 'package:flutter/material.dart';

enum MapType { normal, satellite, terrain, hybrid }

class TemplateConfig {
  final MapType mapType;
  final bool shortAddress;
  final String dateTimeFormat;
  final String notes;
  final String hashtags;
  final bool showQrCode;
  final String stampFont;
  final Color stampColor;
  final double stampSize;
  final double mapScale;

  const TemplateConfig({
    this.mapType = MapType.normal,
    this.shortAddress = false,
    this.dateTimeFormat = 'dd MMM yyyy, hh:mm a',
    this.notes = '',
    this.hashtags = '',
    this.showQrCode = true,
    this.stampFont = 'Roboto',
    this.stampColor = Colors.white,
    this.stampSize = 1.0,
    this.mapScale = 1.0,
  });

  TemplateConfig copyWith({
    MapType? mapType,
    bool? shortAddress,
    String? dateTimeFormat,
    String? notes,
    String? hashtags,
    bool? showQrCode,
    String? stampFont,
    Color? stampColor,
    double? stampSize,
    double? mapScale,
  }) {
    return TemplateConfig(
      mapType: mapType ?? this.mapType,
      shortAddress: shortAddress ?? this.shortAddress,
      dateTimeFormat: dateTimeFormat ?? this.dateTimeFormat,
      notes: notes ?? this.notes,
      hashtags: hashtags ?? this.hashtags,
      showQrCode: showQrCode ?? this.showQrCode,
      stampFont: stampFont ?? this.stampFont,
      stampColor: stampColor ?? this.stampColor,
      stampSize: stampSize ?? this.stampSize,
      mapScale: mapScale ?? this.mapScale,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mapType': mapType.index,
      'shortAddress': shortAddress,
      'dateTimeFormat': dateTimeFormat,
      'notes': notes,
      'hashtags': hashtags,
      'showQrCode': showQrCode,
      'stampFont': stampFont,
      'stampColor': stampColor.toARGB32(),
      'stampSize': stampSize,
      'mapScale': mapScale,
    };
  }

  factory TemplateConfig.fromMap(Map<String, dynamic> map) {
    return TemplateConfig(
      mapType: MapType.values[map['mapType'] as int? ?? 0],
      shortAddress: map['shortAddress'] as bool? ?? false,
      dateTimeFormat: map['dateTimeFormat'] as String? ?? 'dd MMM yyyy, hh:mm a',
      notes: map['notes'] as String? ?? '',
      hashtags: map['hashtags'] as String? ?? '',
      showQrCode: map['showQrCode'] as bool? ?? true,
      stampFont: map['stampFont'] as String? ?? 'Roboto',
      stampColor: Color(map['stampColor'] as int? ?? Colors.white.toARGB32()),
      stampSize: (map['stampSize'] as num? ?? 1.0).toDouble(),
      mapScale: (map['mapScale'] as num? ?? 1.0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory TemplateConfig.fromJson(String source) =>
      TemplateConfig.fromMap(json.decode(source) as Map<String, dynamic>);
}
