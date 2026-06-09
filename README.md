Telemetry Core
telemetry_core é um sistema de telemetria em tempo real projetado para capturar dados de sensores de hardware nativos e renderizá-los em um painel de alta performance e baixa latência.
🎯 Project Overview
O telemetry_core é a base tecnológica para sistemas de monitoramento automotivo ou industrial. O foco principal é a ingestão de dados em alta frequência (via GPS/Sensores Nativos) e a exibição visual através de componentes gráficos customizados, garantindo uma experiência de 60 FPS constantes.
🏗️ Architecture Strategy
O projeto segue os princípios de Clean Architecture, garantindo desacoplamento entre lógica de negócio e plataforma.
•	State Management (BLoC): A lógica de negócio é isolada no TelemetriaBloc. Utilizamos estados imutáveis e o pacote Equatable para garantir que a UI só seja redesenhada quando o dado sofrer alteração real, evitando processamento redundante.
•	Dependency Injection (GetIt): O service_locator garante que as dependências sejam injetadas de forma desacoplada, permitindo que a camada de UI não conheça a implementação concreta dos repositórios.
•	Layered Structure:
•	lib/features/telemetria/ui/: Camada de apresentação e componentes de renderização (CustomPainter).
•	lib/features/telemetria/bloc/: Camada de domínio (regras de negócio e gestão de estados).
•	lib/features/telemetria/repositories/: Abstrações (Interfaces) que permitem a troca fácil entre sensores reais e mocks.
🌉 Native Integration
Para evitar o polling ineficiente, utilizamos Flutter EventChannels. O código nativo (Swift no iOS) abre um stream contínuo que envia dados diretamente para a camada Dart, onde o ISensorRepository os encapsula como um Stream<String>. Isso garante latência mínima na comunicação hardware-aplicação.
🚀 Performance Optimization
O dashboard foi tunado via Flutter DevTools para garantir fluidez total em dispositivos com Apple Silicon (M1/Pro).
•	CustomPainter: Desenvolvemos o FuelTechGauge desenhando diretamente no Canvas da GPU. Isso evita o custo de reconstrução da árvore de widgets, garantindo um desempenho superior em animações rápidas.
•	Optimized Render Pipeline: O uso do --profile mode e a análise de Raster vs UI Thread garantiram que todos os componentes fiquem dentro do budget de 16ms, eliminando jank (travamentos).
💡 Feature Highlight: Peak Hold
Implementamos um sistema de retenção de pico máximo (temperaturaMaxima) que funciona de forma reativa:
	1.	O BLoC compara cada nova leitura com o pico armazenado.
	2.	O estado é emitido com a nova métrica.
	3.	A UI consome esse dado sem necessidade de lógica complexa de comparação no componente visual.
🛠️ Development Methodology
Este projeto adota o Spec-Driven Development (SDD):
	1.	Specification First: Toda funcionalidade nasce de uma especificação escrita em Markdown (feature_peak_hold_spec.md).
	2.	AI-Assisted Implementation: Utilizamos o GitHub Copilot para implementar as especificações.
	3.	Human-in-the-Loop: Todo código gerado passa por revisão crítica, validação de tipagem e testes de performance, garantindo que a IA mantenha os padrões arquiteturais do projeto.
🧪 Testing Strategy
A arquitetura foi desenhada pensando em testabilidade. Como dependemos de uma interface (ISensorRepository), é trivial injetar um MockRepository para realizar testes unitários no BLoC (verificando se o Peak Hold é calculado corretamente) e testes de widget utilizando Golden Tests para garantir que o mostrador gráfico não sofra regressões visuais.
🗺️ Roadmap
•	[ ] Implementar Android Platform Channels (Kotlin).
•	[ ] Criar suíte de testes unitários para a lógica do BLoC.
•	[ ] Adicionar funcionalidade de "Reset de Sessão" (limpar picos).
•	[ ] Refinar CustomPainter com labels dinâmicos de alta precisão.
💻 Getting Started
	1.	Prerequisites: Flutter SDK (Stable), Xcode.
	2.	Setup: flutter pub get
	3.	Run: flutter run --profile
Este repositório é um estudo de caso sobre arquitetura reativa, integração nativa e performance em Flutter.