import 'package:get_it/get_it.dart';
import '../../features/telemetria/repositories/sensor_repository.dart';
import '../../features/telemetria/bloc/telemetria_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<ISensorRepository>(() => SensorRepository());

  getIt.registerFactory<TelemetriaBloc>(
    () => TelemetriaBloc(sensorRepository: getIt<ISensorRepository>()),
  );
}
