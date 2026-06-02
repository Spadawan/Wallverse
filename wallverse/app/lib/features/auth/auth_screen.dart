import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/services/supabase_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;
  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _username.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!SupabaseService.isConfigured) {
      setState(() => _message = 'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      if (_isSignUp) {
        await SupabaseService.client.auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
          data: {'username': _username.text.trim()},
        );
        setState(() => _message = 'Account created. Check your email if confirmation is enabled.');
      } else {
        await SupabaseService.client.auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        if (mounted) Navigator.of(context).pop();
      }
    } on AuthException catch (error) {
      setState(() => _message = error.message);
    } catch (_) {
      setState(() => _message = 'Authentication failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMagicLink() async {
    if (!SupabaseService.isConfigured) {
      setState(() => _message = 'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }

    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _message = 'Enter a valid email address first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await SupabaseService.client.auth.signInWithOtp(email: email);
      setState(() => _message = 'Magic link sent. Check your email to finish signing in.');
    } on AuthException catch (error) {
      setState(() => _message = error.message);
    } catch (_) {
      setState(() => _message = 'Could not send a magic link. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignUp ? 'Create account' : 'Sign in')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!SupabaseService.isConfigured)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text('Supabase is not configured. Run with SUPABASE_URL and SUPABASE_ANON_KEY dart defines to enable live auth.'),
                ),
              ),
            if (_isSignUp) ...[
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Username'),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final username = value?.trim() ?? '';
                  if (username.length < 3 || username.length > 32) return 'Use 3-32 characters.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty || !email.contains('@')) return 'Enter a valid email.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onFieldSubmitted: (_) => _submit(),
              validator: (value) {
                if ((value ?? '').length < 6) return 'Use at least 6 characters.';
                return null;
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isSignUp ? 'Create account' : 'Sign in'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _isLoading ? null : _sendMagicLink,
              child: const Text('Email me a magic link'),
            ),
            TextButton(
              onPressed: _isLoading ? null : () => setState(() => _isSignUp = !_isSignUp),
              child: Text(_isSignUp ? 'I already have an account' : 'Create a new account'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
