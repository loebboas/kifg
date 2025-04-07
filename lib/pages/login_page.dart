import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kifg/providers/user_provider.dart';
import 'package:kifg/services/firestore_service.dart';
import 'package:kifg/widgets/body_logo.dart';
import 'package:kifg/widgets/body_wrapper.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final AuthService authService = AuthService();

  String? error;

  void _login() async {
    try {
      User? user = await authService.signIn(
        email.text.trim(),
        password.text.trim(),
      );
      UserProvider userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      userProvider.setUserModel(await FirestoreService().getUser(user!.uid));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BodyWrapper(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              BodyLogoWidget(),
              if (error != null) ...[
                Text(error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 10),
              ],
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: password,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  'Noch keinen Account? Registriere dich hier!',
                ),
              ),
              SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Open Legal Lab 2025 - Prototyp',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SelectableText(
                      'Fragen? Feedback? loebboas@gmail.com',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
