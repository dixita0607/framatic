/// Model representing a frame with aspect ratio information
class Frame {
  final int? id;
  final String title;
  final int width;
  final int height;
  final bool isCustom;

  Frame({
    this.id,
    required this.title,
    required this.width,
    required this.height,
    this.isCustom = false,
  }) : assert(title.trim().isNotEmpty, 'title cannot be empty'),
       assert(width > 0, 'width must be positive'),
       assert(height > 0, 'height must be positive');

  /// Computed aspect ratio from width and height
  double get aspectRatio => width / height;

  /// Get formatted aspect ratio string (e.g., "16:9" or "2:8")
  String get formattedRatio => '$width:$height';

  /// Create from JSON
  factory Frame.fromJson(Map<String, dynamic> json) {
    return Frame(
      id: json[FramesTable.id] as int?,
      title: json[FramesTable.title] as String,
      width: json[FramesTable.width] as int,
      height: json[FramesTable.height] as int,
      isCustom: json[FramesTable.isCustom] == 1,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    FramesTable.id: id,
    FramesTable.title: title,
    FramesTable.width: width,
    FramesTable.height: height,
    FramesTable.isCustom: isCustom ? 1 : 0,
  };

  /// Create a copy of this frame with modified properties
  Frame copyWith({
    int? id,
    String? title,
    bool? isCustom,
    int? width,
    int? height,
  }) {
    return Frame(
      id: id ?? this.id,
      title: title ?? this.title,
      width: width ?? this.width,
      height: height ?? this.height,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Frame &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          width == other.width &&
          height == other.height &&
          isCustom == other.isCustom;

  @override
  int get hashCode => Object.hash(id, title, width, height, isCustom);

  @override
  String toString() {
    return 'Frame(id: $id, title: $title, width: $width, height: $height, isCustom: $isCustom)';
  }
}

abstract class FramesTable {
  static const String name = 'frames';

  // Columns
  static const String id = 'id';
  static const String title = 'title';
  static const String width = 'width';
  static const String height = 'height';
  static const String isCustom = 'is_custom';
}
