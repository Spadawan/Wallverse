import 'package:flutter/material.dart';

import '../../core/constants/categories.dart';
import '../../shared/services/mock_data.dart';
import '../wallpaper/wallpaper_detail_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallpapers = mockWallpapers;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search wallpapers...',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) => Chip(label: Text(wallverseCategories[index])),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: wallverseCategories.length,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: wallpapers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 9 / 16,
            ),
            itemBuilder: (_, index) {
              final wallpaper = wallpapers[index];
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => WallpaperDetailScreen(wallpaper: wallpaper)),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(wallpaper.thumbnailUrl, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
