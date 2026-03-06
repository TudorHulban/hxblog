-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 03. denormalized posts for fast access
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

create table post_listing (
    post_id bigint primary key,
    slug varchar(255) not null,
    title varchar(500) not null,
    excerpt text,
    category_id bigint,
    published_at bigint not null,
    view_count bigint,
    comment_count bigint
);


create materialized view post_listing as
select
    p.id,
    p.slug,
    p.title,
    p.excerpt,
    p.published_at,
    a.name as author_name,
    c.name as category_name,
    m.view_count
from posts p
join authors a on a.id = p.author_id
left join post_categories pc on pc.post_id = p.id
left join categories c on c.id = pc.category_id
left join post_metrics_total m on m.post_id = p.id;

create index idx_post_listing_published
on post_listing (published_at desc);

refresh materialized view concurrently post_listing;