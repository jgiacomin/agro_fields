import 'tipo_activo.dart';
import 'estado_activo.dart';
import 'ubicacion_activo_model.dart';
import 'modulo_produccion_model.dart';
import 'madurez_activo_model.dart';

import 'activo_agro_model_v2.dart';

import 'confianza_activo_model.dart';
import 'economia_activo_model.dart';
import 'documentacion_activo_model.dart';
import 'evaluacion_confianza_model.dart';

class ActivoAgroTestData {


  static ActivoAgroV2 crearGranjaAvicola(){


    return ActivoAgroV2(

      activoId: "test_001",


      nombre:
      "Granja Avícola Los Tilos",


      descripcion:
      "Producción de huevos con sistema semi intensivo",


      tipoActivo:
      TipoActivo.avicola,


      categorias:
      [
        "huevos",
        "avicultura",
        "produccion animal"
      ],


      ubicacion:

UbicacionActivo(

  pais:
  "Argentina",

  provincia:
  "Buenos Aires",

  departamento:
  "",

  localidad:
  "Ensenada",

  codigoPostal:
  "",

  latitud:
  -34.86,

  longitud:
  -57.91,

  superficie:
  5,


  tipoZona:
  "rural",

  zonaHoraria:
  "America/Argentina/Buenos_Aires",

  accesoCaminos:
  "",

  descripcionEntorno:
  "",

  disponibilidadServicios:
  "",

  jurisdiccionLegal:
  "",

  regionProductiva:
  "Buenos Aires",

  monedaLocal:
  "ARS",

),



      producciones:
      [

        ModuloProduccion(

  dominio:
  "produccion animal",

  actividad:
  "Gallinas ponedoras",

  descripcion:
  "Producción de huevos frescos",

  datos:
  {

    "cantidadAves":5000,

    "sistema":
    "semi intensivo",

    "produccionDiaria":
    "3500 huevos"

  },

)

      ],



      economia:
      EconomiaActivo(
        
        objetivoProyecto:
"Producción avícola",

etapaProyecto:
"inicial",

inversionEsperada:
0,

capacidadActual:
"5000 aves",

capacidadProyectada:
"",

riesgosIdentificados:
"",

origenInformacion:
"productor",

responsableDeclaracion:
"usuario_test_001",
  
        valorSolicitado:0,

        moneda:"USD",

        tipoOperacion:"",

        capitalRequerido:0,

        ingresosEstimados:"",

        costosEstimados:"",

        rentabilidadDeclarada:"",

        periodoEvaluacion:"",

        datosEconomicos:{},

        fechaActualizacion:
        DateTime.now(),

      ),



      documentacion:
      DocumentacionActivo(

        documentacionCompleta:false,

        documentos:[],

        certificaciones:[],

        permisos:[],

        archivos:[],

        observaciones:"Activo nuevo",

        fechaActualizacion:
        DateTime.now(),

      ),



      confianza:
      ConfianzaActivo(

        nivelGeneral:20,

        identidadVerificada:false,

        documentacionCompleta:false,

        cantidadEvidencias:0,

        informacionProductivaCompleta:true,

        participantesVerificados:false,

        ultimaVerificacion:
        DateTime.now(),

        observaciones:
        "Activo creado",

      ),



      evaluacion:
      EvaluacionConfianza(

        nivelGeneral:20,

        fortalezas:
        [
          "Producción definida"
        ],

        pendientes:
        [
          "Documentación",
          "Verificación"
        ],

        resumen:
        "Activo inicial",

        fechaEvaluacion:
        DateTime.now(),

      ),



      madurez:
      MadurezActivo(

        porcentaje:30,

        faltantes:
        [
          "Permisos",
          "Evidencias"
        ],

      ),



      participantes:
      [],

      propietarioId: 'usuario_test_001',

creadorId: 'usuario_test_001',

publicadorId: 'usuario_test_001',

tipoRelacionPropietario:
'propietario',

estadoPublicacion:
'borrador',

visible:
false,

versionDatos:
ActivoAgroV2.modeloVersion,

estado:
EstadoActivo.borrador,



      historial:
      [],



      hashActivo:
      "hash_test_001",



      fechaCreacion:
      DateTime.now(),



      ultimaActualizacion:
      DateTime.now(),

    );

  }

}