-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 05. media library
-- =====================================================

create table if not exists media_catalog (
    id int8 not null primary key,
    uploader_id int8 not null references users(id) on delete cascade,
    
    -- file info
    filename text not null,
    slug text not null unique,
    alt_text text,
    caption text,
    description text,
    copyright text,
    credit text
);

-- indexes for media
create index idx_media_uploader on media_catalog(uploader_id);


create table if not exists media_storage (
    media_id int8 not null primary key references media_catalog(id) on delete cascade,

    media_full bytea,
    media_thumbnail bytea,
    media_medium bytea,

    -- info for full size
    size int8 not null default 0,
    width integer not null default 0,
    height integer not null default 0,
    hash text unique
);

alter table media_storage alter column media_full set storage external;
alter table media_storage alter column media_thumbnail set storage external;
alter table media_storage alter column media_medium set storage external;


create or replace procedure hx_insert_media(
    p_id             int8,
    p_uploader_id    int8,
    p_filename       text,
    p_slug           text,
    p_alt_text       text default null,
    p_caption        text default null,
    p_description    text default null,
    p_copyright      text default null,
    p_credit         text default null,

    p_media_full      bytea default null,
    p_media_thumbnail bytea default null,
    p_media_medium    bytea default null,
    p_size            int8 default 0,
    p_width           int default 0,
    p_height          int default 0,
    p_hash            text default null
)
language plpgsql
SECURITY DEFINER
as $$
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    -- Insert metadata
    insert into media_catalog (
        id,
        uploader_id,
        filename,
        slug,
        alt_text,
        caption,
        description,
        copyright,
        credit
    )
    values (
        p_id,
        p_uploader_id,
        p_filename,
        p_slug,
        p_alt_text,
        p_caption,
        p_description,
        p_copyright,
        p_credit
    );

    -- Insert binary storage
    insert into media_storage (
        media_id,
        media_full,
        media_thumbnail,
        media_medium,
        size,
        width,
        height,
        hash
    )
    values (
        p_id,
        p_media_full,
        p_media_thumbnail,
        p_media_medium,
        p_size,
        p_width,
        p_height,
        p_hash
    );
end;
$$;


create or replace function hx_get_media(
    in p_id int8
)
returns table 
(
    media_full      bytea,
    media_thumbnail bytea,
    media_medium    bytea,
    size            int8,
    width           integer,
    height          integer,
    hash            text
)
language plpgsql stable
SECURITY DEFINER
as 
$$
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    return query
    select
        t.media_full,
        t.media_thumbnail,
        t.media_medium,
        t.size,
        t.width,
        t.height,
        t.hash
    from
        media_storage as t
    where
        t.media_id = p_id;
end
$$;

