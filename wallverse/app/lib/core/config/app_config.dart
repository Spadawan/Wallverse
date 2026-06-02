class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const admobRewardedAndroid = String.fromEnvironment(
    'ADMOB_REWARDED_AD_UNIT_ID_ANDROID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );
}
