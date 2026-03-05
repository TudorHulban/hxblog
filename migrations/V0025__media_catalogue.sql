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
    filename varchar(255) not null,
    slug varchar(255) not null unique,
    alt_text varchar(500),
    caption text,
    description text,
    copyright varchar(255),
    credit varchar(255)
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
as 
$$
begin
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
$$ language plpgsql stable;

