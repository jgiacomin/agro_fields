import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:agro_fields/firebase_options.dart';
import 'package:agro_fields/screens/campos/crear_activo_agro_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseFirestore firestore;
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
        'No se pudo crear el usuario anónimo del test',
      );
    }

    usuarioId = user.uid;

    firestore = FirebaseFirestore.instance;

    firestore.useFirestoreEmulator(
      '10.0.2.2',
      8080,
    );
  });

  testWidgets(
    'Crear Activo Agro registra al propietario como participante inicial',
    (tester) async {
      final nombreActivo =
         'Activo Test Participante ${DateTime.now().millisecondsSinceEpoch}';
      await tester.pumpWidget(
        const MaterialApp(
          home: CrearActivoAgroScreen(),
        ),
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Nombre del activo',
        ),
        nombreActivo,
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'País',
        ),
        'Argentina',
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Provincia',
        ),
        'Buenos Aires',
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Departamento / Estado',
        ),
        'La Plata',
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Localidad',
        ),
        'La Plata',
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Código postal',
        ),
        '1900',
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Superficie hectáreas',
        ),
        '10',
      );

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Descripción',
        ),
        'Activo de prueba para validar participante inicial.',
      );

      await tester.tap(
        find.widgetWithText(
          ElevatedButton,
          'Crear Activo Agro',
        ),
      );

      await tester.pumpAndSettle(
        const Duration(seconds: 3),
      );

      final snapshot = await firestore
          .collection('activos_agro')
          .where(
            'propietarioId',
            isEqualTo: usuarioId,
          )
          .where(
            'nombre',
            isEqualTo: nombreActivo,
          )
          .limit(1)
          .get();

      expect(
        snapshot.docs,
        hasLength(1),
      );

      final data = snapshot.docs.single.data();

      expect(
        data['propietarioId'],
        equals(usuarioId),
      );

      expect(
        data['participantes'],
        isA<List>(),
      );

      final participantes =
          List<Map<String, dynamic>>.from(
        (data['participantes'] as List).map(
          (participante) =>
              Map<String, dynamic>.from(participante),
        ),
      );

      expect(
        participantes,
        hasLength(1),
      );

      expect(
        participantes.first['usuarioId'],
        equals(usuarioId),
      );

      expect(
        participantes.first['rol'],
        equals('propietario'),
      );

      expect(
        participantes.first['estado'],
        equals('activo'),
      );

      expect(
        participantes.first['fechaIngreso'],
        isNotNull,
      );
    },
  );
}
