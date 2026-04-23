# Code Review

## Must Do

1. **Silent frame initialization failure** — If `FrameProvider._initialize()` fails (DB corrupt, etc.), the user sees an empty frame list with no error message and no way to retry. Camera feature becomes unusable since there's no active frame. Should expose an error state like `CameraProvider` does.

2. **No tests** — Zero test files. At minimum, write unit tests for `frame_calculator.dart` (pure functions, easy to test) and `Frame` model (serialization roundtrip, validation). These are the most testable and most critical pieces.

3. ~~**`processPhotoWithFrame` can crash on null active frame**~~ — Not actually a bug. `activeFrame` is captured as a local `final` variable before any `await`, so it can't become null across async gaps.

4. ~~**Temp file leak on app kill**~~ — **DONE** — Added `PhotoService.cleanupTempFiles()` called on app startup.

## Good to Have

1. **Named routes or a router package** — Raw `Navigator.push`/`pop` with `MaterialPageRoute` everywhere. A declarative router (`go_router`) would make navigation clearer and easier to extend.

2. **Frame order persistence race condition** — `orderFrames()` does optimistic UI update + async persist. Rapid reorders could interleave writes. Not likely to cause visible bugs, but a debounce would be cleaner.

3. **Accessibility** — No `Semantics` labels on the capture button, zoom controls, or frame selector. Screen readers can't describe the UI.

4. **Hardcoded strings in UI** — SnackBar messages like `"Frame created"`, `"Photo saved"` are scattered across widgets. Extracting to a constants file (or using `l10n`) would prepare for localization.

5. **`FramaticDB` singleton pattern** — The `_db` field is a plain nullable static. If `initialize()` is called twice concurrently (unlikely but possible), two DB instances could be created. A `Completer` would be safer.

## Learning Lessons

### What went well (carry forward)

- **Feature-based folder structure with data/domain/presentation layers** — Textbook clean architecture. Many production Flutter apps use exactly this.
- **Sealed error classes per feature** — Type-safe, exhaustive, with separate user-facing and debug messages. Better than many professional projects.
- **Isolate for image processing** — Knowing when to offload CPU work off the main thread is a key Flutter skill. `_processImage` being a static top-level function (required for isolates) shows understanding of Dart's concurrency model.
- **`ClipRect` + `OverflowBox` pattern** — Instead of masking or painting, uses Flutter's layout system to clip the camera feed. Idiomatic and performant.
- **Optimistic UI updates** for frame reordering — List reorders instantly while persistence happens in the background. A UX pattern used by every major app.
- **`calculateFrameSize()` as a pure function in a separate file** — No Flutter imports, usable in isolates, easy to test. Exactly how utility logic should be structured.

### Key Flutter/Dart concepts to internalize

1. **Widget lifecycle vs Provider lifecycle** — `CameraProvider` adds itself as a `WidgetsBindingObserver` in the constructor and removes in `dispose()`. Providers outlive individual widgets, so lifecycle observers belong on the Provider, not the Screen.

2. **`ChangeNotifier.dispose()` is critical** — Camera provider disposes the controller and removes the observer. Forgetting this causes memory leaks. Rule: if you `addObserver`, `addListener`, or create a controller, you must clean it up in `dispose()`.

3. **Repository pattern** — `CameraRepository` abstract class with `CameraService` implementation is dependency inversion. The provider depends on the abstraction, not the concrete service. This makes testing possible (you can mock the repository).

4. ~~**`Consumer` vs `context.read` vs `context.watch`**~~ — `Consumer` rebuilds on *any* `notifyListeners()` call, while `Selector`/`context.select()` rebuilds only when specific values change. However, the `Consumer2` in `CameraScreen` wraps a shallow widget tree (a `Column` with ~5 children), the camera preview is a platform view unaffected by widget rebuilds, and the frame calculation isn't repeated on rebuild. The optimization would add real complexity (multiple `Selector` widgets, tuple types) for an unmeasurable gain. **Know `Selector` exists for when you hit actual performance issues** (deep trees, long lists, 60fps animations driven by providers) — but don't prematurely optimize.

5. **Dart records** — `getZoomLimits()` returns `(double, double)`. This is a Dart 3 record -- lightweight, typed, no class needed.

6. **`?.` vs `!` vs null checks** — The pattern of checking `if (x == null) return` then using `x` later is fragile across `await` boundaries. Dart's type promotion doesn't work across async gaps on instance fields -- assign to a local variable instead. (This project does this correctly in `_capturePhoto`.)

### Things vibe coding tends to miss

- **Edge cases** — What happens when the camera list is empty? When the DB is corrupted? When storage is full? AI generates the happy path well but rarely stress-tests boundaries.
- **Testing** — AI rarely writes tests unless asked. Make it a habit to ask for tests alongside features.
- **Performance profiling** — The code looks correct but hasn't been measured. Use Flutter DevTools to check for unnecessary rebuilds (the `Consumer2` wrapping the entire camera screen is a likely candidate).
