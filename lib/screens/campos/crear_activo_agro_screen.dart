import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/activos/tipo_activo.dart';
import '../../models/activos/ubicacion_activo_model.dart';
import '../../models/activos/modulo_produccion_model.dart';
import '../../models/activos/madurez_activo_model.dart';
import '../../models/activos/suelo_activo_model.dart';

import '../../models/activos/estado_activo.dart';
import '../../models/activos/activo_agro_model_v2.dart';

import '../../models/activos/confianza_activo_model.dart';
import '../../models/activos/economia_activo_model.dart';
import '../../models/activos/documentacion_activo_model.dart';
import '../../models/activos/evaluacion_confianza_model.dart';
import '../../models/activos/participante_activo_model.dart';

import '../../core/theme/agro_tema.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_estilo.dart';

/// Diseño "Nuevo campo" (24/11/2026): países de la lista, con su moneda y
/// zona horaria. "Otro" deja escribir el país y usa los valores de antes.
const Map<String, (String moneda, String zonaHoraria)> _paises = {
  'Argentina': ('ARS', 'America/Argentina/Buenos_Aires'),
  'Paraguay': ('PYG', 'America/Asuncion'),
  'Uruguay': ('UYU', 'America/Montevideo'),
};
const String _otroPais = 'Otro';

/// AF-135 (24/11/2026): actividades que se eligen al crear el campo
/// (los mismos nombres que usa Producción) y su tipo de campo.
const List<(String, String, IconData, TipoActivo)> _actividadesCampo = [
  ('ganaderia', 'Ganadería', Icons.pets, TipoActivo.ganadero),
  ('agricultura', 'Agricultura', Icons.grass, TipoActivo.agricola),
  ('avicultura', 'Avicultura', Icons.egg_outlined, TipoActivo.avicola),
  ('piscicultura', 'Piscicultura', Icons.set_meal, TipoActivo.piscicola),
];

/// Superficie escrita como en la región: "2.390", "2.390,5", "150 ha".
/// La misma cuenta sirve para revisar y para guardar.
double? _leerSuperficie(String texto) {
  var t = texto.toLowerCase().trim();
  t = t
      .replaceAll("hectáreas", "")
      .replaceAll("hectareas", "")
      .replaceAll("hectárea", "")
      .replaceAll("hectarea", "")
      .replaceAll("has", "")
      .replaceAll("ha", "")
      .trim();
  t = t.replaceAll(".", "").replaceAll(",", ".");
  return double.tryParse(t);
}

class CrearActivoAgroScreen extends StatefulWidget {
  const CrearActivoAgroScreen({super.key});

  @override
  State<CrearActivoAgroScreen> createState() => _CrearActivoAgroScreenState();
}

class _CrearActivoAgroScreenState extends State<CrearActivoAgroScreen> {
  final _formKey = GlobalKey<FormState>();

  final ActivoAgroServiceV2 _activoService = ActivoAgroServiceV2();

  final nombreController = TextEditingController();

  final paisController = TextEditingController();

  final provinciaController = TextEditingController();

  final departamentoController = TextEditingController();

  final localidadController = TextEditingController();

  final codigoPostalController = TextEditingController();

  final superficieController = TextEditingController();

  final descripcionController = TextEditingController();

  bool loading = false;

  /// Diseño "Nuevo campo": país elegido de la lista.
  String _pais = 'Argentina';

  /// AF-135: actividades marcadas (al menos una).
  final Set<String> _actividades = {};
  bool _faltaActividad = false;

  /// Mixto (agrícola-ganadero) = Ganadería y Agricultura marcadas.
  bool get _esMixto =>
      _actividades.contains('ganaderia') &&
      _actividades.contains('agricultura');

  @override
  void dispose() {
    nombreController.dispose();

    paisController.dispose();

    provinciaController.dispose();

    departamentoController.dispose();

    localidadController.dispose();

    codigoPostalController.dispose();

    superficieController.dispose();

    descripcionController.dispose();

    super.dispose();
  }

  Future<void> guardarActivo() async {
    final formularioBien = _formKey.currentState!.validate();
    // AF-135: hay que marcar al menos una actividad.
    setState(() => _faltaActividad = _actividades.isEmpty);
    if (!formularioBien || _actividades.isEmpty) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final ahora = DateTime.now();

      final nombre = nombreController.text.trim();

      final pais =
          _pais == _otroPais ? paisController.text.trim() : _pais;
      // Moneda y zona horaria según el país (con "Otro", como antes).
      final (moneda, zonaHoraria) =
          _paises[_pais] ?? ('ARS', 'America/Argentina/Buenos_Aires');

      final provincia = provinciaController.text.trim();

      final departamento = departamentoController.text.trim();

      final localidad = localidadController.text.trim();

      final codigoPostal = codigoPostalController.text.trim();

      final superficie = _leerSuperficie(superficieController.text) ?? 0;

      final descripcion = descripcionController.text.trim();

      final hashActivo =
          'AGRO_V2|'
          '${nombre.toLowerCase()}|'
          '${provincia.toLowerCase()}|'
          '${localidad.toLowerCase()}|'
          '$superficie';

      final activo = ActivoAgroV2(
        activoId: ahora.millisecondsSinceEpoch.toString(),

        nombre: nombre,

        descripcion: descripcion,

        // AF-135: una actividad = su tipo; dos o más = mixto.
        tipoActivo: _actividades.length > 1
            ? TipoActivo.mixto
            : _actividadesCampo
                .firstWhere((a) => a.$1 == _actividades.first)
                .$4,

        categorias: ['produccion', 'agro'],

        ubicacion: UbicacionActivo(
          pais: pais,

          provincia: provincia,

          departamento: departamento,

          localidad: localidad,

          codigoPostal: codigoPostal,

          latitud: 0,

          longitud: 0,

          superficie: superficie,

          tipoZona: 'rural',

          zonaHoraria: zonaHoraria,

          accesoCaminos: '',

          descripcionEntorno: '',

          disponibilidadServicios: '',

          jurisdiccionLegal: '',

          regionProductiva: provincia,

          monedaLocal: moneda,
        ),

        // AF-135: una entrada por actividad marcada, en el orden de la
        // lista. "declarada" distingue estas de las viejas (que guardaban
        // "agricultura" siempre).
        producciones: [
          for (final a in _actividadesCampo)
            if (_actividades.contains(a.$1))
              ModuloProduccion(
                actividad: a.$1,
                dominio: 'agropecuario',
                descripcion: 'Declarada al crear el campo',
                datos: {'declarada': true},
                ciclos: [],
              ),
        ],

        economia: EconomiaActivo.inicial(),

        documentacion: DocumentacionActivo.inicial(),

        confianza: ConfianzaActivo(
          nivelGeneral: 0,

          identidadVerificada: false,

          documentacionCompleta: false,
          nivelDocumentacion: 0,

          cantidadEvidencias: 0,
          nivelEvidencias: 0,

          informacionProductivaCompleta: false,
          nivelProduccion: 0,

          nivelInfraestructura: 0,
          infraestructuraVerificada: false,
          cantidadInfraestructuras: 0,

          nivelTecnologia: 0,
          tecnologiaVerificada: false,
          cantidadTecnologias: 0,

          nivelInversion: 0,
          inversionDeclarada: false,
          inversionVerificada: false,
          montoInversionDeclarada: 0,
          monedaInversion: moneda,

          participantesVerificados: false,

          nivelGobernanza: 0,

          ultimaVerificacion: DateTime.now(),
          ultimaEvaluacion: DateTime.now(),

          observaciones: 'Activo creado pendiente de validación',
        ),

        evaluacion: EvaluacionConfianza.inicial(),

        madurez: MadurezActivo(
          porcentaje: 0,

          faltantes: ['Documentación', 'Producción', 'Evidencias'],

          etapa: 'inicial',

          nivelTecnologico: 'bajo',

          preparacionInversion: 'inicial',
        ),
         suelo: SueloActivo.inicial(),

         participantes: [
           ParticipanteActivo(
            usuarioId: user.uid,
            rol: 'propietario',
            estado: 'activo',
            fechaIngreso: ahora,
          ),
         ],

        propietarioId: user.uid,

        creadorId: user.uid,

        publicadorId: user.uid,

        tipoRelacionPropietario: 'propietario',

        estado: EstadoActivo.borrador,

        estadoPublicacion: 'borrador',

        visible: false,

        versionDatos: ActivoAgroV2.modeloVersion,

        historial: [],

        hashActivo: hashActivo,

        fechaCreacion: ahora,

        ultimaActualizacion: ahora,
      );

      debugPrint('ANTES DE GUARDAR ACTIVO');

      debugPrint(activo.toString());

      final mapa = activo.toMap();

      debugPrint('MAPA GENERADO CORRECTAMENTE');

      debugPrint(mapa.toString());

      await _activoService.crearActivo(activo);

      debugPrint('ACTIVO GUARDADO CORRECTAMENTE');

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Campo creado correctamente')),
      );

      Navigator.pop(context);
    } catch (e, stack) {
      debugPrint('ERROR CREANDO ACTIVO:');

      debugPrint(e.toString());

      debugPrint(stack.toString());

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error creando el campo: $e')));
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  /// Diseño "Nuevo campo": casilla blanca con borde redondeado.
  InputDecoration _decoracion(String etiqueta,
      {String? ayuda, String? sufijo}) {
    return InputDecoration(
      labelText: etiqueta,
      hintText: ayuda,
      suffixText: sufijo,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AgroTema.borde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AgroTema.borde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AgroTema.terracota, width: 2),
      ),
    );
  }

  /// Diseño "Nuevo campo": una tarjeta por pregunta.
  Widget _grupo(IconData icono, Color color, String pregunta,
      List<Widget> campos) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TarjetaBlanca(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconoCirculo(icono, color: color, tamano: 40),
                  const SizedBox(width: 10),
                  Text(
                    pregunta,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AgroTema.pizarra,
                    ),
                  ),
                ],
              ),
              for (final c in campos) ...[const SizedBox(height: 12), c],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(title: const Text('Nuevo campo')),

      body: Form(
        key: _formKey,

        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _grupo(Icons.badge_outlined, AgroTema.verde, '¿Cómo se llama?', [
              TextFormField(
                controller: nombreController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoracion('Nombre del campo',
                    ayuda: 'Por ejemplo: La Esperanza'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Escribí el nombre del campo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: descripcionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoracion('Descripción (opcional)',
                    ayuda: 'Qué se hace en el campo, cómo es...'),
              ),
            ]),
            _grupo(Icons.place, AgroTema.azul, '¿Dónde está?', [
              DropdownButtonFormField<String>(
                value: _pais,
                decoration: _decoracion('País'),
                items: [
                  for (final p in [..._paises.keys, _otroPais])
                    DropdownMenuItem(value: p, child: Text(p)),
                ],
                onChanged: (v) => setState(() => _pais = v ?? _pais),
              ),
              if (_pais == _otroPais)
                TextFormField(
                  controller: paisController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _decoracion('¿Qué país?'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Escribí el país';
                    }
                    return null;
                  },
                ),
              TextFormField(
                controller: provinciaController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoracion('Provincia / Departamento'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Escribí la provincia';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: departamentoController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoracion('Partido / Distrito (opcional)'),
              ),
              TextFormField(
                controller: localidadController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoracion('Localidad o pueblo más cercano'),
              ),
              TextFormField(
                controller: codigoPostalController,
                decoration: _decoracion('Código postal (opcional)'),
              ),
            ]),
            // AF-135: qué se hace en el campo.
            _grupo(Icons.agriculture, AgroTema.verde,
                '¿Qué hacés en el campo?', [
              const Text(
                'Marcá una o varias. "Mixto" marca Ganadería y '
                'Agricultura juntas.',
                style: TextStyle(fontSize: 14, color: AgroTema.pizarraSuave),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // "Mixto" = Ganadería + Agricultura juntas (atajo).
                  FilterChip(
                    avatar: Icon(Icons.agriculture,
                        size: 18,
                        color: _esMixto ? Colors.white : AgroTema.verde),
                    label: const Text('Mixto (agrícola-ganadero)'),
                    selected: _esMixto,
                    showCheckmark: false,
                    selectedColor: AgroTema.verde,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _esMixto ? Colors.white : AgroTema.pizarra,
                    ),
                    side: const BorderSide(color: AgroTema.borde),
                    onSelected: (si) => setState(() {
                      if (si) {
                        _actividades.addAll(['ganaderia', 'agricultura']);
                      } else {
                        _actividades.removeAll(['ganaderia', 'agricultura']);
                      }
                      if (_actividades.isNotEmpty) _faltaActividad = false;
                    }),
                  ),
                  for (final (clave, nombre, icono, _) in _actividadesCampo)
                    FilterChip(
                      avatar: Icon(icono,
                          size: 18,
                          color: _actividades.contains(clave)
                              ? Colors.white
                              : AgroTema.verde),
                      label: Text(nombre),
                      selected: _actividades.contains(clave),
                      showCheckmark: false,
                      selectedColor: AgroTema.verde,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _actividades.contains(clave)
                            ? Colors.white
                            : AgroTema.pizarra,
                      ),
                      side: const BorderSide(color: AgroTema.borde),
                      onSelected: (si) => setState(() {
                        si ? _actividades.add(clave) : _actividades.remove(clave);
                        if (_actividades.isNotEmpty) _faltaActividad = false;
                      }),
                    ),
                ],
              ),
              const Text(
                'Próximamente: Apicultura · Frutales',
                style: TextStyle(fontSize: 13, color: AgroTema.pizarraSuave),
              ),
              if (_faltaActividad)
                const Text(
                  'Marcá al menos una actividad',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AgroTema.rojo),
                ),
            ]),
            _grupo(Icons.straighten, AgroTema.terracota,
                '¿Qué tamaño tiene?', [
              TextFormField(
                controller: superficieController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _decoracion('Superficie',
                    ayuda: 'Por ejemplo: 2.390', sufijo: 'ha'),
                validator: (v) {
                  final valor = _leerSuperficie(v ?? '');
                  if (valor == null || valor <= 0) {
                    return 'Escribí las hectáreas (por ejemplo: 150)';
                  }
                  return null;
                },
              ),
            ]),
            const SizedBox(height: 8),
            BotonGrande(
              texto: 'Crear campo',
              icono: Icons.check,
              ocupado: loading,
              onPressed: loading ? null : guardarActivo,
            ),
          ],
        ),
      ),
    );
  }
}
