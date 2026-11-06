
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/models/activos/recurso_agro_model.dart';
import 'package:agro_fields/models/activos/movimiento_stock_model.dart';
import 'package:agro_fields/services/recurso_service.dart';
import 'package:agro_fields/services/movimiento_stock_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;
  late RecursoService recursoService;
  late MovimientoStockService movimientoStockService;
  late String usuarioId;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseAuth.instance.useAuthEmulator(
      '10.0.2.2',
      9099,
    );

    final credential =
        await FirebaseAuth.instance.signInAnonymously();

    final user = credential.user;

    if (user == null) {
      throw Exception(
        'No se pudo crear el usuario anÃ³nimo del test',
      );
    }

    usuarioId = user.uid;

    firestore = FirebaseFirestore.instance;
    firestore.useFirestoreEmulator(
      '10.0.2.2',
      8080,
    );

    recursoService = RecursoService();
    movimientoStockService = MovimientoStockService();
  });

  testWidgets(
    'MovimientoStockService registra entrada y actualiza saldo',
    (tester) async {
      final sufijo =
          DateTime.now().millisecondsSinceEpoch.toString();

      final activoAgroId = 'activo-test-stock-$sufijo';

      await firestore
          .collection('activos_agro')
          .doc(activoAgroId)
          .set({
        'propietarioId': usuarioId,
        'publicadorId': usuarioId,
        'nombre': 'Activo Agro prueba de stock',
      });

      final recurso = RecursoAgro(
        recursoId: '',
        activoAgroId: activoAgroId,
        tipo: 'insumo',
        nombre: 'Insumo de prueba',
        descripcion:
            'Recurso para integraciÃ³n de movimientos de stock',
        unidad: 'unidad',
        cantidadActual: 1,
        cantidadMinima: 0,
        estado: 'disponible',
        moduloProduccionId: 'produccion-test-$sufijo',
        numeroSerie: 'STOCK-TEST-$sufijo',
        observaciones:
            'Prueba de integraciÃ³n Firestore Emulator',
      );

      final recursoId =
          await recursoService.crearRecurso(
        recurso: recurso,
        usuarioId: usuarioId,
        rol: 'productor',
      );

      final movimientoId = 'movimiento-test-$sufijo';

      final movimiento = MovimientoStock(
        movimientoId: movimientoId,
        activoAgroId: activoAgroId,
        recursoId: recursoId,
        tipoMovimiento: 'entrada',
        cantidad: 2,
        unidad: 'unidad',
        fechaMovimiento: DateTime.now(),
        motivo: 'Entrada de prueba de integraciÃ³n',
      );

     final movimientoIdRegistrado =
       await movimientoStockService.registrarMovimiento(
        movimiento: movimiento,
         usuarioId: usuarioId,
          rol: 'productor',
        );

      // Verificar el saldo actualizado: 1 + 2 = 3.
      final recursoFinal = await firestore
          .collection('recursos')
          .doc(recursoId)
          .get();

      expect(recursoFinal.exists, isTrue);
      expect(
        (recursoFinal.data()!['cantidadActual'] as num)
            .toDouble(),
        3,
      );

      // Verificar la persistencia del movimiento.
      final movimientoFinal = await firestore
          .collection('movimientos_stock')
          .doc(movimientoIdRegistrado)
          .get();

      expect(movimientoFinal.exists, isTrue);

      // Verificar que exista la auditorÃ­a asociada.
      final auditoria = await firestore
          .collection('auditoria_activos')
          .where('referencia', isEqualTo: movimientoIdRegistrado)
          .get();

      expect(auditoria.docs, isNotEmpty);
    },
  );
}
