# Project Overview

Framatic is a Flutter mobile app that helps artists frame landscapes by providing live camera viewfinder overlays with customizable aspect ratios. It replaces physical frame cutouts artists traditionally use for composition.

## State Management

Uses **Provider** pattern for state management with the widgets.
Uses **sqflite** package for storing frame data locally.
Uses **shared_preferences** package for storing the order of the frame according to user's preference.

## Core Layers

**Models** (`lib/models/`)

**Services** (`lib/services/`)

**Providers** (`lib/providers/`)

**Screens** (`lib/screens/`)

**Widgets** (`lib/widgets/`)

**Database** (`lib/db/`)

## Frame Overlay Rendering

The overlay uses `CustomPainter` to draw a centered rectangle based on aspect ratio. The frame surrounding the camera preview and clicked pictures look solid white(polaroid-style). Frame dimensions are calculated to fit within 95% of screen bounds while maintaining the aspect ratio.

## Predefined Aspect Ratios

When user opens the application for the first time, there are some pre-defined frames available i.e. 4:3, 16:9, 1:1. Added while creating the database for the first time.

## Photo Capture Flow

Photos are saved to a dedicated "Framatic" album using the `gal` package for gallery access. The frame overlay is rendered onto the captured image before saving.

## Design Approach

- Minimalist interface prioritizing the camera viewfinder
- Use simple black and white colors for theming

## Development workflow notes

- Don't commit the files after finishing a chunk of work. Only commit when asked.
- Try to think critically when asked questions instead of agreeing with it.

## Git

- Use conventional git commit message
