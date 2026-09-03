import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/oportunidad_agro_model.dart';
import 'package:agro_fields/services/oportunidad_agro_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.useFirestoreEmulator(
      '127.0.0.1',
      8080,
    );
  });

  test(
    'OportunidadAgroService crea y recupera una oportunidad desde Firestore Emulator',
    () async {
      final service = OportunidadAgroService();

      final fecha = DateTime(2026, 9, 1, 10, 0);

      final oportunidad = OportunidadAgro(
        oportunidadId: 'op-emulator-001',
        creadorId: 'usuario-test-001',
        titulo: 'Oportunidad de prueba Emulator',
        descripcion: 'Prueba de persistencia en Firestore Emulator.',
        actividad: 'agricultura',
        productoServicio: 'produccion agricola',
        activoId: null,
        ladoMercado: 'demanda',
        tipoOportunidad: 'produccion_bajo_contrato',
        pais: 'Argentina',
        provinciaEstado: 'Buenos Aires',
        localidad: 'La Plata',
        ubicacionEspecifica: '',
        queSeNecesita: 'Produccion agricola',
        volumenRequerido: '100 toneladas',
        capacidadProductiva: '',
        periodicidad: 'anual',
        plazo: '12 meses',
        condiciones: 'Prueba tecnica',
        requisitos: ['Produccion'],
        participantes: ['usuario-test-001'],
        montoObjetivo: null,
        montoMinimo: null,
        inversionEstimada: null,
        costosEstimados: null,
        produccionEstimada: 100,
        precioEstimado: null,
        ingresosEstimados: null,
        resultadoEstimado: null,
        moneda: 'USD',
        periodoCalculo: 'anual',
        fuenteEconomica: 'prueba',
        documentacion: [],
        evidencias: [],
        estado: 'activa',
        confianza: 0,
        madurez: 0,
        historial: [],
        fechaCreacion: fecha,
        fechaActualizacion: fecha,
      );

      final idCreado =
          await service.crearOportunidad(oportunidad);

      expect(idCreado, 'op-emulator-001');

      final recuperada =
          await service.obtenerOportunidadPorId(
        'op-emulator-001',
      );

      expect(recuperada, isNotNull);
      expect(
        recuperada!.oportunidadId,
        'op-emulator-001',
      );
      expect(
        recuperada.titulo,
        'Oportunidad de prueba Emulator',
      );
      expect(
        recuperada.estado,
        'activa',
      );
      expect(
        recuperada.ladoMercado,
        'demanda',
      );
      expect(
        recuperada.activoId,
        isNull,
      );
    },
  );
}
