# Artist Framing Assistant - Flutter Application Plan

## Overview

A Flutter mobile application that replaces physical frame cutouts artists use for framing landscapes. The app provides a live camera viewfinder with customizable aspect ratio overlays, photo capture, and frame comparison features.

## Core Requirements

- **Live camera viewfinder** with real-time aspect ratio overlays
- **Multiple aspect ratios**: 16:9, 4:3, 1:1 as defaults; users can add custom ratios
- **Photo capture** with frame overlay baked into the saved image
- **Zoom control** for composition adjustment
- **Quick frame switching** between saved presets
- **Frame comparison mode** for horizontal vs vertical framing decisions
- **Intuitive UI** suitable for outdoor use by artists

## Technical Architecture

### Technology Stack

- **Framework**: Flutter (cross-platform: iOS & Android)
- **Camera**: `camera` package (official Flutter plugin for camera access)
- **State Management**: Provider or Riverpod (lightweight, suitable for app complexity)
- **Storage**:
  - SharedPreferences for user preferences and custom frame presets
  - path_provider for saving captured photos to device gallery
  - gal for exporting to device photo library (modern, well-maintained alternative)

### Core Components

#### 1. Camera Service Layer

- Initialize and manage camera controller
- Handle camera lifecycle (permissions, initialization, disposal)
- Provide camera preview stream
- Handle photo capture with overlay rendering
- Implement zoom functionality (using camera's zoom capabilities)

#### 2. Frame Overlay System

- **FrameOverlay Widget**: Custom painter to draw aspect ratio frames
- **Frame Model**: Data class containing aspect ratio, name, color
- **Predefined frames**: Standard library of ratios
- **Custom frame builder**: UI for users to create custom aspect ratios
- Overlay rendering: Centered frame box with solid white polaroid like outer area

#### 3. Frame Preset Manager

- Save/load custom frame presets
- Frame switching gesture controls (swipe or bottom sheet)

#### 4. Split-Screen Comparison Mode

- Display two camera previews side-by-side or top-bottom
- Each preview shows different aspect ratio (e.g., landscape vs portrait)
- Synchronized zoom across both views
- Capture comparison shots

#### 5. Photo Capture & Export

- Render overlay onto captured image
- Save to device gallery with proper metadata
- **Save to dedicated app folder** in gallery ("Artist Frames" or "Frame Assistant")
- Optional: Save without overlay (raw photo + overlay data)

## Application Structure

```
lib/
├── main.dart
├── models/
│   ├── frame_preset.dart          # Frame aspect ratio data model
│   └── camera_settings.dart       # Camera state model
├── services/
│   ├── camera_service.dart        # Camera initialization & control
│   ├── frame_preset_service.dart  # Load/save presets
│   └── photo_service.dart         # Photo capture & gallery export
├── providers/
│   ├── camera_provider.dart       # Camera state management
│   └── frame_provider.dart        # Active frame & presets
├── screens/
│   ├── camera_screen.dart         # Main viewfinder screen
│   ├── comparison_screen.dart     # Split-screen comparison
│   ├── settings_screen.dart       # App settings
│   └── preset_manager_screen.dart # Manage saved frames
├── widgets/
│   ├── frame_overlay.dart         # Custom painter for frame
│   ├── camera_controls.dart       # Bottom controls (capture, switch)
│   ├── zoom_slider.dart           # Zoom control UI
│   └── frame_selector.dart        # Quick frame switcher
└── utils/
    ├── constants.dart             # Predefined aspect ratios
    └── permissions.dart           # Camera/storage permissions
```

## Implementation Phases

### Phase 1: Core Camera & Basic Overlay

**Status: ✅ COMPLETED**

**Files to create:**

- `main.dart` - App entry point with navigation
- `services/camera_service.dart` - Camera initialization, preview, basic capture
- `models/frame_preset.dart` - Frame data model
- `widgets/frame_overlay.dart` - Custom painter for centered aspect ratio frame
- `screens/camera_screen.dart` - Main screen with camera preview + overlay
- `utils/constants.dart` - Predefined aspect ratios (4:3, 16:9, 1:1, etc.)
- `utils/permissions.dart` - Permission handling for camera

**Implementation:**

1. Set up Flutter project with camera package dependency
2. Implement camera service with permission handling
3. Create basic camera preview screen
4. Build frame overlay custom painter (centered rectangle with solid white edges)
5. Implement simple frame switching (dropdown or buttons)

### Phase 2: Frame Management & Presets

**Status: ✅ COMPLETED**

**Files to create:**

- `services/frame_preset_service.dart` - SharedPreferences storage
- `providers/frame_provider.dart` - State management for active frame
- `screens/preset_manager_screen.dart` - UI to view/edit/delete presets
- `widgets/frame_selector.dart` - Bottom sheet or swipeable selector

**Implementation:**

1. Add state management (Provider/Riverpod)
2. Implement preset save/load from SharedPreferences
3. Create custom frame builder (input aspect ratio values)
4. Build quick frame switcher UI (swipe gestures or bottom sheet)
5. Add predefined artistic ratios (golden ratio, 2:3, 5:7)

### Phase 3: Photo Capture & Export

**Status: ✅ COMPLETED**

**Files to create:**

- `services/photo_service.dart` - Capture + overlay rendering + gallery export
- `widgets/camera_controls.dart` - Capture button, gallery button

**Implementation:**

1. Implement photo capture with camera service
2. Render frame overlay onto captured image (using Canvas/CustomPainter)
3. Save to dedicated gallery album "Artist Frames" using gal
4. Add photo preview after capture
5. Gallery access button to view captured photos

### Phase 4: Zoom & Enhanced Controls

**Status: ✅ COMPLETED**

**Files to update:**

- `services/camera_service.dart` - Add zoom control methods
- `widgets/zoom_slider.dart` - Vertical/horizontal zoom slider
- `screens/camera_screen.dart` - Integrate zoom UI

**Implementation:**

1. Query device min/max zoom levels (support 0.5x ultra-wide on capable devices)
2. Implement zoom using camera controller's zoom capabilities
3. Create intuitive zoom slider widget (pinch gesture + slider)
4. Display zoom level indicator (0.5x, 1.0x, 2.0x, etc.)
5. Start at minimum zoom (0.5x if available) to give artists wider field of view
6. Add exposure/focus tap controls (optional enhancement)

### Phase 5: Camera Flip (Front/Back Toggle)

**Status: ✅ COMPLETED**

**Files to update:**

- `screens/camera_screen.dart` - Add flip camera button
- `services/camera_service.dart` - Camera switching logic (already exists)

**Implementation:**

1. Add flip camera button to camera screen UI
2. Use existing `switchCamera()` method in CameraService
3. Re-initialize zoom levels after camera switch

### Phase 6: UI/UX Polish & Styling

Status: ✅ COMPLETED

**Overview:**
Redesign of the camera screen UI with proper layout constraints and a clean, modern interface optimized for outdoor use using Flutter Material components.

**User Requirements:**

1. No Header
2. Solid black background - Pure black (#000000) throughout entire app
3. Fix frame positioning - Frame should start immediately from the top
4. Add max height constraints - Prevent camera frame area from bleeding behind bottom controls
5. Redesign capture button - Circular button with translucent background, no icon/text
6. Remove frame navigation arrows - Users select frames by clicking chips only
7. Keep zoom slider position - on top of the capture button UI (currently implemented)

**Implementation Steps:**

- ✅ Step 1-10: Camera screen redesign (completed)
- ✅ Step 11: Update Frame Preset Configuration Screens UI (completed)

### Phase 6.1: Frame Preset Configuration Screens UI Update

Status: ✅ COMPLETED

**Overview:**
Redesign the frame preset manager and custom frame builder screens to match the main camera screen's black-and-white minimalist design with consistent Flutter Material components.

**Current Issues:**

- Frame preset configuration screens don't match the main camera screen design
- Inconsistent color scheme and typography across the app
- Frame preset manager lacks proper visual hierarchy
- Custom frame builder UI needs modernization

**Screens to Update:**

1. **Preset Manager Screen** (`lib/screens/preset_manager_screen.dart`)
   - Single unified list of all frame presets (predefined + custom)
   - Predefined presets included in the list (cannot be deleted)
   - Edit/delete options for custom presets
   - No favorites/star functionality
   - Add button in bottom right corner (Material Design FAB style)
   - No selected state indicator

2. **Edit Frame Modal/Drawer** (modal or bottom sheet)
   - Input fields for aspect ratio (width:height or decimal)
   - Name input for the preset
   - Save/cancel buttons
   - Live preview of frame overlay
   - Wider layout to reduce visual clutter

**Design Requirements:**

- Use Flutter Material 3 components with dark theme
- Consistent spacing and padding with main camera screen
- Minimal, clean UI focused on functionality
- Proper touch targets (minimum 48x48dp)
- All widgets inherit colors from Material theme (no custom color overrides)

**Implementation Steps:**

- ✅ Step 1: Update preset manager screen layout
  - Add screen title "Manage Frames"
  - Uses Material theme defaults for colors
- ✅ Step 2: Merge predefined and custom frames into single list
- ✅ Step 3: Redesign list items with Material ListTile
  - Remove star/favorite icons completely
  - Remove green checkmark (selected state indicator)
  - Show edit/delete buttons or action menu for custom presets only
  - Use Material ListTile default styling
- ✅ Step 4: Remove on-tap gesture from list items
  - Remove the logic that changes the active/selected frame state
  - Remove snackbar showing active state change message
- ✅ Step 5: Move add button to bottom right corner (Material FAB or icon button)
- ✅ Step 6: Rebuild edit frame modal/drawer with wider layout
- ✅ Step 7: Rebuild custom frame builder form with Material TextFormField
  - Use Material theme defaults for colors and styling
- ⏭️ Step 8: Add live preview of frame overlay during configuration (skipped per user request)
- ✅ Step 9: Implement form validation with error messages
- ✅ Step 10: Remove all favorite/star related code and state management
- ✅ Step 11: Clean up favorite-related code from services and models

**Files Modified:**

- `lib/screens/preset_manager_screen.dart` - ✅ Updated with merged lists and FAB
- `lib/widgets/custom_frame_dialog.dart` - ✅ Updated with Material defaults and wider layout
- `lib/providers/frame_provider.dart` - ✅ Removed favorite functionality from state management
- `lib/services/frame_preset_service.dart` - ✅ Removed favorite storage methods
- `lib/widgets/frame_selector.dart` - ✅ Removed favorites section
- `lib/main.dart` - ✅ Simplified to Material 3 dark theme defaults

**Verification Checklist:**

- [x] Predefined and custom frames in single unified list
- [x] Add button in bottom right corner (FAB)
- [x] No star/favorite icons visible anywhere
- [x] No green checkmark or selected state indicator on list items
- [x] Edit/delete options only visible for custom presets
- [x] Edit modal/drawer has wider layout
- [x] List items use Material components (ListTile)
- [x] Custom frame builder uses Material TextFormField components
- [x] Form validation works correctly with clear error messages
- [⏭️] Live preview shows frame overlay in real-time (skipped per user request)
- [x] All buttons have minimum 48x48dp touch target
- [x] Spacing and alignment is consistent
- [x] No on-tap gesture changing active frame state
- [x] No favorite-related code remains in state management
- [x] No favorite-related code remains in services layer
- [x] Theme uses Material 3 dark mode defaults (no custom color overrides)

### Phase 7: Frame Preset Reordering

**Status: ✅ COMPLETED**

**Overview:**
Add drag-and-drop reordering functionality to the frame preset manager screen, allowing users to customize the order of presets. The custom order will be persisted and reflected on the camera screen's frame selector.

**User Requirements:**

1. ✅ Drag-and-drop reordering of frame presets in the preset manager screen
2. ✅ Drag handle icon visible on the left side of each list item
3. ✅ Visual feedback during dragging (elevated state, opacity change)
4. ✅ Persistent storage of custom preset order
5. ✅ Order preserved on camera screen's frame selector
6. ✅ Full-item drag capability (drag from anywhere, not just handle)
7. ✅ Smooth animations without text flicker or lag
8. ✅ Correct drop positioning for items dragged in both directions

**Files Modified:**

- ✅ `lib/screens/preset_manager_screen.dart` - ReorderableListView with performance optimizations and full-item drag
- ✅ `lib/providers/frame_provider.dart` - Reorder method with background persistence
- ✅ `lib/services/frame_preset_service.dart` - Order persistence layer

**Implementation Steps:**

- ✅ Step 1: Update FramePresetService to manage preset order
  - Added `_loadPresetOrder()` and `_savePresetOrder()` for persistence
  - Added `getAllPresetsWithOrder()` to load presets in user-defined order
  - Added `deleteCustomPresetWithOrder()` to maintain order on deletion
  - Updated `addCustomPreset()` to prepend new custom presets to order list

- ✅ Step 2: Add reorder method to FrameProvider
  - Added `reorderPresets(List<FramePreset> orderedPresets)` method
  - **OPTIMIZED**: Updates UI immediately, persists in background (fire-and-forget pattern)
  - Prevents animation jank by decoupling data updates from persistence

- ✅ Step 3: Update preset_manager_screen.dart
  - Replaced ListView.builder with ReorderableListView.builder
  - Added drag handle icon (Icons.drag_handle) on left
  - **OPTIMIZED**: Removed await from onReorder callback (non-blocking)
  - **OPTIMIZED**: Wrapped entire ListTile in ReorderableDragStartListener for full-item drag
  - **OPTIMIZED**: Fixed ReorderableListView index adjustment bug (subtract 1 when dragging down)
  - **OPTIMIZED**: Eliminated O(n) indexOf() calls in itemBuilder
  - **OPTIMIZED**: Changed isPredefined check to use preset.isCustom property (order-independent)
  - **OPTIMIZED**: Added RepaintBoundary to prevent cascading repaints during drag

- ✅ Step 4: Update frame_selector.dart on camera screen
  - Automatically uses ordered list via `frameProvider.allPresets`
  - No changes needed - already reflects user-defined order

- ✅ Step 5: Added visual feedback
  - ReorderableListView provides built-in drag animation
  - Material 3 compliant drag behavior

**Performance Optimizations:**

- ✅ **Eliminated O(n) indexOf() search**: Used dragIndex directly from itemBuilder (O(1))
- ✅ **Eliminated O(n) contains() check**: Replaced with isPredefined = !preset.isCustom (O(1))
- ✅ **Added RepaintBoundary**: Prevents widget rebuild cascades during drag animation
- ✅ **Added ListTile key**: Ensures PopupMenuButton state is properly tracked during reordering
- ✅ **Fire-and-forget persistence**: UI updates immediately, persistence happens in background
- ✅ **Index adjustment for downward drag**: Fixed ReorderableListView quirk where newIndex is post-removal

**Bug Fixes:**

- ✅ Fixed text flicker during drop: Separated UI update from persistence timing
- ✅ Fixed menu state persistence: Added key to ListTile for proper PopupMenuButton tracking
- ✅ Fixed isPredefined indicator: Changed from position-based to property-based check (works after reordering)
- ✅ Fixed incorrect drop positioning: Added index adjustment when dragging down (oldIndex < newIndex)

**Design Requirements:**

- ✅ Drag handle icon positioned consistently on the left (before preview)
- ✅ Drag from any point on the item (full-item drag support)
- ✅ Material 3 compliant drag behavior
- ✅ Clear visual feedback that preset is draggable
- ✅ Maintain minimum 48x48dp touch target
- ✅ Smooth animation when reordering (no flicker, no lag)

**Additional Features:**

- ✅ Default behavior: App always defaults to first preset in ordered list on startup
- ✅ Order strategy: Separate list of preset identifiers (names for predefined, IDs for custom)
- ✅ Graceful fallback: If order list missing, uses predefined first + custom

**Verification Checklist:**

- [x] Drag handle icon visible on all list items
- [x] Dragging reorders items in real-time
- [x] Order persists after app restart
- [x] Order reflected on camera screen frame selector
- [x] Predefined presets can be reordered together with custom presets
- [x] Custom presets can be freely reordered
- [x] Smooth drag animation with visual feedback (no flicker)
- [x] No horizontal scroll within list items during drag
- [x] New custom presets appear at the top of the list
- [x] Full-item drag from any point on the ListTile
- [x] No lag during drag operation (optimized O(1) checks)
- [x] Menu (three dots) stays with correct item after reordering
- [x] Drop position is accurate in both upward and downward drag directions
- [x] No text flicker when dropping items

## Key Technical Decisions

### Camera Implementation

- Use `camera` package (official, well-maintained)
- Target Android API level 21+ and iOS 11+
- Handle both front and back cameras
- Lock orientation to portrait or support auto-rotation based on device sensors

### Overlay Rendering

- Use `CustomPainter` for efficient frame overlay drawing
- Draw frame as centered rectangle with calculated dimensions
- **Outer area**: Solid white overlay (like polaroid frames) covering the area outside the frame
- **Frame border**: Optional thin border line to define the frame edge clearly
- Frame color customizable in settings (default: solid white)

### Frame Calculation

```dart
// Example: For 16:9 frame on screen
double screenWidth = MediaQuery.of(context).size.width;
double screenHeight = MediaQuery.of(context).size.height;
double aspectRatio = 16 / 9;

// Calculate frame dimensions (fit within screen)
double frameWidth = screenWidth * 0.9; // 90% of screen width
double frameHeight = frameWidth / aspectRatio;

if (frameHeight > screenHeight * 0.9) {
  frameHeight = screenHeight * 0.9;
  frameWidth = frameHeight * aspectRatio;
}
```

### Photo Capture with Overlay

1. Capture high-res photo from camera
2. Load image as `ui.Image`
3. Create canvas with image dimensions
4. Draw original image
5. Draw frame overlay at correct scale
6. Export as PNG/JPEG to dedicated gallery folder

### Gallery Organization

**Android:**

- Save photos to `Pictures/ArtistFrames/` using MediaStore API (Android 10+)
- For Android 9 and below, use `DCIM/ArtistFrames/`
- Creates dedicated album visible in Gallery/Photos app
- Use `gal` with album name parameter

**iOS:**

- Save to custom album "Artist Frames" using Photos framework
- Creates dedicated album in Photos app
- Use `gal` or `photo_manager` package
- Requires photo library permissions

**Implementation:**

```dart
// Example save with album name
await ImageGallerySaver.saveImage(
  imageBytes,
  quality: 100,
  name: "frame_${timestamp}",
  albumName: "Artist Frames", // Creates/uses dedicated folder
);
```

### Comparison Mode Layout

- **Horizontal split**: Best for comparing landscape vs portrait orientation
- **Vertical split**: Alternative for different aspect ratios in same orientation
- Each view: 50% of screen space with independent frame overlay
- Synchronized zoom maintains consistent scale across both views

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5          # Official camera plugin
  provider: ^6.1.1         # State management
  shared_preferences: ^2.2.2  # Store presets
  path_provider: ^2.1.1    # File paths
  gal: ^2.3.0              # Save to gallery (modern, Android Gradle compatible)
  permission_handler: ^11.0.1  # Permission management
  image: ^4.1.3            # Image manipulation for overlay rendering
```

## UI/UX Considerations

### Main Camera Screen Layout

```
┌─────────────────────────┐
│   [Settings]    [☀️]    │ ← Top bar: settings, flashlight
│                         │
│    ┏━━━━━━━━━━━━━━┓    │ ← Camera preview with overlay
│    ┃              ┃    │
│    ┃   FRAMED     ┃    │
│    ┃   AREA       ┃    │
│    ┃              ┃    │
│    ┗━━━━━━━━━━━━━━┛    │
│                         │
│  [🔍] Zoom Slider       │ ← Side: Zoom control
│                         │
│  [4:3] [16:9] [1:1]    │ ← Bottom: Quick frame switches
│  [📷] [⚡] [Gallery]    │ ← Capture, comparison, gallery
└─────────────────────────┘
```

### User Experience Flow

1. **First launch**: Request camera permissions → Quick tutorial
2. **Default view**: Camera with 16:9 frame overlay
3. **Frame switching**: Swipe frame selector or tap to open full preset list
4. **Capture**: Tap camera button → Preview → Save/Retake
5. **Comparison**: Tap comparison icon → Select two frames → Side-by-side view

### Accessibility

- Large touch targets for outdoor use (minimum 48x48dp)
- High contrast controls (visible in bright sunlight)
- Haptic feedback on capture
- Simple, minimal UI to avoid distraction

## Verification & Testing

### Manual Testing Checklist

1. **Camera initialization**: App launches and camera preview appears
2. **Frame overlay**: Different aspect ratios display correctly centered
3. **Photo capture**: Captured photos include frame overlay and save to gallery
4. **Dedicated album**: Photos appear in "Artist Frames" album/folder in gallery app
5. **Frame switching**: Quick frame switcher changes overlay in real-time
6. **Custom frames**: Can create and save custom aspect ratios
7. **Zoom**: Zoom slider smoothly adjusts camera zoom level
8. **Comparison mode**: Split-screen displays two different frames simultaneously
9. **Permissions**: App handles denied permissions gracefully
10. **Orientation**: App responds correctly to device rotation
11. **Gallery organization**: Album is visible and accessible on both Android and iOS

### Testing on Devices

- Test on both Android and iOS
- Test on different screen sizes (phone, tablet)
- Test in various lighting conditions (bright sunlight, indoors, low light)
- Verify performance with camera preview (target 30fps)

### Edge Cases

- Camera unavailable or permission denied
- Low storage space for photo capture
- App backgrounded during camera use
- Multiple rapid captures
- Switching between front/back cameras

## Future Enhancements (Post-MVP)

- Cloud sync of frame presets across devices
- Share frame presets with other artists
- Integration with drawing apps (export to Procreate, etc.)
- AR mode: Display frame overlay in 3D space using ARCore/ARKit

## Estimated Complexity

- **Phase 1 (Core Camera & Overlay)**: Medium complexity - Standard Flutter camera implementation
- **Phase 2 (Frame Management)**: Low complexity - Basic CRUD with SharedPreferences
- **Phase 3 (Photo Capture)**: Medium complexity - Image manipulation and gallery export
- **Phase 4 (Zoom)**: Low complexity - Camera API provides zoom control
- **Phase 5 (Camera Flip)**: Low complexity - Simple camera switching with zoom reset
- **Phase 6 (UI/UX Polish)**: Low-Medium complexity - UI refinements and styling
- **Phase 7 (Comparison Mode)**: Medium-High complexity - Dual preview requires careful state management

## Critical Success Factors

1. **Smooth camera preview**: No lag or stuttering in live view
2. **Accurate frame overlay**: Aspect ratios must be mathematically correct
3. **Intuitive frame switching**: Artists can change frames in 1-2 taps
4. **Reliable photo capture**: Overlay renders correctly on saved images
5. **Outdoor usability**: UI visible in bright sunlight with gloves/dirty hands

---

This plan provides a complete roadmap for building the Artist Framing Assistant app. The phased approach allows for incremental development and testing, with the core functionality (camera + overlay + capture) delivered early, followed by enhanced features like comparison mode and custom presets.
