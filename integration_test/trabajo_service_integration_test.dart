import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/trabajo_operacional_model.dart';
import 'package:agro_fields/services/trabajo_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TrabajoService V1 - persistencia, consulta y auditoría', (
    tester,
  ) async {
    print('TRABAJO-01: inicio del test');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('TRABAJO-02: Firebase inicializado');

    await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);

    print('TRABAJO-03: Auth Emulator configurado');

    final credential = await FirebaseAuth.instance.signInAnonymously();

    final usuario = credential.user;

    expect(usuario, isNotNull);
    expect(usuario!.uid, isNotEmpty);

    print('TRABAJO-04: usuario autenticado uid=${usuario.uid}');

    FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);

    print('TRABAJO-05: Firestore Emulator configurado');

    final db = FirebaseFirestore.instance;

    final activoAgroId =
        'activo-test-trabajo-${DateTime.now().millisecondsSinceEpoch}';

    await db.collection('activos_agro').doc(activoAgroId).set({
      'activoId': activoAgroId,
      'propietarioId': usuario.uid,
      'publicadorId': usuario.uid,
      'creadorId': usuario.uid,
    });

    print('TRABAJO-06: Activo de prueba creado');

    final trabajo = TrabajoOperacional(
      trabajoId: '',
      activoAgroId: activoAgroId,
      moduloProduccionId: 'prod-test-001',
      cicloId: 'ciclo-test-001',
      familiaActividad: 'PRODUCCIÓN',
      tipoActividad: 'SIEMBRA',
      descripcion: 'Siembra de lote productivo',
      objetivo: 'Implantar cultivo en lote planificado',
      fechaInicioPlanificada: DateTime(2026, 10, 5),
      fechaFinPlanificada: DateTime(2026, 10, 6),
      estadoTrabajo: TrabajoOperacional.estadoPlanificado,
      fechaInicioReal: null,
      fechaFinReal: null,
      responsableId: usuario.uid,
      objetoTipo: 'PARCELA',
      objetoId: 'parcela-test-001',
      cantidadAlcance: 200,
      unidadAlcance: 'ha',
      observaciones: 'Prueba de integración V1',
      creadoPor: usuario.uid,
      fechaCreacion: DateTime.now(),
      ultimaActualizacion: DateTime.now(),
    );

    final trabajoService = TrabajoService();

    final trabajoId = await trabajoService.crearTrabajo(
      trabajo: trabajo,
      usuarioId: usuario.uid,
    );

    expect(trabajoId, isNotEmpty);

    print('TRABAJO-07: trabajo creado id=$trabajoId');

    final trabajoLeido = await trabajoService.obtenerTrabajoPorId(trabajoId);

    expect(trabajoLeido, isNotNull);
    expect(trabajoLeido!.trabajoId, trabajoId);
    expect(trabajoLeido.activoAgroId, activoAgroId);
    expect(trabajoLeido.tipoActividad, 'SIEMBRA');

    print('TRABAJO-08: trabajo recuperado por ID');

    final trabajos = await trabajoService.obtenerTrabajosPorActivo(
      activoAgroId,
    );

    expect(trabajos.any((item) => item.trabajoId == trabajoId), isTrue);

    print('TRABAJO-09: consulta por activo correcta');

    final auditoria = await db
        .collection('auditoria_activos')
        .where('activoId', isEqualTo: activoAgroId)
        .get();

    final auditoriaTrabajo = auditoria.docs.where((doc) {
      final data = doc.data();

      return data['modulo'] == 'trabajo_operacional' &&
          data['accion'] == 'crear_trabajo' &&
          data['elementoAfectado'] == trabajoId &&
          data['referencia'] == trabajoId;
    }).toList();

    expect(auditoriaTrabajo, isNotEmpty);

    print('TRABAJO-10: auditoría registrada correctamente');
  });
}
