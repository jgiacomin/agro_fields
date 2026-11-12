import 'package:flutter/material.dart';

import '../core/theme/agro_tema.dart';

/// Logo de Agro Fields V8 dibujado por la app (sin archivos de imagen):
/// un sol sobre los surcos del campo, dentro de un círculo.
/// Tomado de la referencia visual aprobada el 10/11/2026.
class LogoAgroFields extends StatelessWidget {
  final double tamano;

  const LogoAgroFields({super.key, this.tamano = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final centro = Offset(r, r);
    final circulo = Rect.fromCircle(center: centro, radius: r);

    // Todo se dibuja recortado dentro del círculo.
    canvas.save();
    canvas.clipPath(Path()..addOval(circulo));

    // Cielo de atardecer.
    canvas.drawRect(
      circulo,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4A261), Color(0xFFFBE3C8)],
        ).createShader(circulo),
    );

    // Sol sobre el horizonte.
    canvas.drawCircle(
      Offset(r, r * 0.95),
      r * 0.36,
      Paint()..color = AgroTema.terracota,
    );

    // Surcos del campo: franjas curvas alternando pizarra y terracota.
    final colores = [
      AgroTema.pizarra,
      const Color(0xFFE8B48A),
      AgroTema.terracota,
      const Color(0xFFF6D9BE),
      AgroTema.pizarra,
    ];
    for (var i = 0; i < colores.length; i++) {
      final arriba = r * (1.0 + i * 0.2);
      final path = Path()
        ..moveTo(0, arriba + r * 0.12)
        ..quadraticBezierTo(
            r * 0.9, arriba - r * 0.22, size.width, arriba - r * 0.02)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = colores[i]);
    }

    canvas.restore();

    // Borde suave.
    canvas.drawCircle(
      centro,
      r - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
