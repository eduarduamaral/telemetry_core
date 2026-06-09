import 'dart:async';
import 'package:flutter/services.dart';

abstract class ISensorRepository {
  Stream<String> lerTelemetriaGps();
}

class SensorRepository implements ISensorRepository {
  static const EventChannel _gpsChannel = EventChannel(
    'fueltech/telemetria_gps',
  );

  @override
  Stream<String> lerTelemetriaGps() {
    return _gpsChannel.receiveBroadcastStream().map(
      (dynamic event) => event.toString(),
    );
  }
}
