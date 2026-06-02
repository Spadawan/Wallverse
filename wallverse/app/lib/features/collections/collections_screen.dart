import 'package:flutter/material.dart';

import '../../shared/services/mock_data.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final collections = mockCollections;

    return Scaffold(
      appBar: AppBar(title: const Text('Collections')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: collections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, index) {
          final collection = collections[index];

          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 8,
                  child: Image.network(collection.bannerUrl, fit: BoxFit.cover),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(collection.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(collection.description),
                      const SizedBox(height: 8),
                      Text('${collection.itemsCount} wallpapers'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
