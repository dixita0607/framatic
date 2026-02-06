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

## Data and State management

`sqflite` package is being used for storing structured data of frames. To save the order of the page, use `shared_preferences`. The logical part which is dart only code, should be part of `lib/services` and any UI related logic should be part of `lib/providers` files.

## Frame Overlay Rendering

The overlay uses `CustomPainter` to draw a centered rectangle based on aspect ratio. The area outside the frame is filled with semi-transparent white (polaroid-style). Frame dimensions are calculated to fit within 95% of screen bounds while maintaining the aspect ratio.

## Predefined Aspect Ratios

Defined in `lib/utils/constants.dart` via `AspectRatios` class: 4:3, 16:9, 1:1.

## Photo Capture Flow

Photos are saved to a dedicated "Framatic" album using the `gal` package for gallery access. The frame overlay is rendered onto the captured image before saving.

## Design Approach

- Minimalist interface prioritizing the camera viewfinder
- Use simple black and white colors for theming

## Development workflow notes

- Don't commit the files after finishing a chunk of work. Only commit when asked.

## Git

- Use conventional git commit message
