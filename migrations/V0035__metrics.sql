-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 03. metrics
-- =====================================================

create table if not exists metrics_01_posts (
    post_id int8 not null primary key references posts(id) on delete cascade,
    share_count int8 not null default 0,
    like_count int8 not null default 0,
    comment_count int8 not null default 0,
    view_count int8 not null default 0   
);

create table if not exists metrics_02_author (
    author_id int8 not null primary key references users(id) on delete cascade,
    total_posts int4 not null default 0,
    follower_count int4 not null default 0,
    total_comments int8 not null default 0,
    total_views int8 not null default 0
);

create table if not exists metrics_03_posts_views (
    id int8 not null primary key,
    post_id int8 not null references posts(id) on delete cascade,
    country_iso int2 not null,
    device_type int2,
    browser int2,
    os int2,
    zip_code int2 not null
);

CREATE INDEX idx_posts_views_post_id ON metrics_03_posts_views(post_id);