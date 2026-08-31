import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/supabase_client.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    setState(() => loading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: email.text.trim(),
        password: password.text,
      );
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تسجيل الدخول: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            shrinkWrap: true,
            children: [
              const Icon(Icons.forum_rounded, size: 72),
              const SizedBox(height: 18),
              Text('وصل', textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('دردشة وتعارف بطريقة بسيطة وآمنة', textAlign: TextAlign.center),
              const SizedBox(height: 32),
              TextField(controller: email, keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
              const SizedBox(height: 12),
              TextField(controller: password, obscureText: true,
                decoration: const InputDecoration(labelText: 'كلمة المرور')),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: loading ? null : login,
                child: Text(loading ? 'جاري الدخول...' : 'تسجيل الدخول'),
              ),
              TextButton(onPressed: () => context.go('/register'), child: const Text('إنشاء حساب جديد')),
            ],
          ),
        ),
      ),
    ),
  );
}
