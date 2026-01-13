import 'package:flutter/material.dart';

/// Model representing a frame preset with aspect ratio information
class FramePreset {
  final String name;
  final double aspectRatio;
  final bool isCustom;
  final Color frameColor;
  final String? id;

  FramePreset({
    required this.name,
    required this.aspectRatio,
    this.isCustom = false,
    this.frameColor = Colors.white,
    this.id,
  });

  /// Create a copy of this preset with modified properties
  FramePreset copyWith({
    String? name,
    double? aspectRatio,
    bool? isCustom,
    Color? frameColor,
    String? id,
  }) {
    return FramePreset(
      name: name ?? this.name,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      isCustom: isCustom ?? this.isCustom,
      frameColor: frameColor ?? this.frameColor,
      id: id ?? this.id,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'aspectRatio': aspectRatio,
      'isCustom': isCustom,
      'frameColor': frameColor.toARGB32(),
      'id': id,
    };
  }

  /// Create from JSON
  factory FramePreset.fromJson(Map<String, dynamic> json) {
    return FramePreset(
      name: json['name'] as String,
      aspectRatio: json['aspectRatio'] as double,
      isCustom: json['isCustom'] as bool? ?? false,
      frameColor: Color(json['frameColor'] as int? ?? Colors.white.toARGB32()),
      id: json['id'] as String?,
    );
  }

  /// Get formatted aspect ratio string (e.g., "16:9" or "1.618:1")
  String get formattedRatio {
    if (name == 'Golden') {
      return '${aspectRatio.toStringAsFixed(3)}:1';
    }
    // Try to find simple ratio
    if (aspectRatio == 1.0) return '1:1';
    if ((aspectRatio - 4 / 3).abs() < 0.01) return '4:3';
    if ((aspectRatio - 16 / 9).abs() < 0.01) return '16:9';
    if ((aspectRatio - 3 / 2).abs() < 0.01) return '3:2';
    if ((aspectRatio - 2 / 3).abs() < 0.01) return '2:3';
    if ((aspectRatio - 5 / 7).abs() < 0.01) return '5:7';

    return '${aspectRatio.toStringAsFixed(2)}:1';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FramePreset &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          aspectRatio == other.aspectRatio &&
          isCustom == other.isCustom;

  @override
  int get hashCode =>
      name.hashCode ^ aspectRatio.hashCode ^ isCustom.hashCode;

  @override
  String toString() {
    return 'FramePreset(name: $name, aspectRatio: $aspectRatio, isCustom: $isCustom)';
  }
}
