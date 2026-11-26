import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/auth/admin.dart';
import '../core/theme/agro_tema.dart';
import '../screens/admin/admin_screen.dart';
import '../services/admin_service.dart';

/// GAP-MERC-01 G (25/11/2026): aviso del Inicio para el administrador.
/// "Tenés N publicaciones para aprobar" y lleva directo a Administración.
/// Si no hay pendientes (o no es admin), no muestra nada.
/// Solo decide qué se MUESTRA: lo que protege son las reglas de Firebase.
class AvisoPublicacionesAdmin extends StatefulWidget {
  const AvisoPublicacionesAdmin({super.key});

  @override
  State<AvisoPublicacionesAdmin> createState() =>
      _AvisoPublicacionesAdminState();
}

class _AvisoPublicacionesAdminState extends State<AvisoPublicacionesAdmin> {
  int pendientes = 0;

  bool get _esAdmin =>
      esAdminPorUid(FirebaseAuth.instance.currentUser?.uid);

  @override
  void initState() {
    super.initState();
    _contar();
  }

  Future<void> _contar() async {
    if (!_esAdmin) return;
    try {
      final lista = await AdminService().publicacionesPendientes();
      if (!mounted) return;
      setState(() => pendientes = lista.length);
    } catch (_) {
      // Si no se puede contar, no se muestra nada (no asusta sin motivo).
      if (!mounted) return;
      setState(() => pendientes = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_esAdmin || pendientes == 0) return const SizedBox.shrink();
    final texto = pendientes == 1
        ? 'Tenés 1 publicación para aprobar'
        : 'Tenés $pendientes publicaciones para aprobar';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: AgroTema.terracotaClaro,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminScreen()),
            );
            // Al volver, se vuelve a contar (por si aprobaste alguna).
            _contar();
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AgroTema.terracota,
                  child: Icon(Icons.fact_check_outlined, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    texto,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AgroTema.pizarra,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AgroTema.terracota),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
