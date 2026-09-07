import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:agro_fields/firebase_options.dart';

import 'package:agro_fields/models/inversion_model.dart';
import 'package:agro_fields/services/inversion_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
  });

  testWidgets('Paso 11 - registra inversion y actualiza monto recaudado', (
    tester,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final inversionService = InversionService();

    final sufijo = DateTime.now().microsecondsSinceEpoch.toString();

    final publicacionId = 'pub-inversion-emulator-$sufijo';

    final inversorId = 'inversor-test-$sufijo';

    final fecha = DateTime(2026, 9, 4, 10, 0);

    await firestore
        .collection('publicaciones_inversion')
        .doc(publicacionId)
        .set({
          'campoId': 'campo-test-$sufijo',
          'propietarioId': 'propietario-test-$sufijo',
          'titulo': 'Oportunidad de inversión test',
          'descripcion': 'Publicación creada para integración.',
          'montoObjetivo': 100000.0,
          'montoRecaudado': 25000.0,
          'estado': 'activa',
          'fecha': Timestamp.fromDate(fecha),
        });

    final inversion = Inversion(
      inversionId: '',
      inversorId: inversorId,
      publicacionId: publicacionId,
      monto: 15000.0,
      porcentaje: 10.0,
      estado: 'activa',
      fecha: fecha,
    );

    await inversionService.crearInversion(inversion);

    final inversionesSnapshot = await firestore
        .collection('inversiones')
        .where('publicacionId', isEqualTo: publicacionId)
        .get();

    expect(inversionesSnapshot.docs.length, 1);

    final inversionRegistrada = inversionesSnapshot.docs.first.data();

    expect(inversionRegistrada['inversorId'], inversorId);

    expect(inversionRegistrada['monto'], 15000.0);

    expect(inversionRegistrada['publicacionId'], publicacionId);

    final publicacionSnapshot = await firestore
        .collection('publicaciones_inversion')
        .doc(publicacionId)
        .get();

    expect(publicacionSnapshot.exists, true);

    final publicacionData = publicacionSnapshot.data()!;
    expect(publicacionData['montoRecaudado'], 40000.0);
  });
}
