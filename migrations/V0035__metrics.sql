-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 03. metrics
-- =====================================================

create table if not exists metrics_1_posts (
    post_id int8 not null primary key references "25_posts"(id) on delete cascade,
    share_count int8 not null default 0,
    like_count int8 not null default 0,
    comment_count int8 not null default 0,
    view_count int8 not null default 0   
);

create table if not exists metrics_2_author (
    author_id int8 not null primary key references "20_users"(id) on delete cascade,
    total_posts int4 not null default 0,
    follower_count int4 not null default 0,
    total_comments int8 not null default 0,
    total_views int8 not null default 0
);