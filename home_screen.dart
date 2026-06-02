insert into public.tags (name)
values
  ('anime'),
  ('gaming'),
  ('amoled'),
  ('nature'),
  ('cyberpunk'),
  ('minimalist'),
  ('ai'),
  ('suggestive')
on conflict (name) do nothing;
