import 'package:flutter/material.dart';

import '../core/theme/agro_tema.dart';
import 'logo_agro_fields.dart';

/// Diseño V8 campo (13/11/2026, demo de Javier): barra de arriba con la
/// foto del campo al atardecer (Pixabay, uso libre), el logo en un círculo,
/// un velo oscuro a la izquierda para leer el título y una curva dorada
/// abajo. Se usa igual que AppBar.
class BarraCampo extends AppBar {
  BarraCampo({
    super.key,
    super.leading,
    super.automaticallyImplyLeading,
    Widget? title,
    super.actions,
    super.centerTitle,
    super.bottom,
  }) : super(
          toolbarHeight: 84,
          titleSpacing: 4,
          title: title == null ? null : _TituloConLogo(title),
          flexibleSpace: const _FondoCampo(),
          // La curva dorada la dibuja el fondo; se saca la línea recta.
          shape: const Border(),
        );
}

class _TituloConLogo extends StatelessWidget {
  final Widget titulo;

  const _TituloConLogo(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AgroTema.pizarra,
            border: Border.all(color: AgroTema.dorado, width: 2),
          ),
          child: const ClipOval(child: LogoAgroFields(tamano: 48)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DefaultTextStyle.merge(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              shadows: [Shadow(color: Color(0x88000000), blurRadius: 6)],
            ),
            child: titulo,
          ),
        ),
      ],
    );
  }
}

class _FondoCampo extends StatelessWidget {
  const _FondoCampo();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/encabezado_campo.jpg',
          fit: BoxFit.cover,
          alignment: const Alignment(0.6, 0.3),
          // Si la imagen no carga, queda la barra oscura del tema.
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xE62F3B46),
                Color(0x992F3B46),
                Color(0x112F3B46),
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 18,
          child: CustomPaint(painter: _CurvaDorada()),
        ),
      ],
    );
  }
}

/// Curva dorada abajo de la barra (como en la demo).
class _CurvaDorada extends CustomPainter {
  const _CurvaDorada();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Franja crema que "corta" la foto con una curva suave.
    final relleno = Path()
      ..moveTo(0, h * 0.35)
      ..quadraticBezierTo(w * 0.35, h * 1.15, w, h * 0.55)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(relleno, Paint()..color = AgroTema.crema);
    // Línea dorada sobre el borde de la curva.
    final linea = Path()
      ..moveTo(0, h * 0.35)
      ..quadraticBezierTo(w * 0.35, h * 1.15, w, h * 0.55);
    canvas.drawPath(
      linea,
      Paint()
        ..color = AgroTema.dorado
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
