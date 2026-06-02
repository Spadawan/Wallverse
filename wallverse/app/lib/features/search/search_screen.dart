import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/categories.dart';
import '../../shared/models/wallpaper.dart';
import '../../shared/services/wallpaper_repository.dart';
import '../wallpaper/wallpaper_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _repo = WallpaperRepository();
  final _query = TextEditingController();

  String? _category;
  Future<List<Wallpaper>>? _results;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _results = _repo.searchApprovedWallpapers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _results = _repo.searchApprovedWallpapers(query: _query.text, category: _category);
    });
  }

  void _scheduleRefresh() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _refresh);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _query,
            onChanged: (_) => _scheduleRefresh(),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              hintText: 'Search wallpapers...',
              suffixIcon: _query.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _query.clear();
                        _refresh();
                      },
                    ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) {
                final category = wallverseCategories[index];
                return ChoiceChip(
                  label: Text(category),
                  selected: _category == category,
                  onSelected: (selected) {
                    _category = selected ? category : null;
                    _refresh();
                  },
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: wallverseCategories.length,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Wallpaper>>(
            future: _results,
            builder: (context, snapshot) {
              final wallpapers = snapshot.data ?? const <Wallpaper>[];
              if (snapshot.connectionState == ConnectionState.waiting && wallpapers.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('Could not load wallpapers.')),
                );
              }
              if (wallpapers.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('No wallpapers found.')),
                );
              }

              return GridView.builder(
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
                      child: CachedNetworkImage(
                        imageUrl: wallpaper.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported)),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
