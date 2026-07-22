import 'package:flutter/material.dart';

import '../../models/publicacion_inversion_model.dart';
import '../../services/publicacion_inversion_service.dart';
import 'invertir_screen.dart';

class FeedInversionScreen extends StatelessWidget {
  FeedInversionScreen({super.key});

  final PublicacionInversionService _service =
      PublicacionInversionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oportunidades de Inversión'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<PublicacionInversion>>(
        stream: _service.obtenerPublicaciones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay oportunidades disponibles'),
            );
          }

          final publicaciones = snapshot.data!;

          return ListView.builder(
            itemCount: publicaciones.length,
            itemBuilder: (context, index) {
              final pub = publicaciones[index];

              final progreso = pub.montoRecaudado / pub.montoObjetivo;

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 🏷 Título
                      Text(
                        pub.titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// 📄 Descripción
                      Text(pub.descripcion),

                      const SizedBox(height: 10),

                      /// 💰 Progreso inversión
                      LinearProgressIndicator(
                        value: progreso > 1 ? 1 : progreso,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Recaudado: \$${pub.montoRecaudado} / ${pub.montoObjetivo}',
                      ),

                      const SizedBox(height: 10),

                      /// 🚀 Botón invertir
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InvertirScreen(
                                  publicacionId: pub.publicacionId,
                                ),
                              ),
                            );
                          },
                          child: const Text('Invertir'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}