import 'package:flutter/material.dart';
import '../../core/supabase_client.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  const ChatPage({super.key, required this.conversationId});
  @override State<ChatPage> createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();
  List<Map<String,dynamic>> messages = [];
  RealtimeChannel? channel;

  Future<void> load() async {
    final data = await supabase.from('messages').select().eq('conversation_id', widget.conversationId).order('created_at');
    setState(() => messages = List<Map<String,dynamic>>.from(data));
    channel = supabase.channel('chat-${widget.conversationId}')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'conversation_id', value: widget.conversationId),
        callback: (payload) {
          if (mounted) setState(() => messages.add(Map<String,dynamic>.from(payload.newRecord)));
        },
      ).subscribe();
  }

  Future<void> send() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    controller.clear();
    await supabase.from('messages').insert({
      'conversation_id': widget.conversationId,
      'sender_id': currentUserId,
      'body': text,
      'message_type': 'text',
    });
  }

  @override void initState() { super.initState(); load(); }
  @override void dispose() { if (channel != null) supabase.removeChannel(channel!); controller.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('محادثة')),
    body: Column(children: [
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: messages.length,
        itemBuilder: (_, i) {
          final m = messages[i];
          final mine = m['sender_id'] == currentUserId;
          return Align(
            alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: mine ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(m['body'] ?? ''),
            ),
          );
        },
      )),
      SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
        child: Row(children: [
          Expanded(child: TextField(controller: controller, textInputAction: TextInputAction.send,
            onSubmitted: (_) => send(), decoration: const InputDecoration(hintText: 'اكتب رسالة...'))),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: send, icon: const Icon(Icons.send)),
        ]),
      )),
    ]),
  );
}
