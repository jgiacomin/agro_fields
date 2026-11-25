import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import '../../widgets/barra_campo.dart';
import '../../core/theme/agro_tema.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otroUsuarioId;

  /// GAP-MERC-01 Parte C: nombre de la otra persona (para el título).
  final String? nombreOtro;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otroUsuarioId,
    this.nombreOtro,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();

  Future<void> enviarMensaje() async {
    if (_controller.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;

    final msg = ChatMessage(
      messageId: '',
      chatId: widget.chatId,
      senderId: user!.uid,
      text: _controller.text.trim(),
      fecha: DateTime.now(),
    );

    await _chatService.enviarMensaje(msg);

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraCampo(
        title: Text(widget.nombreOtro == null || widget.nombreOtro!.isEmpty
            ? 'Chat de negociación'
            : 'Chat con ${widget.nombreOtro}'),
      ),
      body: Column(
        children: [

          /// 💬 LISTA DE MENSAJES
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.obtenerMensajes(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final mensajes = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: mensajes.length,
                  itemBuilder: (context, index) {
                    final msg = mensajes[index];
                    final isMe =
                        msg.senderId ==
                        FirebaseAuth.instance.currentUser!.uid;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.green[200]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg.text),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// ✍ INPUT
          // QA 25/11/2026: franja crema y caja blanca para que se lea bien
          // sobre la foto del fondo.
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AgroTema.crema,
              border: Border(top: BorderSide(color: AgroTema.borde)),
            ),
            child: Row(
              children: [

                Expanded(
  child: TextField(
    controller: _controller,
    onSubmitted: (_) => enviarMensaje(),
    style: const TextStyle(color: AgroTema.pizarra),
    decoration: InputDecoration(
      hintText: 'Escribir mensaje...',
      hintStyle: const TextStyle(color: AgroTema.pizarraSuave),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AgroTema.borde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AgroTema.borde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AgroTema.terracota, width: 2),
      ),
    ),
  ),
),

                const SizedBox(width: 8),

                IconButton(
                  icon: const Icon(Icons.send, color: AgroTema.terracota),
                  onPressed: enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}