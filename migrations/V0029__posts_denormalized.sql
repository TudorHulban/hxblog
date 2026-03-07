-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 03. denormalized posts for fast access on common queries
-- =====================================================

-- latest posts
-- popular posts
-- category posts

-- post_listing
-- -----------
-- post_id
-- title
-- slug
-- category_id
-- published_at
-- comment_count
-- view_count

-- select id, slug, title
-- from latest posts
-- where status_id = 2
-- order by published_at desc
-- limit 20

-- create table post_listing (
--     post_id bigint primary key,
--     slug varchar(255) not null,
--     title varchar(500) not null,
--     excerpt text,
--     category_id bigint,
--     published_at bigint not null,
--     view_count bigint,
--     comment_count bigint
-- );


-- create materialized view post_listing as
-- select
--     p.id,
--     p.slug,
--     p.title,
--     p.excerpt,
--     p.published_at,
--     a.name as author_name,
--     c.name as category_name,
--     m.view_count
-- from posts p
-- join authors a on a.id = p.author_id
-- left join post_categories pc on pc.post_id = p.id
-- left join categories c on c.id = pc.category_id
-- left join post_metrics_total m on m.post_id = p.id;

-- create index idx_post_listing_published
-- on post_listing (published_at desc);

-- refresh materialized view concurrently post_listing;



-- Published posts view
-- CREATE VIEW published_posts AS
-- SELECT 
--     p.*,
--     u.display_name as author_name,
--     u.avatar_url as author_avatar,
--     COALESCE(
--         (SELECT json_agg(json_build_object('id', c.id, 'name', c.name, 'slug', c.slug))
--          FROM post_categories pc
--          JOIN categories c ON pc.category_id = c.id
--          WHERE pc.post_id = p.id),
--         '[]'::json
--     ) as categories,
--     COALESCE(
--         (SELECT json_agg(json_build_object('id', t.id, 'name', t.name, 'slug', t.slug))
--          FROM post_tags pt
--          JOIN tags t ON pt.tag_id = t.id
--          WHERE pt.post_id = p.id),
--         '[]'::json
--     ) as tags
-- FROM posts p
-- JOIN users u ON p.author_id = u.id
-- WHERE p.status = 'published' AND p.deleted_at IS NULL;

-- -- Popular posts view (last 30 days)
-- CREATE VIEW popular_posts AS
-- SELECT 
--     p.*,
--     COALESCE(dps.views, 0) as views_30d,
--     COALESCE(dps.unique_visitors, 0) as visitors_30d
-- FROM posts p
-- LEFT JOIN (
--     SELECT post_id, SUM(views) as views, SUM(unique_visitors) as unique_visitors
--     FROM daily_post_stats
--     WHERE date > NOW() - INTERVAL '30 days'
--     GROUP BY post_id
-- ) dps ON p.id = dps.post_id
-- WHERE p.status = 'published' AND p.deleted_at IS NULL
-- ORDER BY views_30d DESC NULLS LAST;