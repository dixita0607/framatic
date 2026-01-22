# Project Overview

Framatic is a Flutter mobile app that helps artists frame landscapes by providing live camera viewfinder overlays with customizable aspect ratios. It replaces physical frame cutouts artists traditionally use for composition.

## State Management

Uses **Provider** pattern for state management.

## Core Layers

**Models** (`lib/models/`)

**Services** (`lib/services/`)

**Providers** (`lib/providers/`)

**Screens** (`lib/screens/`)

**Widgets** (`lib/widgets/`)

### Frame Overlay Rendering

The overlay uses `CustomPainter` to draw a centered rectangle based on aspect ratio. The area outside the frame is filled with semi-transparent white (polaroid-style). Frame dimensions are calculated to fit within 95% of screen bounds while maintaining the aspect ratio.

## Predefined Aspect Ratios

Defined in `lib/utils/constants.dart` via `AspectRatios` class: 4:3, 16:9, 1:1, 3:2, 2:3, 5:7, Golden ratio (1.618:1).

## Photo Capture Flow

Photos are saved to a dedicated "Artist Frames" album using the `gal` package for gallery access. The frame overlay is rendered onto the captured image before saving.

## Design Approach

- Minimalist interface prioritizing the camera viewfinder
- Use simple black and white colors for theming

## Implementation Status

See [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) for full roadmap.

## Development workflow notes

- Don't commit the files after finishing a chunk of work. Only commit when asked.
