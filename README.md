# Telemetry Core

Sistema de telemetria em tempo real em Flutter, com ingestão via sensores nativos e renderização de alta performance.

Real-time telemetry system in Flutter, with native sensor ingestion and high-performance rendering.

---

## Português

### Visão geral

`telemetry_core` é a base tecnológica para sistemas de monitoramento automotivo ou industrial. Foco em ingestão de dados em alta frequência (GPS e sensores nativos) e exibição visual através de componentes gráficos customizados, sustentando 60 FPS.

### Arquitetura

Projeto estruturado em Clean Architecture, com desacoplamento entre lógica de negócio e plataforma.

- State management com BLoC: lógica de negócio isolada em `TelemetriaBloc`, estados imutáveis e `Equatable` para evitar rebuilds redundantes.
- Injeção de dependência com GetIt: composição feita em `service_locator`, a UI não conhece implementações concretas.
- Camadas:
  - `lib/features/telemetria/ui/` — apresentação e renderização (`CustomPainter`).
  - `lib/features/telemetria/bloc/` — domínio (eventos, estados, regras).
  - `lib/features/telemetria/repositories/` — abstrações sobre as fontes de dados nativas.

### Integração nativa

Sensores são expostos ao Dart via `EventChannel`s do Flutter. O código nativo (Swift no iOS) abre um stream contínuo e o `ISensorRepository` o encapsula como `Stream<String>`, eliminando polling e mantendo latência mínima.

### Performance

Pipeline de renderização tunado com Flutter DevTools para sustentar 60 FPS em Apple Silicon.

- `CustomPainter` para o `telemetry_coreGauge`, desenhando direto no `Canvas` da GPU.
- `BlocBuilder` com escopo reduzido para reconstruir apenas a subárvore necessária.
- Análise contínua de Raster Thread vs UI Thread em modo `--profile` para manter o orçamento de 16 ms.

### Feature: Peak Hold

Retenção do valor máximo (`temperaturaMaxima`) durante a sessão:

1. O BLoC compara cada nova leitura com o pico armazenado.
2. O novo estado é emitido de forma imutável, com o campo incluído em `props`.
3. A UI exibe o indicador `PEAK: X°C` sem lógica de negócio no widget.

### Metodologia

Spec-Driven Development com codificação assistida por IA:

1. Specification first: cada feature começa como spec em Markdown (ver [feature_peak_hold_spec.md](feature_peak_hold_spec.md)).
2. Implementação assistida por GitHub Copilot, escopada estritamente ao contrato da spec.
3. Revisão humana, análise estática e validação visual antes de mergear.

### Testes

Como toda fonte de dados depende de uma interface (`ISensorRepository`), é trivial injetar mocks para testar o BLoC e usar Golden Tests para validar o gauge sem regressões visuais.

### Roadmap

- [ ] Android Platform Channels (Kotlin).
- [ ] Suíte de testes unitários para o BLoC.
- [ ] Reset de sessão (limpar picos).
- [ ] Labels dinâmicos de alta precisão no `CustomPainter`.

### Como rodar

Pré-requisitos: Flutter SDK (stable) e Xcode.

```bash
flutter pub get
flutter run --profile
```

---

## English

### Overview

`telemetry_core` is the technical foundation for automotive and industrial monitoring systems. It focuses on high-frequency data ingestion (GPS and native sensors) and visualization through custom graphics components, sustaining 60 FPS.

### Architecture

The project follows Clean Architecture, decoupling business logic from platform code.

- State management with BLoC: logic is isolated in `TelemetriaBloc`, using immutable states and `Equatable` to avoid redundant rebuilds.
- Dependency injection with GetIt: composition lives in `service_locator`; widgets never depend on concrete implementations.
- Layers:
  - `lib/features/telemetria/ui/` — presentation and rendering (`CustomPainter`).
  - `lib/features/telemetria/bloc/` — domain (events, states, rules).
  - `lib/features/telemetria/repositories/` — abstractions over native data sources.

### Native integration

Sensors are exposed to Dart via Flutter `EventChannel`s. The native side (Swift on iOS) opens a continuous stream and `ISensorRepository` wraps it as a `Stream<String>`, removing polling and keeping latency minimal.

### Performance

The rendering pipeline is profiled with Flutter DevTools to sustain 60 FPS on Apple Silicon.

- `CustomPainter` powers `telemetry_coreGauge`, drawing directly to the GPU `Canvas`.
- `BlocBuilder` is scoped to the smallest subtree that depends on telemetry state.
- Raster vs UI thread analysis in `--profile` mode keeps each frame within the 16 ms budget.

### Feature: Peak Hold

The BLoC retains the maximum temperature observed during the session:

1. Each new reading is compared against the stored peak.
2. The new state is emitted immutably, with the field included in `props`.
3. The UI renders the `PEAK: X°C` indicator with no business logic inside the widget.

### Methodology

Spec-Driven Development with AI-assisted coding:

1. Specification first: every feature starts as a Markdown spec (see [feature_peak_hold_spec.md](feature_peak_hold_spec.md)).
2. Implementation assisted by GitHub Copilot, scoped strictly to the spec contract.
3. Human review, static analysis and visual validation before merging.

### Testing

Because every data source depends on an interface (`ISensorRepository`), it is trivial to inject mocks to unit-test the BLoC and use Golden Tests to detect visual regressions in the gauge.

### Roadmap

- [ ] Android Platform Channels (Kotlin).
- [ ] Unit test suite for the BLoC.
- [ ] Session reset (clear peaks).
- [ ] High-precision dynamic labels in `CustomPainter`.

### Getting started

Requirements: Flutter SDK (stable) and Xcode.

```bash
flutter pub get
flutter run --profile
```

## 📱 App Demo

<div align="center">
  <table>
    <tr>
      <td><b>iOS (Simulador)</b></td>
      <td><b>Android (Emulador)</b></td>
    </tr>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/2d9475c5-c967-4fd4-8b75-0286fa97eba6" width="300" /></td>
      <td><img src="https://github.com/user-attachments/assets/1aca264b-977e-4676-bc39-c9a3da50679b" width="300" /></td>
    </tr>
  </table>
</div>