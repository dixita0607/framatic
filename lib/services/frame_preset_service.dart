import 'dart:convert';

import 'package:framatic/models/frame_preset.dart';
import 'package:framatic/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing frame preset storage using SharedPreferences
class FramePresetService {
  static const String _customPresetsKey = 'custom_frame_presets';
  static const String _presetOrderKey = 'preset_order';

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
      final List<Map<String, dynamic>> presetsList = presets
          .map((preset) => preset.toJson())
          .toList();
      final String presetsJson = jsonEncode(presetsList);
      return await prefs.setString(_customPresetsKey, presetsJson);
    } catch (e) {
      return false;
    }
  }

  /// Add a new custom preset (prepends to order, so it appears at the top)
  Future<bool> addCustomPreset(FramePreset preset) async {
    final presets = await loadCustomPresets();
    presets.add(preset);
    final success = await saveCustomPresets(presets);

    if (success && preset.id != null) {
      // Prepend new preset to order list
      final order = await _loadPresetOrder();
      order.insert(0, preset.id!);
      await _savePresetOrder(order);
    }

    return success;
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
      await prefs.remove(_presetOrderKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load preset order from storage
  /// Returns list of preset identifiers (predefined frame names + custom frame IDs)
  Future<List<String>> _loadPresetOrder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? orderJson = prefs.getString(_presetOrderKey);

      if (orderJson == null || orderJson.isEmpty) {
        return [];
      }

      final List<dynamic> order = jsonDecode(orderJson);
      return order.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Save preset order to storage
  Future<bool> _savePresetOrder(List<String> order) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String orderJson = jsonEncode(order);
      return await prefs.setString(_presetOrderKey, orderJson);
    } catch (e) {
      return false;
    }
  }

  /// Delete a custom preset and remove from order
  Future<bool> deleteCustomPresetWithOrder(String presetId) async {
    final success = await deleteCustomPreset(presetId);

    if (success) {
      final order = await _loadPresetOrder();
      order.removeWhere((id) => id == presetId);
      await _savePresetOrder(order);
    }

    return success;
  }

  /// Reorder all presets and save the new order
  Future<bool> reorderPresets(List<FramePreset> orderedPresets) async {
    try {
      final order = orderedPresets
          .map((p) => p.id ?? p.name) // Use ID for custom, name for predefined
          .toList();
      return await _savePresetOrder(order);
    } catch (e) {
      return false;
    }
  }

  /// Get all presets sorted by user-defined order
  Future<List<FramePreset>> getAllPresetsWithOrder() async {
    final customPresets = await loadCustomPresets();
    final predefinedFrames = AspectRatios.predefinedFrames;
    final order = await _loadPresetOrder();

    // If no order exists, return predefined first + custom
    if (order.isEmpty) {
      return [...predefinedFrames, ...customPresets];
    }

    final allPresets = <FramePreset>[];
    final presetMap = <String, FramePreset>{};

    // Build map for quick lookup by ID (custom) or name (predefined)
    for (final preset in customPresets) {
      presetMap[preset.id ?? preset.name] = preset;
    }
    for (final preset in predefinedFrames) {
      presetMap[preset.name] = preset;
    }

    // Add presets in order specified
    for (final identifier in order) {
      if (presetMap.containsKey(identifier)) {
        allPresets.add(presetMap[identifier]!);
        presetMap.remove(identifier); // Remove to avoid duplicates
      }
    }

    // Add any remaining presets (newly added predefined or custom not in order)
    allPresets.addAll(presetMap.values);

    return allPresets;
  }
}
