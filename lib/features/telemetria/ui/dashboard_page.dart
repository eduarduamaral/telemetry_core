import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/service_locator.dart';
import '../bloc/telemetria_bloc.dart';
import '../bloc/telemetria_event.dart';
import '../bloc/telemetria_state.dart';
import 'widgets/fueltech_gauge.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Injetamos o BLoC na árvore de Widgets usando o GetIt
    return BlocProvider(
      create: (context) =>
          getIt<TelemetriaBloc>()..add(IniciarMonitoramentoEvent()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FUELTECH TELEMETRY CORE (BLoC)'),
        backgroundColor: const Color(0xFF1A1A1A),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'TELEMETRIA GPS',
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // O BlocBuilder escuta as mudanças de estado e reconstrói apenas este trecho
              BlocBuilder<TelemetriaBloc, TelemetriaState>(
                builder: (context, state) {
                  if (state is TelemetriaCarregandoState ||
                      state is TelemetriaInicialState) {
                    return const CircularProgressIndicator();
                  }

                  if (state is TelemetriaErroState) {
                    return Text(
                      state.mensagem,
                      style: const TextStyle(color: Colors.red, fontSize: 24),
                    );
                  }

                  if (state is TelemetriaAtualizadaState) {
                    final isAlerta =
                        state.latitude.abs() > 90 || state.longitude.abs() > 180;

                    return Column(
                      children: [
                        // Substituímos o Container simples pelo nosso componente desenhado na GPU
                        FuelTechGauge(
                          valorAtual: state.latitude.abs().clamp(0.0, 150.0),
                          isAlerta: isAlerta,
                        ),

                        const SizedBox(height: 30),

                        Text(
                          'LAT: ${state.latitude.toStringAsFixed(6)} | LON: ${state.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        Text(
                          isAlerta
                              ? '⚠️ ALERTA DE SISTEMA'
                              : 'SISTEMA ONLINE',
                          style: TextStyle(
                            color: isAlerta ? Colors.orange : Colors.green,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    );
                  }

                  // Fallback seguro
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
