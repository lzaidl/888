import 'package:flutter/material.dart';
import '../../core/supabase_client.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  Map<String,dynamic>? profile;
  final bio = TextEditingController();
  bool loading = true;

  Future<void> load() async {
    final p = await supabase.from('profiles').select().eq('id', currentUserId).maybeSingle();
    setState(() { profile = p; bio.text = p?['bio'] ?? ''; loading = false; });
  }

  Future<void> save() async {
    await supabase.from('profiles').update({'bio': bio.text.trim()}).eq('id', currentUserId);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الملف')));
  }

  @override void initState() { super.initState(); load(); }

  @override Widget build(BuildContext context) {
    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('ملفي الشخصي')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        CircleAvatar(radius: 48, child: const Icon(Icons.person, size: 45)),
        const SizedBox(height: 15),
        Center(child: Text(profile?['display_name'] ?? '', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
        Center(child: Text('${profile?['age'] ?? ''} • ${profile?['country'] ?? ''}')),
        const SizedBox(height: 25),
        TextField(controller: bio, maxLines: 5, decoration: const InputDecoration(labelText: 'نبذة عني')),
        const SizedBox(height: 15),
        FilledButton(onPressed: save, child: const Text('حفظ التعديلات')),
      ]),
    );
  }
}
