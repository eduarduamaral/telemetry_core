import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/sensor_repository.dart';
import 'telemetria_event.dart';
import 'telemetria_state.dart';

class TelemetriaBloc extends Bloc<TelemetriaEvent, TelemetriaState> {
  final ISensorRepository _sensorRepository;
  StreamSubscription<String>? _sensorSubscription;
  int _temperaturaMaxima = 0;

  TelemetriaBloc({required this._sensorRepository})
    : super(TelemetriaInicialState()) {
    on<IniciarMonitoramentoEvent>(_onIniciarMonitoramento);
    on<NovaLeituraRecebidaEvent>(_onNovaLeituraRecebida);
  }

  void _onIniciarMonitoramento(
    IniciarMonitoramentoEvent event,
    Emitter<TelemetriaState> emit,
  ) {
    emit(TelemetriaCarregandoState());
    _temperaturaMaxima = 0;

    _sensorSubscription?.cancel();

    _sensorSubscription = _sensorRepository.lerTelemetriaGps().listen(
      (telemetria) {
        add(NovaLeituraRecebidaEvent(telemetria));
      },
      onError: (error) {
        emit(TelemetriaErroState('Falha na leitura do GPS: $error'));
      },
    );
  }

  void _onNovaLeituraRecebida(
    NovaLeituraRecebidaEvent event,
    Emitter<TelemetriaState> emit,
  ) {
    final partes = event.leituraGps.split(',');
    if (partes.length < 2) {
      emit(TelemetriaErroState('Leitura GPS invalida: ${event.leituraGps}'));
      return;
    }

    final latitude = double.tryParse(partes[0].trim());
    final longitude = double.tryParse(partes[1].trim());

    if (latitude == null || longitude == null) {
      emit(
        TelemetriaErroState(
          'Nao foi possivel fazer parse do GPS: ${event.leituraGps}',
        ),
      );
      return;
    }

    final temperaturaAtual = latitude.abs().round();
    if (temperaturaAtual > _temperaturaMaxima) {
      _temperaturaMaxima = temperaturaAtual;
    }

    emit(
      TelemetriaAtualizadaState(
        latitude: latitude,
        longitude: longitude,
        temperaturaMaxima: _temperaturaMaxima,
      ),
    );
  }

  @override
  Future<void> close() {
    _sensorSubscription?.cancel();
    return super.close();
  }
}
