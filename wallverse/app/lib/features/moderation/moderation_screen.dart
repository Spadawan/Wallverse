import 'package:flutter/material.dart';

import '../../shared/services/wallpaper_repository.dart';

class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen> {
  final _repo = WallpaperRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moderation')),
      body: FutureBuilder(
        future: _repo.fetchPendingWallpapers(),
        builder: (context, snapshot) {
          final wallpapers = snapshot.data ?? const [];

          if (wallpapers.isEmpty) {
            return const Center(child: Text('No pending wallpapers'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wallpapers.length,
            itemBuilder: (_, index) {
              final wallpaper = wallpapers[index];

              return Card(
                child: ListTile(
                  title: Text(wallpaper.title),
                  subtitle: Text('@${wallpaper.username} • ${wallpaper.category}'),
                  trailing: Wrap(
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.check_rounded)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
