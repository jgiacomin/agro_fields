import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_publico_model.dart';
import '../../models/solicitud_contacto_model.dart';
import '../../services/solicitud_contacto_service.dart';
import '../../services/foto_mercado_service.dart';
import '../../enums/solicitud_estado.dart';
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_activo_screen.dart' show nombreActividad;
import '../produccion/produccion_estilo.dart';
import 'campos_screen.dart' show hectareasTexto;
import 'detalle_activo_agro_screen.dart' show emojiActividad;

/// Detalle de un campo del Mercado (lo ve el comprador o arrendatario).
/// GAP-MERC-01 Parte D (24/11/2026): diseño nuevo: fotos arriba con
/// flechas y puntitos (en la PC también), precio grande, tarjetas y el
/// botón "Me interesa" fijo abajo. Fondo liso para que se lea todo.
class DetalleCampoScreen extends StatefulWidget {
  final ActivoPublico activo;

  const DetalleCampoScreen({
    super.key,
    required this.activo,
  });

  @override
  State<DetalleCampoScreen> createState() => _DetalleCampoScreenState();
}

class _DetalleCampoScreenState extends State<DetalleCampoScreen> {
  final SolicitudContactoService solicitudService =
      SolicitudContactoService();

  final PageController _paginas = PageController();
  int _fotoActual = 0;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  Future<void> enviarSolicitud() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    if (user.uid == widget.activo.propietarioId) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Este campo es tuyo: no podés pedir contacto."),
        ),
      );
      return;
    }

    final solicitud = SolicitudContacto(
      solicitudId: '',
      campoId: widget.activo.activoId,
      interesadoId: user.uid,
      propietarioId: widget.activo.propietarioId,
      tipoInteres: 'inversion',
      estado: SolicitudEstado.pendiente,
      fechaCreacion: DateTime.now(),
    );

    try {
      await solicitudService.crearSolicitud(solicitud);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Listo: le avisamos al dueño que te interesa este campo 🚜"),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No se pudo enviar: $e")),
      );
    }
  }

  void _irAFoto(int i) {
    _paginas.animateToPage(i,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final activo = widget.activo;
    final publicado = activo.estadoPublicacion == 'publicado';

    return Scaffold(
      backgroundColor: AgroTema.crema,
      appBar: BarraCampo(title: Text(activo.nombre)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (activo.fotos.isNotEmpty) _fotos(activo.fotos),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activo.nombre,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AgroTema.pizarra,
                  ),
                ),
                const SizedBox(height: 8),
                if (activo.ofertas.isEmpty)
                  const Text(
                    "Precio: consultar al dueño",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AgroTema.terracota,
                    ),
                  ),
                for (final o in activo.ofertas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      o.texto,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AgroTema.terracota,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                ResumenNumeros([
                  (
                    activo.superficie > 0
                        ? hectareasTexto(activo.superficie)
                        : '—',
                    'hectáreas',
                    Icons.straighten,
                    AgroTema.azul,
                  ),
                  (
                    '${activo.nivelConfianza}%',
                    'confianza',
                    Icons.verified,
                    AgroTema.verde,
                  ),
                ]),
                const SizedBox(height: 16),
                _tarjeta(Icons.place, AgroTema.terracota, "Ubicación", [
                  Text(
                    [activo.localidad, activo.provincia, activo.pais]
                        .where((x) => x.trim().isNotEmpty)
                        .join(', '),
                    style:
                        const TextStyle(fontSize: 15, color: AgroTema.pizarra),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Ubicación aproximada. La exacta la comparte el dueño.",
                    style:
                        TextStyle(fontSize: 13, color: AgroTema.pizarraSuave),
                  ),
                ]),
                if (activo.producciones.isNotEmpty)
                  _tarjeta(Icons.agriculture, AgroTema.verde, "Producción", [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final a in activo.producciones)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AgroTema.verdeClaro,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${emojiActividad(a)} ${nombreActividad(a)}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AgroTema.verde,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ]),
                if (activo.descripcion.trim().isNotEmpty)
                  _tarjeta(Icons.notes, AgroTema.azul, "Descripción", [
                    Text(
                      activo.descripcion,
                      style: const TextStyle(
                          fontSize: 15, height: 1.4, color: AgroTema.pizarra),
                    ),
                  ]),
                _tarjeta(Icons.verified_user, AgroTema.pizarra,
                    "Confianza del expediente", [
                  _barra("Expediente completo", activo.madurezPorcentaje),
                  const SizedBox(height: 8),
                  _barra("Confianza de los datos",
                      activo.nivelConfianza.toDouble()),
                  const SizedBox(height: 8),
                  const Text(
                    "Muestra cuánta información cargó el dueño y cuánta tiene "
                    "documento o verificación. Agro Fields conecta, no "
                    "garantiza: la decisión y el riesgo son de las partes.",
                    style: TextStyle(
                        fontSize: 13, height: 1.35, color: AgroTema.pizarraSuave),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: BotonGrande(
            texto: "Me interesa",
            icono: Icons.handshake,
            onPressed: publicado
                ? enviarSolicitud
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Este campo todavía no está publicado"),
                      ),
                    );
                  },
          ),
        ),
      ),
    );
  }

  /// Fotos arriba, a todo lo ancho: se pasan con las flechas, con los
  /// puntitos o arrastrando (dedo en el celular y mouse en la PC).
  Widget _fotos(List<String> fotos) {
    final varias = fotos.length > 1;
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          ScrollConfiguration(
            // Flutter no arrastra con el mouse por defecto: se habilita.
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: PageView(
              controller: _paginas,
              onPageChanged: (i) => setState(() => _fotoActual = i),
              children: [
                for (final ruta in fotos) FotoDelMercado(ruta: ruta, alto: 260),
              ],
            ),
          ),
          if (varias) ...[
            if (_fotoActual > 0)
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _flecha(Icons.chevron_left,
                      () => _irAFoto(_fotoActual - 1)),
                ),
              ),
            if (_fotoActual < fotos.length - 1)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _flecha(Icons.chevron_right,
                      () => _irAFoto(_fotoActual + 1)),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < fotos.length; i++)
                    GestureDetector(
                      onTap: () => _irAFoto(i),
                      child: Container(
                        width: i == _fotoActual ? 12 : 8,
                        height: i == _fotoActual ? 12 : 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _fotoActual
                              ? Colors.white
                              : Colors.white54,
                          border: Border.all(color: Colors.black26),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_fotoActual + 1} / ${fotos.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _flecha(IconData icono, VoidCallback alTocar) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icono, color: Colors.white, size: 30),
        onPressed: alTocar,
      ),
    );
  }

  Widget _tarjeta(
      IconData icono, Color color, String titulo, List<Widget> hijos) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TarjetaBlanca(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconoCirculo(icono, color: color, tamano: 38),
                  const SizedBox(width: 10),
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AgroTema.pizarra,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...hijos,
            ],
          ),
        ),
      ),
    );
  }

  Widget _barra(String texto, double porcentaje) {
    final p = porcentaje.clamp(0, 100).toDouble();
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(texto,
              style:
                  const TextStyle(fontSize: 14, color: AgroTema.pizarraSuave)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: p / 100,
              minHeight: 8,
              backgroundColor: AgroTema.borde,
              color: AgroTema.verde,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text('${p.round()}%',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AgroTema.pizarra)),
      ],
    );
  }
}
