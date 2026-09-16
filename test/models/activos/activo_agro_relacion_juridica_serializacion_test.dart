import 'package:flutter_test/flutter_test.dart';
import 'package:agro_fields/models/activos/activo_agro_model_v2.dart';
import 'package:agro_fields/models/activos/derecho_activo_model.dart';
import 'package:agro_fields/models/activos/relacion_juridica_model.dart';
import 'package:agro_fields/models/activos/economia_activo_model.dart';
import 'package:agro_fields/models/activos/documentacion_activo_model.dart';
import 'package:agro_fields/models/activos/confianza_activo_model.dart';
import 'package:agro_fields/models/activos/evaluacion_confianza_model.dart';
import 'package:agro_fields/models/activos/factor_confianza_model.dart';
import 'package:agro_fields/models/activos/madurez_activo_model.dart';
import 'package:agro_fields/models/activos/suelo_activo_model.dart';
import 'package:agro_fields/models/activos/ubicacion_activo_model.dart';
import 'package:agro_fields/models/activos/modulo_produccion_model.dart';
import 'package:agro_fields/models/activos/participante_activo_model.dart';
import 'package:agro_fields/models/activos/historial_activo_model.dart';
import 'package:agro_fields/models/activos/tipo_activo.dart';
import 'package:agro_fields/models/activos/estado_activo.dart';
void main() {
  test(
    'ActivoAgroV2 conserva RelacionJuridica en toMap/fromMap',
    () {
      final fecha = DateTime(2026, 9, 16);
      final derecho = DerechoActivo(
        derechoId: 'derecho_001',
        activoAgroId: 'activo_001',
        tipoDerecho: 'dominio',
        descripcionTipo: 'Dominio sobre inmueble rural',
        tipoObjeto: 'inmueble',
        descripcionObjeto: 'Campo rural identificado como activo_001',
        alcanceTerritorial: const AlcanceTerritorial(
          tipoAlcance: 'total',
          descripcion: 'Comprende la totalidad del activo',
          superficieAfectada: 1000,
          unidadSuperficie: 'ha',
          referenciaGeografica: 'Parcela rural de prueba',
        ),
        tipoInstrumento: 'titulo',
        identificadorInstrumento: 'TIT-001',
        emisor: 'Registro de prueba',
        fechaInicio: DateTime(2020, 1, 1),
        fechaFin: null,
        estado: 'vigente',
        condiciones: const [
          'Sin restricciones declaradas',
          'Sujeto a verificacion documental',
        ],
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );
      final relacion = RelacionJuridica(
        relacionId: 'relacion_001',
        derechoId: 'derecho_001',
        sujetoId: 'sujeto_001',
        tipoSujeto: 'persona',
        rol: 'titular',
        fechaInicio: DateTime(2020, 1, 1),
        fechaFin: null,
        estado: 'vigente',
        condiciones: const [
          'Titularidad declarada',
          'Sujeta a verificacion documental',
        ],
      );
      final factor = FactorConfianza(
        nivel: 0,
        descripcion: '',
        evidencias: const [],
        fechaActualizacion: fecha,
      );
      final activo = ActivoAgroV2(
        activoId: 'activo_001',
        nombre: 'Activo de prueba RWA-02',
        descripcion: 'Activo utilizado para prueba de relacion juridica',
        tipoActivo: TipoActivo.otro,
        categorias: const ['prueba'],
        ubicacion: UbicacionActivo(
          pais: 'Argentina',
          provincia: 'Buenos Aires',
          departamento: '',
          localidad: '',
          codigoPostal: '',
          latitud: -34.9,
          longitud: -57.9,
          superficie: 1000,
          tipoZona: 'rural',
          zonaHoraria: 'America/Argentina/Buenos_Aires',
          accesoCaminos: '',
          descripcionEntorno: '',
          disponibilidadServicios: '',
          jurisdiccionLegal: '',
          regionProductiva: '',
          monedaLocal: 'USD',
        ),
        producciones: const <ModuloProduccion>[],
        economia: EconomiaActivo(
          objetivoProyecto: '',
          etapaProyecto: '',
          inversionEsperada: 0,
          capacidadActual: '',
          capacidadProyectada: '',
          riesgosIdentificados: '',
          origenInformacion: '',
          responsableDeclaracion: '',
          valorSolicitado: 0,
          moneda: 'USD',
          tipoOperacion: '',
          capitalRequerido: 0,
          ingresosEstimados: '',
          costosEstimados: '',
          rentabilidadDeclarada: '',
          periodoEvaluacion: '',
          datosEconomicos: const [],
          fechaActualizacion: fecha,
        ),
        documentacion: DocumentacionActivo(
          documentacionCompleta: false,
          documentos: const [],
          certificaciones: const [],
          permisos: const [],
          archivos: const [],
          observaciones: '',
          fechaActualizacion: fecha,
        ),
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
          monedaInversion: 'USD',
          participantesVerificados: false,
          nivelGobernanza: 0,
          ultimaVerificacion: fecha,
          ultimaEvaluacion: fecha,
          observaciones: '',
        ),
        evaluacion: EvaluacionConfianza(
          nivelGeneral: 0,
          documental: factor,
          productivo: factor,
          economico: factor,
          legal: factor,
          profesional: factor,
          fortalezas: const [],
          pendientes: const [],
          resumen: '',
          responsable: '',
          fechaEvaluacion: fecha,
        ),
        madurez: MadurezActivo(
          porcentaje: 0,
          faltantes: const [],
          etapa: '',
          nivelTecnologico: '',
          preparacionInversion: '',
        ),
        suelo: SueloActivo.inicial(),
        participantes: const <ParticipanteActivo>[],
        derechos: [derecho],
        relacionesJuridicas: [relacion],
        propietarioId: 'usuario_001',
        creadorId: 'usuario_001',
        publicadorId: 'usuario_001',
        tipoRelacionPropietario: 'propietario',
        estado: EstadoActivo.borrador,
        estadoPublicacion: 'borrador',
        visible: false,
        historial: const <HistorialActivo>[],
        hashActivo: 'hash-rwa-02-relacion',
        versionDatos: 1,
        fechaCreacion: fecha,
        ultimaActualizacion: fecha,
      );
      final map = activo.toMap();
      final reconstruido = ActivoAgroV2.fromMap(
        map,
        'activo_001',
      );
      expect(reconstruido.relacionesJuridicas.length, 1);
      final relacionReconstruida =
          reconstruido.relacionesJuridicas.first;
      expect(relacionReconstruida.relacionId, 'relacion_001');
      expect(relacionReconstruida.derechoId, 'derecho_001');
      expect(relacionReconstruida.sujetoId, 'sujeto_001');
      expect(relacionReconstruida.tipoSujeto, 'persona');
      expect(relacionReconstruida.rol, 'titular');
      expect(relacionReconstruida.estado, 'vigente');
      expect(
        relacionReconstruida.condiciones,
        const [
          'Titularidad declarada',
          'Sujeta a verificacion documental',
        ],
      );
      expect(
        relacionReconstruida.fechaInicio,
        DateTime(2020, 1, 1),
      );
      expect(relacionReconstruida.fechaFin, isNull);
    },
  );
}
