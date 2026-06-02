import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/services/supabase_service.dart';
import '../auth/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseService.isConfigured ? SupabaseService.authStateChanges : null,
      builder: (context, snapshot) {
        final user = SupabaseService.currentUser;
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(height: 16),
              const CircleAvatar(radius: 42, child: Icon(Icons.person_rounded, size: 42)),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(user == null ? '@guest' : '@${_displayName(user)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    if (user != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_rounded, color: AppTheme.accent),
                    ],
                  ],
                ),
              ),
              if (user?.email != null) ...[
                const SizedBox(height: 6),
                Text(user!.email!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted)),
              ],
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(label: 'Uploads', value: '0'),
                  _Stat(label: 'Likes', value: '0'),
                  _Stat(label: 'Followers', value: '0'),
                ],
              ),
              const SizedBox(height: 24),
              if (user == null)
                FilledButton(
                  onPressed: SupabaseService.isConfigured
                      ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuthScreen()))
                      : null,
                  child: Text(SupabaseService.isConfigured ? 'Sign in' : 'Configure Supabase to sign in'),
                )
              else
                FilledButton.tonal(
                  onPressed: () => SupabaseService.client.auth.signOut(),
                  child: const Text('Sign out'),
                ),
              const SizedBox(height: 16),
              const ListTile(
                leading: Icon(Icons.visibility_off_rounded),
                title: Text('Hide suggestive content by default'),
                subtitle: Text('Enabled'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _displayName(User user) {
    final username = user.userMetadata?['username']?.toString();
    if (username != null && username.isNotEmpty) return username;
    final emailName = user.email?.split('@').first;
    if (emailName != null && emailName.isNotEmpty) return emailName;
    return 'user';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: AppTheme.muted)),
      ],
    );
  }
}
