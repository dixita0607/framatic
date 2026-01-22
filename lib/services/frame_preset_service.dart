import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:framatic/models/frame_preset.dart';
import 'package:framatic/utils/constants.dart';

/// Service for managing frame preset storage using SharedPreferences
class FramePresetService {
  static const String _customPresetsKey = 'custom_frame_presets';

  /// Load all custom presets from storage
  Future<List<FramePreset>> loadCustomPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? presetsJson = prefs.getString(_customPresetsKey);

      if (presetsJson == null || presetsJson.isEmpty) {
        return [];
      }

      final List<dynamic> presetsList = jsonDecode(presetsJson);
      return presetsList
          .map((json) => FramePreset.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's an error, return empty list
      return [];
    }
  }

  /// Save custom presets to storage
  Future<bool> saveCustomPresets(List<FramePreset> presets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> presetsList =
          presets.map((preset) => preset.toJson()).toList();
      final String presetsJson = jsonEncode(presetsList);
      return await prefs.setString(_customPresetsKey, presetsJson);
    } catch (e) {
      return false;
    }
  }

  /// Add a new custom preset
  Future<bool> addCustomPreset(FramePreset preset) async {
    final presets = await loadCustomPresets();
    presets.add(preset);
    return await saveCustomPresets(presets);
  }

  /// Update an existing custom preset
  Future<bool> updateCustomPreset(FramePreset preset) async {
    if (preset.id == null) return false;

    final presets = await loadCustomPresets();
    final index = presets.indexWhere((p) => p.id == preset.id);

    if (index == -1) return false;

    presets[index] = preset;
    return await saveCustomPresets(presets);
  }

  /// Delete a custom preset
  Future<bool> deleteCustomPreset(String presetId) async {
    final presets = await loadCustomPresets();
    presets.removeWhere((p) => p.id == presetId);
    return await saveCustomPresets(presets);
  }

  /// Get all presets (predefined + custom)
  Future<List<FramePreset>> getAllPresets() async {
    final customPresets = await loadCustomPresets();
    return [...AspectRatios.predefinedFrames, ...customPresets];
  }

  /// Clear all custom presets
  Future<bool> clearAllCustomPresets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_customPresetsKey);
      return true;
    } catch (e) {
      return false;
    }
  }
}
