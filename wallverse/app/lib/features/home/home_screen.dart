import 'package:flutter/material.dart';

import '../../shared/services/wallpaper_repository.dart';
import '../../shared/widgets/wallpaper_card.dart';
import '../wallpaper/wallpaper_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = WallpaperRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallverse', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _repo.fetchApprovedWallpapers(),
        builder: (context, snapshot) {
          final wallpapers = snapshot.data ?? const [];

          if (snapshot.connectionState == ConnectionState.waiting && wallpapers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load wallpapers.'));
          }
          if (wallpapers.isEmpty) {
            return const Center(child: Text('No approved wallpapers yet.'));
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wallpapers.length,
              itemBuilder: (context, index) {
                final wallpaper = wallpapers[index];
                return WallpaperCard(
                  wallpaper: wallpaper,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WallpaperDetailScreen(wallpaper: wallpaper),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
