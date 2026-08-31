import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/supabase_client.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final age = TextEditingController();
  String gender = 'male';
  String country = 'Iraq';
  bool loading = false;

  Future<void> register() async {
    final n = int.tryParse(age.text);
    if (name.text.trim().isEmpty || n == null || n < 18) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب الاسم وعمرًا 18 سنة أو أكثر')),
      );
      return;
    }
    setState(() => loading = true);
    try {
      final res = await supabase.auth.signUp(
        email: email.text.trim(),
        password: password.text,
        data: {
          'display_name': name.text.trim(),
          'age': n,
          'gender': gender,
          'country': country,
        },
      );
      if (res.user != null) {
        await supabase.from('profiles').upsert({
          'id': res.user!.id,
          'display_name': name.text.trim(),
          'age': n,
          'gender': gender,
          'country': country,
        });
      }
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إنشاء الحساب: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('إنشاء حساب')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم')),
              const SizedBox(height: 10),
              TextField(controller: age, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'العمر')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(labelText: 'الجنس'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('ذكر')),
                  DropdownMenuItem(value: 'female', child: Text('أنثى')),
                ],
                onChanged: (v) => setState(() => gender = v!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: country,
                decoration: const InputDecoration(labelText: 'الدولة'),
                items: const [
                  DropdownMenuItem(value: 'Iraq', child: Text('العراق 🇮🇶')),
                  DropdownMenuItem(value: 'Saudi Arabia', child: Text('السعودية 🇸🇦')),
                  DropdownMenuItem(value: 'Kuwait', child: Text('الكويت 🇰🇼')),
                  DropdownMenuItem(value: 'Jordan', child: Text('الأردن 🇯🇴')),
                  DropdownMenuItem(value: 'United Arab Emirates', child: Text('الإمارات 🇦🇪')),
                  DropdownMenuItem(value: 'Other', child: Text('دولة أخرى')),
                ],
                onChanged: (v) => setState(() => country = v!),
              ),
              const SizedBox(height: 10),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
              const SizedBox(height: 10),
              TextField(controller: password, obscureText: true,
                decoration: const InputDecoration(labelText: 'كلمة المرور')),
              const SizedBox(height: 20),
              FilledButton(onPressed: loading ? null : register,
                child: Text(loading ? 'جاري إنشاء الحساب...' : 'إنشاء الحساب')),
            ],
          ),
        ),
      ),
    ),
  );
}
