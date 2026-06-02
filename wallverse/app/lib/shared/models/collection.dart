class WallpaperCollection {
  const WallpaperCollection({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.itemsCount,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final String bannerUrl;
  final int itemsCount;
}
