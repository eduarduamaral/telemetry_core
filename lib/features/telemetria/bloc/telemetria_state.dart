import 'package:equatable/equatable.dart';

abstract class TelemetriaState extends Equatable {
  const TelemetriaState();

  @override
  List<Object> get props => [];
}

class TelemetriaInicialState extends TelemetriaState {}

class TelemetriaCarregandoState extends TelemetriaState {}

class TelemetriaAtualizadaState extends TelemetriaState {
  final double latitude;
  final double longitude;

  const TelemetriaAtualizadaState({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}

class TelemetriaErroState extends TelemetriaState {
  final String mensagem;
  const TelemetriaErroState(this.mensagem);

  @override
  List<Object> get props => [mensagem];
}
