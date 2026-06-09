import 'dart:math';
import 'package:flutter/material.dart';

/// O Widget que envelopa a nossa pintura customizada
class FuelTechGauge extends StatelessWidget {
  final double valorAtual; // Ex: Pode ser a temperatura, RPM ou Velocidade
  final double valorMaximo;
  final bool isAlerta;

  const FuelTechGauge({
    super.key,
    required this.valorAtual,
    this.valorMaximo = 150.0,
    this.isAlerta = false,
  });

  @override
  Widget build(BuildContext context) {
    // O CustomPaint precisa de um tamanho definido para o Canvas saber os limites
    return SizedBox(
      width: 250,
      height: 250,
      child: CustomPaint(
        // Passamos as propriedades para o nosso pintor
        painter: _GaugePainter(
          percentual: (valorAtual / valorMaximo).clamp(0.0, 1.0),
          isAlerta: isAlerta,
        ),
        // O child fica sobreposto à pintura (ótimo para colocar o texto do número no meio)
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                valorAtual.toInt().toString(),
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier', // Fonte monoespaçada de painel
                  color: isAlerta ? Colors.orange : Colors.white,
                ),
              ),
              const Text(
                'TEMP',
                style: TextStyle(
                  color: Colors.grey,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A classe de baixo nível que executa a renderização dos pixels
class _GaugePainter extends CustomPainter {
  final double percentual;
  final bool isAlerta;

  _GaugePainter({required this.percentual, required this.isAlerta});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. O centro matemático do nosso Canvas
    final centro = Offset(size.width / 2, size.height / 2);
    // 2. O raio vai ser metade da largura disponível, tirando uma margem
    final raio = (size.width / 2) - 10;

    // 3. O retângulo imaginário onde o nosso arco será desenhado
    final rect = Rect.fromCircle(center: centro, radius: raio);

    // No Flutter, os ângulos começam às 3 horas (0 radianos).
    // Para um gauge de carro, começamos às 8 horas (135 graus) e varremos 270 graus.
    const anguloInicial = pi * 0.75;
    const anguloTotal = pi * 1.5;

    // --- PINCEL DO FUNDO (A trilha apagada) ---
    final pincelFundo = Paint()
      ..color = const Color(0xFF2A2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round; // Deixa as pontas arredondadas

    // Desenha o arco de fundo inteiro
    canvas.drawArc(rect, anguloInicial, anguloTotal, false, pincelFundo);

    // --- PINCEL DO PROGRESSO (A trilha acesa) ---
    final pincelProgresso = Paint()
      ..color = isAlerta
          ? Colors.orange
          : const Color(0xFFFF3E3E) // Vermelho FuelTech
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    // Calcula o quanto do arco deve ser preenchido baseado no valor atual
    final anguloProgresso = anguloTotal * percentual;

    // Desenha o arco de progresso por cima
    canvas.drawArc(
      rect,
      anguloInicial,
      anguloProgresso,
      false,
      pincelProgresso,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    // ESSENCIAL PARA PERFORMANCE: Só manda a GPU redesenhar o Canvas se o valor realmente mudou.
    return oldDelegate.percentual != percentual ||
        oldDelegate.isAlerta != isAlerta;
  }
}
