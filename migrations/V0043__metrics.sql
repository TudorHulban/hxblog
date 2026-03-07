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
    id          int8 not null,
    day_date    date not null,
    post_id     int8 not null references posts(id) on delete cascade,
    country_iso int2 not null,
    device_type int2,
    browser     int2,
    os          int2,
    zip_code    int2 not null
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
            'create table if not exists %I
             partition of metrics_03_posts_views
             for values from (%L) to (%L);',
            part_name,
            d + i,
            d + i + 1
        );
    end loop;
end;
$$;

-- call aggregate_posts_views_daily();
create table if not exists metrics_04_posts_views_aggregated (
    post_id int8 not null references posts(id) on delete cascade,
    date    date not null,

    views_by_country jsonb,
    views_by_device  jsonb,
    views_by_browser jsonb,
    views_by_os      jsonb,
    views_by_zip     jsonb
);

create index idx_metrics_posts_aggregated on metrics_04_posts_views_aggregated(post_id);

create or replace procedure aggregate_posts_views_daily()
language plpgsql
as $$
begin
    insert into metrics_04_posts_views_aggregated (
        post_id,
        date,
        views_by_country,
        views_by_device,
        views_by_browser,
        views_by_os,
        views_by_zip
    )
    select
        post_id,
        day_date,

        jsonb_object_agg(country_iso, country_count),
        jsonb_object_agg(device_type, device_count),
        jsonb_object_agg(browser, browser_count),
        jsonb_object_agg(os, os_count),
        jsonb_object_agg(zip_code, zip_count)

    from (
        select
            post_id,
            day_date,

            country_iso,
            device_type,
            browser,
            os,
            zip_code,

            count(*) as country_count,
            count(*) as device_count,
            count(*) as browser_count,
            count(*) as os_count,
            count(*) as zip_count

        from metrics_03_posts_views
        group by post_id, day_date, country_iso, device_type, browser, os, zip_code
    ) s
    group by post_id, day_date;

end;
$$;
