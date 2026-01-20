import 'package:flutter/foundation.dart';
import 'package:framatic/models/frame_preset.dart';
import 'package:framatic/services/frame_preset_service.dart';
import 'package:framatic/utils/constants.dart';

/// Provider for managing frame presets and active frame state
class FrameProvider extends ChangeNotifier {
  final FramePresetService _presetService = FramePresetService();

  List<FramePreset> _allPresets = [];
  List<FramePreset> _customPresets = [];
  List<String> _favoritePresetIds = [];
  FramePreset _activePreset = AspectRatios.predefinedFrames[1]; // Default to 16:9
  bool _isLoading = true;

  // Getters
  List<FramePreset> get allPresets => _allPresets;
  List<FramePreset> get customPresets => _customPresets;
  List<FramePreset> get predefinedPresets => AspectRatios.predefinedFrames;
  List<String> get favoritePresetIds => _favoritePresetIds;
  FramePreset get activePreset => _activePreset;
  bool get isLoading => _isLoading;

  /// Get favorite presets
  List<FramePreset> get favoritePresets {
    return _allPresets.where((preset) {
      final id = preset.id ?? preset.name;
      return _favoritePresetIds.contains(id);
    }).toList();
  }

  /// Initialize provider and load presets from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customPresets = await _presetService.loadCustomPresets();
      _favoritePresetIds = await _presetService.loadFavoritePresetIds();
      _allPresets = [...AspectRatios.predefinedFrames, ..._customPresets];
    } catch (e) {
      debugPrint('Error initializing FrameProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Set the active frame preset
  void setActivePreset(FramePreset preset) {
    _activePreset = preset;
    notifyListeners();
  }

  /// Switch to next preset in list
  void nextPreset() {
    final currentIndex = _allPresets.indexWhere((p) => p == _activePreset);
    final nextIndex = (currentIndex + 1) % _allPresets.length;
    _activePreset = _allPresets[nextIndex];
    notifyListeners();
  }

  /// Switch to previous preset in list
  void previousPreset() {
    final currentIndex = _allPresets.indexWhere((p) => p == _activePreset);
    final previousIndex =
        (currentIndex - 1 + _allPresets.length) % _allPresets.length;
    _activePreset = _allPresets[previousIndex];
    notifyListeners();
  }

  /// Add a custom preset
  Future<bool> addCustomPreset(FramePreset preset) async {
    final success = await _presetService.addCustomPreset(preset);
    if (success) {
      _customPresets.add(preset);
      _allPresets = [...AspectRatios.predefinedFrames, ..._customPresets];
      notifyListeners();
    }
    return success;
  }

  /// Update an existing custom preset
  Future<bool> updateCustomPreset(FramePreset preset) async {
    final success = await _presetService.updateCustomPreset(preset);
    if (success) {
      final index = _customPresets.indexWhere((p) => p.id == preset.id);
      if (index != -1) {
        _customPresets[index] = preset;
        _allPresets = [...AspectRatios.predefinedFrames, ..._customPresets];

        // Update active preset if it was the one being edited
        if (_activePreset.id == preset.id) {
          _activePreset = preset;
        }

        notifyListeners();
      }
    }
    return success;
  }

  /// Delete a custom preset
  Future<bool> deleteCustomPreset(String presetId) async {
    final success = await _presetService.deleteCustomPreset(presetId);
    if (success) {
      _customPresets.removeWhere((p) => p.id == presetId);
      _allPresets = [...AspectRatios.predefinedFrames, ..._customPresets];

      // If the deleted preset was active, switch to default
      if (_activePreset.id == presetId) {
        _activePreset = AspectRatios.predefinedFrames[1]; // 16:9
      }

      // Remove from favorites if it was favorited
      _favoritePresetIds.remove(presetId);
      await _presetService.saveFavoritePresetIds(_favoritePresetIds);

      notifyListeners();
    }
    return success;
  }

  /// Toggle favorite status of a preset
  Future<bool> toggleFavorite(String presetId) async {
    if (_favoritePresetIds.contains(presetId)) {
      final success = await _presetService.removeFromFavorites(presetId);
      if (success) {
        _favoritePresetIds.remove(presetId);
        notifyListeners();
      }
      return success;
    } else {
      final success = await _presetService.addToFavorites(presetId);
      if (success) {
        _favoritePresetIds.add(presetId);
        notifyListeners();
      }
      return success;
    }
  }

  /// Check if a preset is favorited
  bool isFavorite(String presetId) {
    return _favoritePresetIds.contains(presetId);
  }

  /// Clear all custom presets
  Future<bool> clearAllCustomPresets() async {
    final success = await _presetService.clearAllCustomPresets();
    if (success) {
      _customPresets.clear();
      _favoritePresetIds.clear();
      _allPresets = [...AspectRatios.predefinedFrames];

      // Reset to default if active was custom
      if (_activePreset.isCustom) {
        _activePreset = AspectRatios.predefinedFrames[1]; // 16:9
      }

      notifyListeners();
    }
    return success;
  }

  /// Get preset by ID (either custom ID or name for predefined)
  FramePreset? getPresetById(String id) {
    return _allPresets.firstWhere(
      (preset) => (preset.id ?? preset.name) == id,
      orElse: () => AspectRatios.predefinedFrames[1], // Default to 16:9
    );
  }
}
