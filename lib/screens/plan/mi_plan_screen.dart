import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/plan_usuario_model.dart';
import '../../services/plan_service.dart';
import '../../widgets/barra_campo.dart';
import '../produccion/produccion_estilo.dart';

/// GAP-PLAN-01: pantalla "Mi plan". Muestra el plan, qué incluye y, si es
/// Fundador, hasta cuándo es gratis y cuánto pagaría después. Sin cobros:
/// en 2027 nada se corta.
class MiPlanScreen extends StatefulWidget {
  const MiPlanScreen({super.key});

  @override
  State<MiPlanScreen> createState() => _MiPlanScreenState();
}

class _MiPlanScreenState extends State<MiPlanScreen> {
  PlanUsuario? plan;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final p = await PlanService().planDe(uid);
      if (!mounted) return;
      setState(() => plan = p);
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'No se pudo cargar tu plan (¿hay señal?).');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(title: const Text('Mi plan')),
      body: error != null
          ? Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(error!, textAlign: TextAlign.center)))
          : plan == null
              ? const Center(child: CircularProgressIndicator())
              : _contenido(plan!),
    );
  }

  Widget _fila(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(etiqueta,
                style: const TextStyle(color: EstiloProduccion.textoSuave)),
          ),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _contenido(PlanUsuario p) {
    final hoy = DateTime.now();
    final efectivo = p.planEfectivo(hoy);
    final precio = PlanUsuario.precioUsd[efectivo] ?? 0;
    final fundadorPrecio = p.precioFundadorUsd();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TarjetaBlanca(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombrePlan(efectivo),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                if (p.esFundador && p.vigente(hoy))
                  Text(
                    p.fechaFin == null
                        ? 'Plan Fundador: gratis.'
                        : 'Plan Fundador: gratis hasta el ${fechaCorta(p.fechaFin!)}.',
                    style: const TextStyle(
                        color: EstiloProduccion.verde,
                        fontWeight: FontWeight.w600),
                  )
                else if (efectivo == TipoPlan.esencial)
                  const Text('Gratis para siempre.',
                      style: TextStyle(color: EstiloProduccion.verde))
                else
                  Text('US\$ $precio por mes (referencia).'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const TituloSeccion('Qué incluye', icono: Icons.checklist),
        TarjetaBlanca(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Column(
              children: [
                _fila('Campos, expediente, producción, sin señal', 'Sí'),
                _fila('Personas invitadas',
                    textoLimite(PlanUsuario.personasInvitadas[efectivo])),
                _fila('Campos publicados en el mercado',
                    textoLimite(PlanUsuario.camposPublicados[efectivo])),
                _fila('Espacio para archivos',
                    PlanUsuario.espacioArchivos[efectivo] ?? '-'),
              ],
            ),
          ),
        ),
        if (p.esFundador && fundadorPrecio != null) ...[
          const SizedBox(height: 16),
          EstadoVacio(
            icono: Icons.workspace_premium,
            texto: 'Gracias por ser Fundador. Cuando termine el período '
                'gratis podés seguir en Esencial sin pagar, o quedarte en '
                '${nombrePlan(p.plan)} por US\$ $fundadorPrecio por mes '
                '(40% de descuento para siempre). No se cobra nada sin avisarte.',
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'En 2027 los límites solo son informativos: no se corta nada.',
          style: TextStyle(fontSize: 13, color: EstiloProduccion.textoSuave),
        ),
      ],
    );
  }
}
