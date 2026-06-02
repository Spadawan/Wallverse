# Wallverse

Wallverse is a community-driven Android-first wallpaper app.

> Discover and share high-quality mobile wallpapers curated by a passionate community.

This repository contains a Flutter MVP base and Supabase SQL schema.

## MVP scope

- Android-first Flutter app
- Supabase Auth / Database / Storage-ready architecture
- Home feed
- Search grid
- Wallpaper detail
- Upload form with `pending` moderation status
- Collections base
- Profile base
- Notifications placeholder
- Moderation queue placeholder
- Rewarded ads placeholder service

## Tech stack

- Flutter
- Riverpod
- Supabase Flutter
- PostgreSQL / Row Level Security
- Google Mobile Ads Flutter plugin

## Repository structure

```txt
wallverse/
  app/                 Flutter app
  supabase/            SQL schema, policies and seed data
  README.md
  .env.example
```

## Quick start

### 1. Create the Flutter app shell

From inside `wallverse/app`, run:

```bash
flutter pub get
flutter run
```

If Android files are missing because this is a code scaffold, run:

```bash
flutter create .
flutter pub get
flutter run
```

This keeps the existing `lib/` and `pubspec.yaml`.

### 2. Create Supabase project

Create a Supabase project, then run:

```sql
-- first
supabase/schema.sql

-- then
supabase/policies.sql

-- optional
supabase/seed.sql
```

### 3. Configure environment

Copy:

```bash
cp .env.example app/.env
```

Then fill:

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
ADMOB_REWARDED_AD_UNIT_ID_ANDROID=
```

For local Flutter env loading, this base uses `--dart-define` for simplicity:

```bash
flutter run \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY \
  --dart-define=ADMOB_REWARDED_AD_UNIT_ID_ANDROID=ca-app-pub-3940256099942544/5224354917
```

The AdMob ID above is Google's rewarded test ad unit.

## Supabase Storage buckets

Create these buckets manually in Supabase Storage:

- `wallpapers-original`
- `wallpapers-thumbnails`
- `avatars`
- `banners`

Recommended public access for MVP:
- thumbnails: public
- originals: public or signed URLs later

## Important product rules

- Mobile wallpapers only at launch
- SFW only
- Suggestive content allowed only with tag and hidden by default
- AI images allowed only with `is_ai = true`
- Uploads are not public until approved
- 4 MB max image size in app logic
- Minimum recommended resolution: 1080 x 1920
- 30 uploads/day target rule to implement with backend rate limiting later

## Next Codex prompts

Useful first prompt:

> Review this Flutter/Supabase MVP scaffold. Make it compile, then implement Supabase auth and replace mock wallpaper data with live approved wallpapers from the database.

Then:

> Implement image upload to Supabase Storage with validation: JPG, PNG, WEBP, max 4 MB, min 1080x1920, status pending.
