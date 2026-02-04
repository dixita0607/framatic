import 'package:flutter/material.dart';

/// Model representing a frame preset with aspect ratio information
class FramePreset {
  final String name;
  final int width;
  final int height;
  final bool isCustom;
  final Color frameColor;
  final String id;

  FramePreset({
    required this.name,
    required this.width,
    required this.height,
    required this.id,
    this.isCustom = false,
    this.frameColor = Colors.white,
  }) : assert(name.trim().isNotEmpty, 'name cannot be empty'),
       assert(width > 0, 'width must be positive'),
       assert(height > 0, 'height must be positive');

  /// Computed aspect ratio from width and height
  double get aspectRatio => width / height;

  /// Get formatted aspect ratio string (e.g., "16:9" or "2:8")
  String get formattedRatio => '$width:$height';

  /// Create a copy of this preset with modified properties
  FramePreset copyWith({
    String? name,
    bool? isCustom,
    Color? frameColor,
    String? id,
    int? width,
    int? height,
  }) {
    return FramePreset(
      name: name ?? this.name,
      width: width ?? this.width,
      height: height ?? this.height,
      isCustom: isCustom ?? this.isCustom,
      frameColor: frameColor ?? this.frameColor,
      id: id ?? this.id,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isCustom': isCustom,
      'frameColor': frameColor.toARGB32(),
      'id': id,
      'width': width,
      'height': height,
    };
  }

  /// Create from JSON
  factory FramePreset.fromJson(Map<String, dynamic> json) {
    return FramePreset(
      name: json['name'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      id: json['id'] as String,
      isCustom: json['isCustom'] as bool? ?? false,
      frameColor: Color(json['frameColor'] as int? ?? Colors.white.toARGB32()),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FramePreset &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          width == other.width &&
          height == other.height &&
          isCustom == other.isCustom &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FramePreset(id: $id, name: $name, width: $width, height: $height, isCustom: $isCustom)';
  }
}
