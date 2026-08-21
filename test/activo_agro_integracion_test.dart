import 'package:flutter_test/flutter_test.dart';

import '../lib/models/activos/activo_agro_model_v2.dart';
import '../lib/models/activos/modulo_produccion_model.dart';
import '../lib/models/activos/ciclo_productivo_model.dart';
import '../lib/models/activos/ubicacion_activo_model.dart';
import '../lib/models/activos/economia_activo_model.dart';
import '../lib/models/activos/documentacion_activo_model.dart';
import '../lib/models/activos/confianza_activo_model.dart';
import '../lib/models/activos/evaluacion_confianza_model.dart';
import '../lib/models/activos/madurez_activo_model.dart';
import '../lib/models/activos/tipo_activo.dart';
import '../lib/models/activos/estado_activo.dart';

void main() {
  test(
    'Activo Agro V2 conserva producción y ciclos',
    () {
      final ciclo = CicloProductivo(
        cicloId: 'ciclo_001',
        activoAgroId: 'activo_001',
        moduloProduccionId: 'prod_001',
        fechaInicio: DateTime(2026, 1, 1),
        fechaFin: DateTime(2026, 6, 30),
        campania: '2026',
        produccionObtenida: 12000,
        unidadProduccion: 'kg',
        observaciones: 'Ciclo de prueba',
      );

      final modulo = ModuloProduccion(
        id: 'prod_001',
        activoAgroId: 'activo_001',
        dominio: 'agricultura',
        actividad: 'Soja',
        descripcion: 'Producción de soja',
        superficie: 100,
        unidad: 'hectareas',
        capacidadActual: 100,
        capacidadMaxima: 150,
        activo: true,
        datos: {
          'campania': '2026',
        },
        ciclos: [
          ciclo,
        ],
      );

      final activo = ActivoAgroV2(
        activoId: 'activo_001',
        nombre: 'Campo de prueba',
        descripcion: 'Activo Agro de prueba',
        tipoActivo: TipoActivo.agricola,
        categorias: ['agricultura'],
        ubicacion: UbicacionActivo(
          pais: 'Argentina',
          provincia: 'Buenos Aires',
          departamento: '',
          localidad: 'La Plata',
          codigoPostal: '',
          latitud: -34.9,
          longitud: -57.9,
          superficie: 100,
          regionProductiva: 'Buenos Aires',
          tipoZona: 'rural',
          descripcionEntorno: '',
          accesoCaminos: '',
          disponibilidadServicios: '',
          jurisdiccionLegal: '',
          zonaHoraria: 'America/Argentina/Buenos_Aires',
          monedaLocal: 'ARS',
        ),
        producciones: [
          modulo,
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
          monedaInversion: 'ARS',
          participantesVerificados: false,
          nivelGobernanza: 0,
          ultimaVerificacion: DateTime.now(),
          ultimaEvaluacion: DateTime.now(),
          observaciones: '',
        ),
        evaluacion: EvaluacionConfianza.inicial(),
       madurez: MadurezActivo(
  porcentaje: 30,
  faltantes: [
    'Permisos',
    'Evidencias',
  ],
  etapa: 'inicial',
  nivelTecnologico: 'bajo',
  preparacionInversion: 'inicial',
),
        participantes: [],
        propietarioId: 'usuario_001',
        creadorId: 'usuario_001',
        publicadorId: 'usuario_001',
        tipoRelacionPropietario: 'propietario',
        estado: EstadoActivo.borrador,
        estadoPublicacion: 'borrador',
        visible: false,
        historial: [],
        hashActivo: 'hash_001',
        versionDatos: 2,
        fechaCreacion: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
      );

      final mapa = activo.toMap();

      final recuperado = ActivoAgroV2.fromMap(
        mapa,
        activo.activoId,
      );

      expect(
        recuperado.producciones.length,
        1,
      );

      expect(
        recuperado.producciones.first.actividad,
        'Soja',
      );

      expect(
        recuperado.producciones.first.ciclos.length,
        1,
      );

      expect(
        recuperado.producciones.first.ciclos.first.cicloId,
        'ciclo_001',
      );

      expect(
        recuperado.producciones.first.ciclos.first.produccionObtenida,
        12000,
      );

      expect(
        recuperado.producciones.first.ciclos.first.unidadProduccion,
        'kg',
      );
    },
  );
}