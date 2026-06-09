import 'package:flutter/material.dart';
import 'core/di/service_locator.dart';
import 'features/telemetria/ui/dashboard_page.dart';

void main() {
  // Inicializa o Service Locator
  setupDependencies();
  runApp(const TelemetryCorePanelApp());
}

class TelemetryCorePanelApp extends StatelessWidget {
  const TelemetryCorePanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF3E3E),
          secondary: Color(0xFFFFB703),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}
