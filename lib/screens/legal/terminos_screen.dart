import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/legal/textos_legales.dart';
import '../../core/theme/agro_tema.dart';
import '../../services/legal_service.dart';
import '../produccion/produccion_estilo.dart';

/// GAP-LEGAL-01: Términos de uso y Política de privacidad.
///
/// Una sola pantalla para dos usos:
///  * [pedirAceptacion] = true: al entrar, con la casilla y el botón
///    "Acepto". Al aceptar llama a [alAceptar].
///  * [pedirAceptacion] = false: desde el menú, solo para leer.
class TerminosScreen extends StatefulWidget {
  final bool pedirAceptacion;
  final VoidCallback? alAceptar;

  const TerminosScreen({
    super.key,
    this.pedirAceptacion = false,
    this.alAceptar,
  });

  @override
  State<TerminosScreen> createState() => _TerminosScreenState();
}

class _TerminosScreenState extends State<TerminosScreen> {
  final LegalService _legal = LegalService();
  bool leido = false;
  bool guardando = false;

  Future<void> _aceptar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => guardando = true);
    try {
      await _legal.registrarAceptacion(uid);
      widget.alAceptar?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AgroTema.pizarra,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: !widget.pedirAceptacion,
          title: const Text('Términos y privacidad'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AgroTema.terracota,
            tabs: [
              Tab(text: 'Términos de uso'),
              Tab(text: 'Privacidad'),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: AgroTema.terracotaClaro,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Versión $versionLegal',
                style: const TextStyle(fontSize: 13, color: AgroTema.pizarra),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  TextoLegal(textoTerminos),
                  TextoLegal(textoPrivacidad),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: widget.pedirAceptacion
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: leido,
                        onChanged: (v) => setState(() => leido = v ?? false),
                        title: const Text(
                          'Leí y acepto los Términos de uso y la Política de '
                          'privacidad, incluida la guarda de mis datos en '
                          'servidores de Estados Unidos.',
                          style: TextStyle(fontSize: 14, height: 1.35),
                        ),
                      ),
                      BotonGrande(
                        texto: 'Acepto',
                        ocupado: guardando,
                        onPressed: leido ? _aceptar : null,
                      ),
                      TextButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        child: const Text('No acepto, salir'),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// Muestra un texto legal con formato simple: "### " título, "- " viñeta,
/// **negrita**. Sin paquetes extra.
class TextoLegal extends StatelessWidget {
  final String texto;
  const TextoLegal(this.texto, {super.key});

  /// Letra grande y bien oscura para leer con anteojos o al sol.
  static const TextStyle _estiloTexto =
      TextStyle(fontSize: 16, height: 1.5, color: AgroTema.pizarra);

  static List<TextSpan> _conNegrita(String linea) {
    final partes = linea.split('**');
    return [
      for (var i = 0; i < partes.length; i++)
        TextSpan(
          text: partes[i],
          style: i.isOdd ? const TextStyle(fontWeight: FontWeight.w700) : null,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    for (final linea in texto.trim().split('\n')) {
      final l = linea.trimRight();
      if (l.isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else if (l.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            l.substring(4),
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AgroTema.pizarra),
          ),
        ));
      } else if (l.startsWith('- ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  ', style: _estiloTexto),
              Expanded(
                child: Text.rich(
                  TextSpan(children: _conNegrita(l.substring(2))),
                  style: _estiloTexto,
                ),
              ),
            ],
          ),
        ));
      } else {
        widgets.add(Text.rich(
          TextSpan(children: _conNegrita(l)),
          style: _estiloTexto,
        ));
      }
    }
    // QA T4-06 (20/11/2026): el texto quedaba sobre la foto del pasto y
    // costaba leerlo. Ahora va sobre fondo liso, con letra más grande.
    return ColoredBox(
      color: const Color(0xFFFFFAF2),
      child: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: widgets,
        ),
      ),
    );
  }
}
