class Wallpaper {
  const Wallpaper({
    required this.id,
    required this.userId,
    required this.title,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.username,
    required this.category,
    required this.tags,
    required this.width,
    required this.height,
    required this.fileSize,
    required this.likesCount,
    required this.downloadsCount,
    required this.isAi,
    required this.isSuggestive,
    required this.status,
  });

  final String id;
  final String userId;
  final String title;
  final String imageUrl;
  final String thumbnailUrl;
  final String username;
  final String category;
  final List<String> tags;
  final int width;
  final int height;
  final int fileSize;
  final int likesCount;
  final int downloadsCount;
  final bool isAi;
  final bool isSuggestive;
  final String status;

  factory Wallpaper.fromMap(Map<String, dynamic> map) {
    return Wallpaper(
      id: map['id'].toString(),
      userId: map['user_id'].toString(),
      title: map['title'] ?? '',
      imageUrl: map['image_url'] ?? '',
      thumbnailUrl: map['thumbnail_url'] ?? map['image_url'] ?? '',
      username: map['username'] ?? 'unknown',
      category: map['category'] ?? 'Uncategorized',
      tags: List<String>.from(map['tags'] ?? const []),
      width: map['width'] ?? 0,
      height: map['height'] ?? 0,
      fileSize: map['file_size'] ?? 0,
      likesCount: map['likes_count'] ?? 0,
      downloadsCount: map['downloads_count'] ?? 0,
      isAi: map['is_ai'] ?? false,
      isSuggestive: map['is_suggestive'] ?? false,
      status: map['status'] ?? 'pending',
    );
  }
}
