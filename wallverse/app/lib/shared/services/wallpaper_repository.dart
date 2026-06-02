import '../models/wallpaper.dart';
import 'mock_data.dart';
import 'supabase_service.dart';

class WallpaperRepository {
  Future<List<Wallpaper>> fetchApprovedWallpapers({int limit = 30}) async {
    if (!SupabaseService.isConfigured) {
      return mockWallpapers;
    }

    final rows = await SupabaseService.client
        .from('wallpapers')
        .select()
        .eq('status', 'approved')
        .eq('is_suggestive', false)
        .order('created_at', ascending: false)
        .limit(limit);

    return rows.map<Wallpaper>((row) => Wallpaper.fromMap(row)).toList();
  }

  Future<List<Wallpaper>> fetchPendingWallpapers({int limit = 50}) async {
    if (!SupabaseService.isConfigured) {
      return const [];
    }

    final rows = await SupabaseService.client
        .from('wallpapers')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: true)
        .limit(limit);

    return rows.map<Wallpaper>((row) => Wallpaper.fromMap(row)).toList();
  }
}
