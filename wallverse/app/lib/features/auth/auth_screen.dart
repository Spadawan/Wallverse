import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            FilledButton(onPressed: () {}, child: const Text('Continue with email')),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () {}, child: const Text('Continue with Google')),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () {}, child: const Text('Continue with Facebook')),
          ],
        ),
      ),
    );
  }
}
