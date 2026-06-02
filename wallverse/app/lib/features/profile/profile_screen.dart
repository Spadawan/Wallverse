import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('@yourname', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                SizedBox(width: 6),
                Icon(Icons.verified_rounded, color: AppTheme.accent),
              ],
            ),
          ),
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
          FilledButton(onPressed: null, child: Text('Sign in coming next')),
          const SizedBox(height: 16),
          const ListTile(
            leading: Icon(Icons.visibility_off_rounded),
            title: Text('Hide suggestive content by default'),
            subtitle: Text('Enabled'),
          ),
        ],
      ),
    );
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
