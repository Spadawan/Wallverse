import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/wallpaper.dart';
import 'mock_data.dart';
import 'supabase_service.dart';

class WallpaperUploadInput {
  const WallpaperUploadInput({
    required this.title,
    required this.description,
    required this.category,
    required this.tags,
    required this.bytes,
    required this.fileName,
    required this.contentType,
    required this.width,
    required this.height,
    required this.fileSize,
    required this.isAi,
    required this.isSuggestive,
  });

  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final Uint8List bytes;
  final String fileName;
  final String contentType;
  final int width;
  final int height;
  final int fileSize;
  final bool isAi;
  final bool isSuggestive;
}

class WallpaperRepository {
  static const originalBucket = 'wallpapers-original';

  Future<List<Wallpaper>> fetchApprovedWallpapers({int limit = 30}) async {
    if (!SupabaseService.isConfigured) {
      return mockWallpapers;
    }

    final rows = await SupabaseService.client
        .from('wallpapers')
        .select('*, profiles(username), wallpaper_tags(tags(name))')
        .eq('status', 'approved')
        .eq('is_suggestive', false)
        .order('created_at', ascending: false)
        .limit(limit);

    return rows.map<Wallpaper>((row) => Wallpaper.fromMap(row)).toList();
  }

  Future<List<Wallpaper>> searchApprovedWallpapers({String? query, String? category, int limit = 60}) async {
    if (!SupabaseService.isConfigured) {
      final lowerQuery = query?.trim().toLowerCase() ?? '';
      return mockWallpapers.where((wallpaper) {
        final matchesQuery = lowerQuery.isEmpty ||
            wallpaper.title.toLowerCase().contains(lowerQuery) ||
            wallpaper.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
        final matchesCategory = category == null || wallpaper.category == category;
        return matchesQuery && matchesCategory;
      }).toList();
    }

    var request = SupabaseService.client
        .from('wallpapers')
        .select('*, profiles(username), wallpaper_tags(tags(name))')
        .eq('status', 'approved')
        .eq('is_suggestive', false);

    final trimmed = query?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      request = request.ilike('title', '%$trimmed%');
    }
    if (category != null) {
      request = request.eq('category', category);
    }

    final rows = await request.order('created_at', ascending: false).limit(limit);
    return rows.map<Wallpaper>((row) => Wallpaper.fromMap(row)).toList();
  }

  Future<List<Wallpaper>> fetchPendingWallpapers({int limit = 50}) async {
    if (!SupabaseService.isConfigured) {
      return const [];
    }

    final rows = await SupabaseService.client
        .from('wallpapers')
        .select('*, profiles(username), wallpaper_tags(tags(name))')
        .eq('status', 'pending')
        .order('created_at', ascending: true)
        .limit(limit);

    return rows.map<Wallpaper>((row) => Wallpaper.fromMap(row)).toList();
  }

  Future<void> uploadWallpaper(WallpaperUploadInput input) async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      throw AuthException('Sign in before uploading wallpapers.');
    }

    await _ensureProfile(user);

    final extension = _extensionForContentType(input.contentType);
    final imagePath = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';

    await SupabaseService.client.storage.from(originalBucket).uploadBinary(
          imagePath,
          input.bytes,
          fileOptions: FileOptions(contentType: input.contentType, upsert: false),
        );

    final imageUrl = SupabaseService.client.storage.from(originalBucket).getPublicUrl(imagePath);

    final inserted = await SupabaseService.client.from('wallpapers').insert({
      'user_id': user.id,
      'title': input.title.trim(),
      'description': input.description.trim().isEmpty ? null : input.description.trim(),
      'category': input.category,
      'image_url': imageUrl,
      'thumbnail_url': imageUrl,
      'width': input.width,
      'height': input.height,
      'file_size': input.fileSize,
      'is_ai': input.isAi,
      'is_suggestive': input.isSuggestive,
      'status': 'pending',
    }).select('id').single();

    final wallpaperId = inserted['id'].toString();
    for (final tag in input.tags) {
      final tagId = await _findOrCreateTag(tag);
      await SupabaseService.client.from('wallpaper_tags').insert({
        'wallpaper_id': wallpaperId,
        'tag_id': tagId,
      });
    }
  }

  Future<void> _ensureProfile(User user) async {
    final rows = await SupabaseService.client.from('profiles').select('id').eq('id', user.id).limit(1);
    if (rows.isNotEmpty) return;

    final cleaned = user.email?.split('@').first.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '') ?? '';
    final fallback = cleaned.length >= 3 ? cleaned : 'user';
    final username = '${fallback}_${user.id.substring(0, 6)}'.toLowerCase();
    final safeUsername = username.length > 32 ? username.substring(0, 32) : username;
    await SupabaseService.client.from('profiles').insert({'id': user.id, 'username': safeUsername});
  }

  Future<String> _findOrCreateTag(String rawTag) async {
    final tag = rawTag.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]'), '');
    if (tag.isEmpty) throw ArgumentError('Tag cannot be empty.');

    final existing = await SupabaseService.client.from('tags').select('id').eq('name', tag).limit(1);
    if (existing.isNotEmpty) return existing.first['id'].toString();

    final inserted = await SupabaseService.client.from('tags').insert({'name': tag}).select('id').single();
    return inserted['id'].toString();
  }

  static Future<Size> decodeImageSize(Uint8List bytes) async {
    final image = await decodeImageFromList(bytes);
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  static String contentTypeForName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    throw ArgumentError('Only JPG, PNG, and WEBP images are supported.');
  }

  static String _extensionForContentType(String contentType) {
    switch (contentType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      default:
        throw ArgumentError('Unsupported content type.');
    }
  }
}
