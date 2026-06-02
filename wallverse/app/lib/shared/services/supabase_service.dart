import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static bool get isConfigured {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser {
    if (!isConfigured) return null;
    return client.auth.currentUser;
  }

  static Stream<AuthState> get authStateChanges {
    return client.auth.onAuthStateChange;
  }
}
