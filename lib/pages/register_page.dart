import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kifg/widgets/body_wrapper.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final AuthService authService = AuthService();
  final TextEditingController teacherCode = TextEditingController();

  String? error;
  bool isTeacher = false;

  static const String _obfuscatedTeacherCode = 'b2xsLTIwMjU=';

  bool _verifyTeacherCode(String input) {
    final expected = String.fromCharCodes(
      const Base64Decoder().convert(_obfuscatedTeacherCode),
    );
    return input.trim() == expected;
  }

  void _register() async {
    if (isTeacher && !_verifyTeacherCode(teacherCode.text)) {
      setState(
        () =>
            error =
                'Ungültiger Dozenten-Code: Code can angefragt werden bei loebboas@gmail.com',
      );
      return;
    }

    try {
      await authService.register(
        email.text.trim(),
        password.text.trim(),
        isTeacher,
      );
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
      appBar: AppBar(title: const Text('Register')),
      body: BodyWrapper(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
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
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: 'Open Legal Lab 2025',
                items: const [
                  DropdownMenuItem(
                    value: 'Open Legal Lab 2025',
                    child: Text('Open Legal Lab 2025'),
                  ),
                  DropdownMenuItem(
                    value: 'Universität Basel',
                    child: Text('Universität Basel'),
                  ),
                  DropdownMenuItem(
                    value: 'Universität Zürich',
                    child: Text('Universität Zürich'),
                  ),
                ],
                onChanged: (value) {
                  // Handle dropdown value change if needed
                },
                decoration: const InputDecoration(
                  labelText: 'Bitte wählen Sie Ihre Institution aus',
                ),
              ),

              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Als Dozent registrieren'),
                value: isTeacher,
                onChanged: (val) {
                  setState(() {
                    isTeacher = val;
                  });
                },
              ),
              if (isTeacher)
                TextField(
                  controller: teacherCode,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Dozenten-Code'),
                ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
