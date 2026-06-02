alter table public.profiles enable row level security;
alter table public.wallpapers enable row level security;
alter table public.tags enable row level security;
alter table public.wallpaper_tags enable row level security;
alter table public.likes enable row level security;
alter table public.favorites enable row level security;
alter table public.collections enable row level security;
alter table public.collection_items enable row level security;
alter table public.follows enable row level security;
alter table public.comments enable row level security;
alter table public.reports enable row level security;
alter table public.downloads enable row level security;

create or replace function public.is_moderator_or_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid()
    and role in ('moderator', 'admin')
  );
$$;

create policy "Profiles are public"
on public.profiles for select
using (true);

create policy "Users can update own profile"
on public.profiles for update
using (id = auth.uid())
with check (id = auth.uid());

create policy "Approved non-suggestive wallpapers are public"
on public.wallpapers for select
using (
  status = 'approved'
  and (
    is_suggestive = false
    or exists (
      select 1 from public.profiles
      where id = auth.uid()
      and show_suggestive = true
    )
  )
);

create policy "Users can see own wallpapers"
on public.wallpapers for select
using (user_id = auth.uid());

create policy "Moderators can see all wallpapers"
on public.wallpapers for select
using (public.is_moderator_or_admin());

create policy "Users can insert own pending wallpapers"
on public.wallpapers for insert
with check (
  user_id = auth.uid()
  and status = 'pending'
);

create policy "Users can update own pending wallpapers"
on public.wallpapers for update
using (user_id = auth.uid() and status = 'pending')
with check (user_id = auth.uid() and status = 'pending');

create policy "Moderators can update wallpapers"
on public.wallpapers for update
using (public.is_moderator_or_admin())
with check (public.is_moderator_or_admin());

create policy "Tags are public"
on public.tags for select
using (true);

create policy "Authenticated users can insert tags"
on public.tags for insert
with check (auth.uid() is not null);

create policy "Wallpaper tags are public"
on public.wallpaper_tags for select
using (true);

create policy "Owners can tag own wallpapers"
on public.wallpaper_tags for insert
with check (
  exists (
    select 1 from public.wallpapers
    where id = wallpaper_id
    and user_id = auth.uid()
  )
);

create policy "Likes are readable"
on public.likes for select
using (true);

create policy "Users can like"
on public.likes for insert
with check (user_id = auth.uid());

create policy "Users can unlike"
on public.likes for delete
using (user_id = auth.uid());

create policy "Favorites are private"
on public.favorites for select
using (user_id = auth.uid());

create policy "Users can favorite"
on public.favorites for insert
with check (user_id = auth.uid());

create policy "Users can unfavorite"
on public.favorites for delete
using (user_id = auth.uid());

create policy "Public collections are readable"
on public.collections for select
using (is_private = false or user_id = auth.uid());

create policy "Users can create own collections"
on public.collections for insert
with check (user_id = auth.uid());

create policy "Users can update own collections"
on public.collections for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "Collection items readable through collection"
on public.collection_items for select
using (
  exists (
    select 1 from public.collections c
    where c.id = collection_id
    and (c.is_private = false or c.user_id = auth.uid())
  )
);

create policy "Collection owners can add items"
on public.collection_items for insert
with check (
  exists (
    select 1 from public.collections c
    where c.id = collection_id
    and c.user_id = auth.uid()
  )
);

create policy "Collection owners can remove items"
on public.collection_items for delete
using (
  exists (
    select 1 from public.collections c
    where c.id = collection_id
    and c.user_id = auth.uid()
  )
);

create policy "Follows are readable"
on public.follows for select
using (true);

create policy "Users can follow"
on public.follows for insert
with check (follower_id = auth.uid());

create policy "Users can unfollow"
on public.follows for delete
using (follower_id = auth.uid());

create policy "Comments on approved wallpapers are readable"
on public.comments for select
using (
  exists (
    select 1 from public.wallpapers w
    where w.id = wallpaper_id
    and w.status = 'approved'
  )
);

create policy "Authenticated users can comment"
on public.comments for insert
with check (user_id = auth.uid());

create policy "Users can soft edit own comments"
on public.comments for update
using (user_id = auth.uid())
with check (user_id = auth.uid());

create policy "Users can create reports"
on public.reports for insert
with check (user_id = auth.uid());

create policy "Users can see own reports"
on public.reports for select
using (user_id = auth.uid());

create policy "Moderators can see reports"
on public.reports for select
using (public.is_moderator_or_admin());

create policy "Moderators can update reports"
on public.reports for update
using (public.is_moderator_or_admin())
with check (public.is_moderator_or_admin());

create policy "Downloads can be inserted"
on public.downloads for insert
with check (auth.uid() is null or user_id = auth.uid());

create policy "Users can see own downloads"
on public.downloads for select
using (user_id = auth.uid() or public.is_moderator_or_admin());
