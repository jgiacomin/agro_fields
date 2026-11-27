import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/auth/admin.dart';
import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../widgets/barra_campo.dart';
import 'detalle_activo_agro_screen.dart';
import 'publicar_campo_screen.dart';

/// INICIO-BOTONES (27/11/2026): "Mis campos" en lista corta.
/// Una línea por campo (nombre, lugar y estado del aviso), un buscador
/// y el lápiz ✏️ para el dueño, el broker que lo cargó o el admin.
/// Tocar la línea abre la ficha; el lápiz abre "Editar campo".
class MisCamposScreen extends StatefulWidget {
  const MisCamposScreen({super.key});

  @override
  State<MisCamposScreen> createState() => _MisCamposScreenState();
}

class _MisCamposScreenState extends State<MisCamposScreen> {
  final _servicio = ActivoAgroServiceV2();
  final _buscador = TextEditingController();

  List<ActivoAgroV2> _campos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _cargando = false;
        _error = 'No hay una sesión iniciada';
      });
      return;
    }
    try {
      final lista = await _servicio.buscarMisCampos(uid);
      lista.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
      if (!mounted) return;
      setState(() {
        _campos = lista;
        _cargando = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'No se pudieron cargar los campos';
      });
    }
  }

  bool _puedeEditar(ActivoAgroV2 a) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null &&
        (uid == a.propietarioId ||
            uid == a.publicadorId ||
            esAdminPorUid(uid));
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pantalla));
    // Al volver, se recarga (pudo cambiar el nombre, el precio o el estado).
    await _cargar();
  }

  static String _estadoTexto(String estado) {
    switch (estado) {
      case 'publicado':
        return 'Publicado';
      case 'pendienteRevision':
        return 'En revisión';
      case 'pausado':
        return 'Pausado';
      case 'verificado':
        return 'Verificado';
      default:
        return 'Sin publicar';
    }
  }

  static Color _estadoColor(String estado) {
    switch (estado) {
      case 'publicado':
        return AgroTema.azul;
      case 'pendienteRevision':
        return AgroTema.terracotaOscuro;
      default:
        return AgroTema.pizarraSuave;
    }
  }

  List<ActivoAgroV2> get _filtrados {
    final q = _buscador.text.trim().toLowerCase();
    if (q.isEmpty) return _campos;
    return _campos.where((a) {
      final u = a.ubicacion;
      final texto = '${a.nombre} ${u.localidad} ${u.provincia}'.toLowerCase();
      return texto.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtrados;
    return Scaffold(
      backgroundColor: AgroTema.crema,
      appBar: BarraCampo(
        title: Text(_cargando
            ? 'Mis campos'
            : 'Mis campos (${_campos.length})'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!))
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                        children: [
                          TextField(
                            controller: _buscador,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Buscar campo por nombre o lugar',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AgroTema.borde),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: AgroTema.borde),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_campos.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Todavía no tenés campos. Tocá "Cargar campo" '
                                'en el Inicio para empezar.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          else if (lista.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text('Ningún campo coincide con la búsqueda',
                                  textAlign: TextAlign.center),
                            ),
                          for (final a in lista) _fila(a),
                          if (_campos.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                'Tocá el campo para abrir la ficha. '
                                'El lápiz abre "Editar campo".',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AgroTema.pizarraSuave),
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _fila(ActivoAgroV2 a) {
    final u = a.ubicacion;
    final lugar = [u.localidad, u.provincia]
        .where((x) => x.trim().isNotEmpty)
        .join(', ');
    final estado = a.estadoPublicacion;
    final ofertas = a.economia.ofertas.map((o) => o.texto).join(' · ');
    final linea = estado == 'publicado' && ofertas.isNotEmpty
        ? '${_estadoTexto(estado)} · $ofertas'
        : _estadoTexto(estado);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AgroTema.borde),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _abrir(DetalleActivoAgroScreen(activo: a)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AgroTema.pizarra,
                        ),
                      ),
                      if (a.sinDueno)
                        Text(
                          a.duenoDeclarado == null
                              ? 'Campo de un cliente'
                              : 'Cliente: ${a.duenoDeclarado}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AgroTema.azul),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        lugar.isEmpty ? 'Ubicación sin información' : lugar,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: AgroTema.pizarraSuave),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        linea,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _estadoColor(estado),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_puedeEditar(a))
                  IconButton(
                    tooltip: 'Editar campo',
                    onPressed: () => _abrir(PublicarCampoScreen(activo: a)),
                    icon: const Icon(Icons.edit, size: 20),
                    style: IconButton.styleFrom(
                      foregroundColor: AgroTema.terracotaOscuro,
                      side: const BorderSide(color: AgroTema.terracota),
                      minimumSize: const Size(44, 44),
                    ),
                  )
                else
                  const Icon(Icons.chevron_right,
                      color: AgroTema.pizarraSuave),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
