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
    id          bigint not null primary key,
    post_id     bigint not null references posts(id) on delete cascade,
    country_iso int2 not null,
    device_type int2,
    browser     int2,
    os          int2,
    zip_code    int2 not null,

    -- convert epoch → date for partitioning
    day_date    date generated always as (to_timestamp(id)::date) stored
)
partition by range (day_date);

create index idx_posts_views_post_id on metrics_03_posts_views(post_id);


-- call it by select create_post_views_partitions(30);
create or replace function create_post_views_partitions(days_ahead int)
returns void
language plpgsql
as $$
declare
    d date := current_date;
    i int;
    part_name text;
begin
    for i in 0..days_ahead loop
        part_name := 'metrics_03_posts_views_' || to_char(d + i, 'yyyymmdd');

        execute format(
            'create table if not exists %i
             partition of metrics_03_posts_views
             for values from (%l) to (%l);',
            part_name,
            d + i,
            d + i + 1
        );
    end loop;
end;
$$;
