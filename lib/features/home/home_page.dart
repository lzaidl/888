import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/supabase_client.dart';

class HomePage extends StatelessWidget {
  final void Function(ThemeMode) onThemeChanged;
  const HomePage({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('وصل', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(onPressed: () => context.push('/profile'), icon: const Icon(Icons.person_outline)),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('أهلًا بك 👋', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('اكتشف أشخاصًا جدد أو ابدأ بحثًا فوريًا.'),
        const SizedBox(height: 24),
        _ActionCard(icon: Icons.bolt_rounded, title: 'بحث فوري', subtitle: 'ابحث عن أشخاص يبحثون الآن',
          onTap: () => context.push('/live-search')),
        const SizedBox(height: 12),
        _ActionCard(icon: Icons.search_rounded, title: 'اكتشف', subtitle: 'بحث حسب الجنس والدولة',
          onTap: () => context.push('/discover')),
        const SizedBox(height: 12),
        _ActionCard(icon: Icons.chat_bubble_outline_rounded, title: 'المحادثات', subtitle: 'محادثاتك الخاصة',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ستظهر المحادثات هنا')))),
        const SizedBox(height: 28),
        Card(
          child: ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('مظهر التطبيق'),
            subtitle: const Text('فاتح / داكن / تلقائي'),
            onTap: () => showModalBottomSheet(
              context: context,
              builder: (_) => SafeArea(
                child: Wrap(children: [
                  ListTile(leading: const Icon(Icons.light_mode), title: const Text('فاتح'), onTap: () { onThemeChanged(ThemeMode.light); Navigator.pop(context); }),
                  ListTile(leading: const Icon(Icons.dark_mode), title: const Text('داكن'), onTap: () { onThemeChanged(ThemeMode.dark); Navigator.pop(context); }),
                  ListTile(leading: const Icon(Icons.settings_suggest), title: const Text('تلقائي'), onTap: () { onThemeChanged(ThemeMode.system); Navigator.pop(context); }),
                ]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () async {
            await supabase.auth.signOut();
            if (context.mounted) context.go('/login');
          },
          icon: const Icon(Icons.logout),
          label: const Text('تسجيل الخروج'),
        ),
      ],
    ),
  );
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          CircleAvatar(radius: 27, child: Icon(icon)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 4), Text(subtitle),
          ])),
          const Icon(Icons.chevron_right),
        ]),
      ),
    ),
  );
}
