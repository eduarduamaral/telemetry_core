# Feature Specification: Telemetry Peak Hold (Max Temperature)

## 1. Context
The dashboard currently displays real-time engine temperature. We need to add a "Peak Hold" feature that permanently displays the maximum temperature reached during the current session, so the driver can review it after a run.

## 2. Business Rules
- The `TelemetriaBloc` must retain the highest temperature received from the `ISensorRepository`.
- If a new temperature is received and it is HIGHER than the current peak, the peak must be updated.
- If the new temperature is lower, the peak remains the same.

## 3. Architecture & State Management (BLoC)
- **State Update**: Update `TelemetriaAtualizadaState` to include a new property: `final int temperaturaMaxima;`.
- **Bloc Logic**: Inside `_onNovaLeituraRecebida` in `telemetria_bloc.dart`, implement the comparison logic to maintain the peak value.
- **Immutability**: Ensure the new state is emitted using the proper `props` list for the `Equatable` package.

## 4. UI Implementation (DashboardPage)
- Modify the `_DashboardView` inside `dashboard_page.dart`.
- When `TelemetriaAtualizadaState` is active, add a small, distinct visual indicator below the main gauge (or next to it) that displays: "PEAK: [temperaturaMaxima]°C".
- Use a grey or subdued text color for the peak indicator so it doesn't distract from the real-time gauge, but make it clearly readable.

## 5. Constraints
- Do not modify the `ISensorRepository` or the `EventChannel` implementation.
- Keep the `build` method clean. Do not put business logic inside the UI.