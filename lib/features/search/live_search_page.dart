import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/supabase_client.dart';

class LiveSearchPage extends StatefulWidget {
  const LiveSearchPage({super.key});
  @override State<LiveSearchPage> createState() => _LiveSearchPageState();
}

class _LiveSearchPageState extends State<LiveSearchPage> {
  RealtimeChannel? channel;
  String status = 'لم يبدأ البحث';
  bool searching = false;
  List<Map<String, dynamic>> matches = [];
  String? gender;
  String? country;

  Future<void> start() async {
    await stop();
    setState(() { searching = true; status = 'جاري البحث عن أشخاص...'; });
    final row = await supabase.from('search_sessions').insert({
      'user_id': currentUserId,
      'preferred_gender': gender,
      'preferred_country': country,
      'status': 'searching',
    }).select().single();
    final id = row['id'];

    channel = supabase.channel('live-search-$id')
      ..onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'search_matches',
        filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'session_id', value: id),
        callback: (payload) async {
          final other = payload.newRecord['matched_user_id'];
          if (other != null) {
            final p = await supabase.from('profiles').select().eq('id', other).maybeSingle();
            if (p != null && mounted) {
              setState(() {
                matches.add(Map<String, dynamic>.from(p));
                status = 'تم العثور على شخص مناسب 🎉';
              });
            }
          }
        },
      ).subscribe();
  }

  Future<void> stop() async {
    if (channel != null) {
      await supabase.removeChannel(channel!);
      channel = null;
    }
    if (searching) {
      await supabase.from('search_sessions').update({'status': 'cancelled', 'ended_at': DateTime.now().toIso8601String()})
        .eq('user_id', currentUserId).eq('status', 'searching');
    }
    if (mounted) setState(() { searching = false; });
  }

  @override
  void dispose() {
    if (channel != null) supabase.removeChannel(channel!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('البحث الفوري')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('حدد من تريد أن تتعرف عليه ثم ابدأ البحث.', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 18),
        DropdownButtonFormField<String>(
          value: gender, decoration: const InputDecoration(labelText: 'الجنس المطلوب'),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('ذكر')),
            DropdownMenuItem(value: 'female', child: Text('أنثى')),
          ],
          onChanged: searching ? null : (v) => setState(() => gender = v),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: country, decoration: const InputDecoration(labelText: 'الدولة المطلوبة'),
          items: const [
            DropdownMenuItem(value: 'Iraq', child: Text('العراق')),
            DropdownMenuItem(value: 'Saudi Arabia', child: Text('السعودية')),
            DropdownMenuItem(value: 'Kuwait', child: Text('الكويت')),
            DropdownMenuItem(value: 'Jordan', child: Text('الأردن')),
            DropdownMenuItem(value: 'United Arab Emirates', child: Text('الإمارات')),
          ],
          onChanged: searching ? null : (v) => setState(() => country = v),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: searching ? stop : start,
          icon: Icon(searching ? Icons.stop : Icons.bolt),
          label: Text(searching ? 'إيقاف البحث' : 'ابدأ البحث'),
        ),
        const SizedBox(height: 20),
        Center(child: Text(status, style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        ...matches.map((p) => Card(child: ListTile(
          leading: CircleAvatar(child: const Icon(Icons.person)),
          title: Text(p['display_name'] ?? 'مستخدم'),
          subtitle: Text('${p['country'] ?? ''}'),
        ))),
      ],
    ),
  );
}
