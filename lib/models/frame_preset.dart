import 'package:flutter/material.dart';

/// Model representing a frame preset with aspect ratio information
class FramePreset {
  final String name;
  final double aspectRatio;
  final bool isCustom;
  final Color frameColor;
  final String? id;
  final int? widthRatio;  // Original width value for custom presets
  final int? heightRatio; // Original height value for custom presets

  FramePreset({
    required this.name,
    required this.aspectRatio,
    this.isCustom = false,
    this.frameColor = Colors.white,
    this.id,
    this.widthRatio,
    this.heightRatio,
  });

  /// Create a copy of this preset with modified properties
  FramePreset copyWith({
    String? name,
    double? aspectRatio,
    bool? isCustom,
    Color? frameColor,
    String? id,
    int? widthRatio,
    int? heightRatio,
  }) {
    return FramePreset(
      name: name ?? this.name,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      isCustom: isCustom ?? this.isCustom,
      frameColor: frameColor ?? this.frameColor,
      id: id ?? this.id,
      widthRatio: widthRatio ?? this.widthRatio,
      heightRatio: heightRatio ?? this.heightRatio,
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
      'widthRatio': widthRatio,
      'heightRatio': heightRatio,
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
      widthRatio: json['widthRatio'] as int?,
      heightRatio: json['heightRatio'] as int?,
    );
  }

  /// Get formatted aspect ratio string (e.g., "16:9" or "2:8")
  String get formattedRatio {
    // Use stored width/height for custom presets
    if (widthRatio != null && heightRatio != null) {
      return '$widthRatio:$heightRatio';
    }

    if (name == 'Golden') {
      return '${aspectRatio.toStringAsFixed(3)}:1';
    }
    // Try to find simple ratio for predefined
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
