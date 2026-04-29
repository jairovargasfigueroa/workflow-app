# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app
flutter run

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Lint
flutter analyze

# Generate JSON serialization code (required after modifying models)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation
dart run build_runner watch --delete-conflicting-outputs

# Get dependencies
flutter pub get
```

## Architecture

This is a Flutter app for managing "trámites" (administrative procedures/paperwork). It uses a layered architecture:

**Entry points:**
- `lib/main.dart` — bootstraps the app, calls `runApp`
- `lib/app.dart` — root widget that wires up `MultiProvider` and `GoRouter`

**Layers:**
- `lib/config/` — app-wide configuration: `theme.dart` (ThemeData) and `routes.dart` (GoRouter route definitions)
- `lib/models/` — data models using `json_serializable`; each model has a `.g.dart` generated file (run `build_runner` to regenerate after changes)
- `lib/services/` — API communication via `Dio`; `api_service.dart` is the HTTP client
- `lib/providers/` — `ChangeNotifier` classes (consumed via `provider` package) that hold state and call services
- `lib/screens/` — screen widgets organized by feature subfolder (e.g., `home/`, `tramite_detail/`)
- `lib/widgets/` — reusable widgets shared across screens

**Data flow:** Screens consume Providers via `context.watch` / `context.read`. Providers call Services. Services use Dio for HTTP.

## Key dependencies

| Package | Purpose |
|---|---|
| `provider` | State management (ChangeNotifier) |
| `dio` | HTTP client |
| `go_router` | Declarative routing |
| `json_annotation` + `json_serializable` | JSON model generation |
| `build_runner` | Code generation (for models) |
