# Project Overview

Framatic is a Flutter mobile app that helps artists frame landscapes by providing live camera viewfinder overlays with customizable aspect ratios. It replaces physical frame cutouts artists traditionally use for composition.

## State Management

Uses **Provider** pattern for state management with the widgets.
Uses **sqflite** package for storing frame data locally.
Uses **shared_preferences** package for storing the order of the frame according to user's preference.

## Architecture

Feature-based MVVM structure under `lib/`:

**Core** (`lib/core/`) — shared code across features

- `models/` — data models (e.g., Frame)
- `services/` — permission, preferences
- `utils/` — constants, DB helper, frame calculator
- `widgets/` — reusable widgets (e.g., CircularActionButton)

**Features** (`lib/features/`) — each feature follows data/domain/presentation layers

- `camera/` — camera viewfinder, capture, zoom, frame overlay
- `frames_manager/` — CRUD for custom frames
- `photo_preview/` — preview and save captured photos

## Frame Overlay & Camera Clipping

The frame border is a `Container` with `Border.all` positioned via `Stack`/`Positioned`. The camera feed is clipped to the selected aspect ratio using `ClipRect` + `OverflowBox` (not masked). Both widgets share `calculateFrameSize()` from `frame_calculator.dart` to stay aligned.

## Photo Processing

Captured images are processed in a background `Isolate`. The image is center-cropped to the frame's aspect ratio using the `image` package (`img.copyCrop`), then composited onto a white-filled canvas to create the polaroid-style border. The result is written to a temp file and shown in preview. Photos are saved to a dedicated "Framatic" album using `Gal.putImage`.

## Predefined Aspect Ratios

When user opens the application for the first time, there are some pre-defined frames available i.e. 4:3, 16:9, 1:1. Added while creating the database for the first time.

## Design Approach

- Minimalist interface prioritizing the camera viewfinder
- Use simple black and white colors for theming

## Development workflow notes

- Don't commit the files after finishing a chunk of work. Only commit when asked.
- Try to think critically when asked questions instead of agreeing with it.

## Git

- Use conventional git commit message
