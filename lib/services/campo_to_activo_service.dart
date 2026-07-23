import '../models/campo_model.dart';

import '../models/activos/activo_agro_model_v2.dart';
import '../models/activos/tipo_activo.dart';
import '../models/activos/estado_activo.dart';

import '../models/activos/ubicacion_activo_model.dart';
import '../models/activos/modulo_produccion_model.dart';

import '../models/activos/confianza_activo_model.dart';
import '../models/activos/economia_activo_model.dart';
import '../models/activos/documentacion_activo_model.dart';
import '../models/activos/evaluacion_confianza_model.dart';
import '../models/activos/madurez_activo_model.dart';
import '../models/activos/historial_activo_model.dart';
import '../models/activos/participante_activo_model.dart';




class CampoToActivoService {


  ActivoAgroV2 convertir(Campo campo){


    return ActivoAgroV2(


      activoId:
      campo.campoId,


      nombre:
      campo.nombre,


      descripcion:
      campo.descripcion,



      tipoActivo:
      TipoActivo.otro,



      categorias:
      [
        'campo',
        'agropecuario',
      ],



      ubicacion:

UbicacionActivo(

  pais:
      campo.pais,

  provincia:
      campo.provincia,


  departamento:
      campo.departamento,


  localidad:
      campo.localidad,


  codigoPostal:
      campo.codigoPostal,


  latitud:
      0,


  longitud:
      0,


  superficie:
      campo.hectareas,



  tipoZona:
      'rural',


  zonaHoraria:
      'America/Argentina/Buenos_Aires',


  accesoCaminos:
      '',


  descripcionEntorno:
      '',


  disponibilidadServicios:
      '',


  jurisdiccionLegal:
      '',


  regionProductiva:
      campo.provincia,


  monedaLocal:
      'ARS',

),





      producciones:


      [


        ModuloProduccion(

          dominio:
          'agropecuario',


          actividad:
          'agricultura',


          descripcion:
          'Producción inicial',


          superficie:
          campo.hectareas,


          unidad:
          'hectáreas',


          datos:
          {

            'capacidadProductiva':
            '',

            'infraestructura':
            [],

            'equipamiento':
            [],

          },


        )


      ],




      economia:


      EconomiaActivo(

                objetivoProyecto:
        '',


        etapaProyecto:
        'inicial',


        inversionEsperada:
        0,


        capacidadActual:
        '',


        capacidadProyectada:
        '',


        riesgosIdentificados:
        '',


        origenInformacion:
        'productor',


        responsableDeclaracion:
        campo.propietarioId,


        valorSolicitado:
        0,

        moneda:
        'USD',

        tipoOperacion:
        '',

        capitalRequerido:
        0,

        ingresosEstimados:
        '',

        costosEstimados:
        '',

        rentabilidadDeclarada:
        '',

        periodoEvaluacion:
        '',

        datosEconomicos:
        {},

        fechaActualizacion:
        DateTime.now(),

      ),





      documentacion:


      DocumentacionActivo(

        documentacionCompleta:
        false,

        documentos:
        [],

        certificaciones:
        [],

        permisos:
        [],

        archivos:
        [],

        observaciones:
        '',

        fechaActualizacion:
        DateTime.now(),

      ),





      confianza:


      ConfianzaActivo(

        nivelGeneral:
        campo.verificado ? 50 : 0,


        identidadVerificada:
        campo.verificado,


        documentacionCompleta:
        false,


        cantidadEvidencias:
        0,


        informacionProductivaCompleta:
        false,


        participantesVerificados:
        false,


        ultimaVerificacion:
        DateTime.now(),


        observaciones:
        '',

      ),





      evaluacion:


      EvaluacionConfianza(

        nivelGeneral:
        campo.verificado ? 50 : 0,


        fortalezas:
        [
          'Campo registrado'
        ],


        pendientes:
        [
          'Documentación',
          'Verificación'
        ],


        resumen:
        'Evaluación inicial',


        fechaEvaluacion:
        DateTime.now(),

      ),





      madurez:


      MadurezActivo(

        porcentaje:
        campo.verificado ? 50 : 10,


        faltantes:
        [
          'Documentación'
        ],

      ),





      participantes:
[
  ParticipanteActivo(

    usuarioId:
    campo.propietarioId,

    rol:
    'propietario',

    estado:
    'activo',

    fechaIngreso:
    campo.fechaCreacion,

  ),
],





      propietarioId:
      campo.propietarioId,



      creadorId:
      campo.publicadorId,

            publicadorId:
      campo.publicadorId,


      tipoRelacionPropietario:
      'propietario',


      estadoPublicacion:
      campo.estadoPublicacion,


      visible:
      campo.estadoPublicacion == 'publicado',


      versionDatos:
      ActivoAgroV2.modeloVersion,



      estado:


      campo.estadoPublicacion == 'publicado'

      ?

      EstadoActivo.publicado

      :

      EstadoActivo.borrador,





      historial:
[
  HistorialActivo(

    eventoId:
    'creacion_${campo.campoId}',

    tipoEvento:
    'creacion',

    descripcion:
    'Activo generado desde Campo',

    usuarioId:
    campo.publicadorId,

    fecha:
    campo.fechaCreacion,

  ),
],






      hashActivo:
      campo.hashCampo,





      fechaCreacion:
      campo.fechaCreacion,





      ultimaActualizacion:
      DateTime.now(),


    );


  }


}