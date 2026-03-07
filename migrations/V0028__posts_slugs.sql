-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 03. posts slugs for application cache
-- =====================================================

create table if not exists posts_slugs (
    slug text primary key,
    post_id int8 references posts(id)  -- no on delete cascade for seo redirection
);

create index idx_posts_slugs on posts_slugs(post_id);