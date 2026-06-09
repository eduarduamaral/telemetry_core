import 'package:equatable/equatable.dart';

abstract class TelemetriaEvent extends Equatable {
  const TelemetriaEvent();

  @override
  List<Object> get props => [];
}

class IniciarMonitoramentoEvent extends TelemetriaEvent {}

class NovaLeituraRecebidaEvent extends TelemetriaEvent {
  final String leituraGps;

  const NovaLeituraRecebidaEvent(this.leituraGps);

  @override
  List<Object> get props => [leituraGps];
}
