# Telemetry Core

Real-time vehicle telemetry application built with Flutter, focused on streaming hardware sensor data from the device into a high-performance, GPU-accelerated dashboard.

---

## Project Overview

`telemetry_core` is a real-time telemetry system that ingests data from native hardware sensors (GPS, accelerometer, and engine-related signals) and renders them on a low-latency, automotive-grade dashboard.

The application is designed around three pillars:

- **Reactivity:** every sensor reading is propagated to the UI through a unidirectional event/state pipeline.
- **Resilience:** the BLoC layer guarantees deterministic state transitions and graceful error handling.
- **Performance:** the rendering pipeline is tuned to sustain 60 FPS even under continuous sensor updates.

---

## Architecture Strategy

The project follows **Clean Architecture** principles, with a clear separation between presentation, domain, and data layers.

- **State Management — BLoC:** all UI state is owned by `TelemetriaBloc`, which consumes events (`IniciarMonitoramentoEvent`, `NovaLeituraRecebidaEvent`) and emits immutable states (`TelemetriaInicialState`, `TelemetriaCarregandoState`, `TelemetriaAtualizadaState`, `TelemetriaErroState`). `Equatable` is used to keep state comparisons cheap and predictable.
- **Dependency Injection — GetIt:** the service locator (`core/di/service_locator.dart`) wires repositories and BLoCs, keeping widgets free from construction logic and making the codebase trivially testable.
- **Layered structure:**
  - `lib/features/telemetria/ui/` — Widgets and `CustomPainter` rendering.
  - `lib/features/telemetria/bloc/` — Events, states and BLoC logic.
  - `lib/features/telemetria/repositories/` — Abstractions over the native data sources (`ISensorRepository`).
  - `lib/core/di/` — Composition root for dependencies.

This separation makes business rules (e.g. *Peak Hold* of maximum temperature) independent of both the UI and the underlying platform channel.

---

## Native Integration

Hardware sensors are exposed to Dart through Flutter **`EventChannel`s**, providing a continuous stream of readings without polling.

- The native layer (iOS/Swift, with parity planned for Android/Kotlin) opens the sensor pipelines and pushes events into the `EventChannel`.
- On the Dart side, `ISensorRepository` wraps the channel as a typed `Stream<String>`, isolating the rest of the codebase from platform details.
- The BLoC subscribes to that stream, parses each payload and emits a new immutable state for the UI.

This design keeps platform-specific code thin and replaceable, while the Dart layer treats every sensor as a reactive stream.

---

## Performance Optimization

Real-time telemetry only works if the UI never drops frames. The dashboard was profiled and tuned with **Flutter DevTools** to sustain **60 FPS** during sustained sensor streaming.

Key optimizations:

- **`CustomPainter`-based gauges:** the analog gauge (`FuelTechGauge`) is drawn directly on the GPU through `CustomPainter`, avoiding widget-tree rebuilds for animated elements.
- **Targeted rebuilds:** `BlocBuilder` is scoped to the smallest possible subtree so static parts of the UI never repaint when telemetry updates.
- **Immutable states + `Equatable`:** identical states short-circuit rebuilds entirely.
- **DevTools workflow:** the *Performance* and *CPU Profiler* tabs were used to validate frame budget, jank-free rebuilds and absence of unnecessary `setState` cascades.

---

## Feature Highlight — Peak Hold

The dashboard includes a *Peak Hold* indicator that retains the highest temperature observed during the current session:

- The BLoC keeps the peak in memory and compares each new reading against it.
- The new value is exposed as `temperaturaMaxima` inside `TelemetriaAtualizadaState` and reflected immutably through `Equatable` props.
- The UI displays `PEAK: X°C` in a subdued style so the driver can review the run without distracting from the live gauge.

This feature was specified, implemented and validated end-to-end using the methodology described below.

---

## Development Methodology

This project is developed using **Spec-Driven Development with AI-assisted coding**:

1. **Specification first:** each feature begins as a Markdown spec (see [feature_peak_hold_spec.md](feature_peak_hold_spec.md)) describing context, business rules, architectural constraints and UI expectations.
2. **AI-assisted implementation:** the spec is handed to an AI pair-programmer (GitHub Copilot / Claude) that proposes changes scoped strictly to the spec's contracts (State, BLoC, UI).
3. **Human review & validation:** every diff is reviewed against the spec, type-checked through the Dart analyzer, and validated visually in the running app.
4. **Repeatable process:** new specs follow the same template, ensuring the architecture and quality bar remain consistent as the codebase grows.

This workflow keeps the AI focused on intent rather than guesswork, demonstrates alignment with modern engineering practices, and produces code that is both reviewable and predictable.

---

## Getting Started

Prerequisites:

- Flutter SDK (stable channel)
- Xcode (for iOS sensor integration)
- CocoaPods (`sudo gem install cocoapods`)

Run the app:

```bash
flutter pub get
flutter run
```

Project layout:

```
lib/
├── core/
│   └── di/                    # GetIt service locator
└── features/
    └── telemetria/
        ├── bloc/              # Events, states, BLoC
        ├── repositories/      # ISensorRepository (EventChannel wrapper)
        └── ui/                # DashboardPage + CustomPainter gauges
```

---

## Tech Stack

- **Flutter / Dart** — UI and application logic
- **flutter_bloc + Equatable** — predictable state management
- **GetIt** — dependency injection
- **EventChannel (Swift / Kotlin planned)** — native sensor bridge
- **CustomPainter** — GPU-accelerated dashboard widgets
- **Flutter DevTools** — performance profiling
