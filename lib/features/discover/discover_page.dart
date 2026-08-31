import 'package:flutter/material.dart';
import '../../core/supabase_client.dart';
import '../chat/chat_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});
  @override State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String? gender;
  String? country;
  bool loading = false;
  List<Map<String, dynamic>> people = [];

  Future<void> search() async {
    setState(() => loading = true);
    try {
      var q = supabase.from('profiles').select().neq('id', currentUserId);
      if (gender != null) q = q.eq('gender', gender!);
      if (country != null) q = q.eq('country', country!);
      final data = await q.order('created_at', ascending: false).limit(50);
      setState(() => people = List<Map<String, dynamic>>.from(data));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> like(String targetId) async {
    await supabase.from('likes').upsert({'liker_id': currentUserId, 'liked_id': targetId});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الإعجاب ❤️')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('اكتشف')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          value: gender, decoration: const InputDecoration(labelText: 'الجنس المطلوب'),
          items: const [
            DropdownMenuItem(value: 'male', child: Text('ذكر')),
            DropdownMenuItem(value: 'female', child: Text('أنثى')),
          ],
          onChanged: (v) => setState(() => gender = v),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: country, decoration: const InputDecoration(labelText: 'الدولة'),
          items: const [
            DropdownMenuItem(value: 'Iraq', child: Text('العراق')),
            DropdownMenuItem(value: 'Saudi Arabia', child: Text('السعودية')),
            DropdownMenuItem(value: 'Kuwait', child: Text('الكويت')),
            DropdownMenuItem(value: 'Jordan', child: Text('الأردن')),
            DropdownMenuItem(value: 'United Arab Emirates', child: Text('الإمارات')),
          ],
          onChanged: (v) => setState(() => country = v),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: loading ? null : search, icon: const Icon(Icons.search), label: const Text('بحث')),
        const SizedBox(height: 18),
        if (loading) const Center(child: CircularProgressIndicator()),
        ...people.map((p) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: p['avatar_url'] != null ? NetworkImage(p['avatar_url']) : null,
              child: p['avatar_url'] == null ? const Icon(Icons.person) : null,
            ),
            title: Text('${p['display_name'] ?? 'مستخدم'} • ${p['age'] ?? ''}'),
            subtitle: Text('${p['country'] ?? ''} • ${p['gender'] == 'male' ? 'ذكر' : 'أنثى'}'),
            trailing: IconButton(icon: const Icon(Icons.favorite_border), onPressed: () => like(p['id'])),
          ),
        )),
      ],
    ),
  );
}
