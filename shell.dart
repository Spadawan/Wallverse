create extension if not exists "pgcrypto";

create type public.wallpaper_status as enum ('pending', 'approved', 'rejected');
create type public.report_status as enum ('open', 'reviewing', 'resolved', 'dismissed');
create type public.user_role as enum ('user', 'verified_artist', 'moderator', 'admin');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null check (char_length(username) between 3 and 32),
  avatar_url text,
  banner_url text,
  bio text,
  website_url text,
  instagram_url text,
  role public.user_role not null default 'user',
  hide_stats boolean not null default false,
  hide_socials boolean not null default false,
  show_suggestive boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.wallpapers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 2 and 80),
  description text,
  category text not null,
  image_url text not null,
  thumbnail_url text not null,
  width integer not null check (width >= 1080),
  height integer not null check (height >= 1920),
  file_size integer not null check (file_size <= 4194304),
  is_ai boolean not null default false,
  is_suggestive boolean not null default false,
  status public.wallpaper_status not null default 'pending',
  rejection_reason text,
  likes_count integer not null default 0,
  downloads_count integer not null default 0,
  comments_count integer not null default 0,
  reports_count integer not null default 0,
  created_at timestamptz not null default now(),
  approved_at timestamptz
);

create table public.tags (
  id uuid primary key default gen_random_uuid(),
  name text unique not null check (name = lower(name) and char_length(name) between 2 and 32),
  created_at timestamptz not null default now()
);

create table public.wallpaper_tags (
  wallpaper_id uuid not null references public.wallpapers(id) on delete cascade,
  tag_id uuid not null references public.tags(id) on delete cascade,
  primary key (wallpaper_id, tag_id)
);

create table public.likes (
  user_id uuid not null references public.profiles(id) on delete cascade,
  wallpaper_id uuid not null references public.wallpapers(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, wallpaper_id)
);

create table public.favorites (
  user_id uuid not null references public.profiles(id) on delete cascade,
  wallpaper_id uuid not null references public.wallpapers(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, wallpaper_id)
);

create table public.collections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(title) between 2 and 80),
  description text,
  banner_url text,
  is_private boolean not null default false,
  followers_count integer not null default 0,
  items_count integer not null default 0,
  created_at timestamptz not null default now()
);

create table public.collection_items (
  collection_id uuid not null references public.collections(id) on delete cascade,
  wallpaper_id uuid not null references public.wallpapers(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (collection_id, wallpaper_id)
);

create table public.follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  followed_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, followed_id),
  check (follower_id <> followed_id)
);

create table public.comments (
  id uuid primary key default gen_random_uuid(),
  wallpaper_id uuid not null references public.wallpapers(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  parent_id uuid references public.comments(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 500),
  is_deleted boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  wallpaper_id uuid not null references public.wallpapers(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  reason text not null check (char_length(reason) between 3 and 120),
  details text,
  status public.report_status not null default 'open',
  created_at timestamptz not null default now(),
  unique (wallpaper_id, user_id)
);

create table public.downloads (
  id uuid primary key default gen_random_uuid(),
  wallpaper_id uuid not null references public.wallpapers(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete set null,
  quality text not null check (quality in ('sd', 'hd', 'original')),
  rewarded_ad_watched boolean not null default false,
  created_at timestamptz not null default now()
);

create index wallpapers_status_created_idx on public.wallpapers(status, created_at desc);
create index wallpapers_category_idx on public.wallpapers(category);
create index wallpapers_suggestive_idx on public.wallpapers(is_suggestive);
create index tags_name_idx on public.tags(name);
create index comments_wallpaper_idx on public.comments(wallpaper_id, created_at desc);
create index reports_status_idx on public.reports(status, created_at desc);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'username', 'user_' || substr(new.id::text, 1, 8))
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
