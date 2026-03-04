-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 05. media library
-- =====================================================

create table if not exists "23_media_storage" (
    id int8 not null primary key,
    media bytea,
    size int8 NOT NULL,
    width INTEGER,
    height INTEGER,
    hash text
);

create or replace function get_media(
    in p_id int8
)
returns table 
(
    media bytea,
    size int8,
    hash text
)
as 
$$
begin
return query
select
	t.media, t.size, t.hash
from
	"23_media_storage" as t
where
	t.id = p_eventid;
end
$$ language plpgsql;


create table "24_media_catalog" (
    id int8 not null primary key,
    uploader_id int8 not null references "20_users"(id) on delete cascade,
    
    -- file info
    filename varchar(255) not null,
    slug varchar(255) not null unique,
    file_id int8 not null references "23_media_storage"(id),

    -- image specific
    width integer,
    height integer,
    aspect_ratio decimal(5,2) generated always as (
        case 
            when width > 0 and height > 0 then round(width::decimal / height, 2)
            else null
        end
    ) stored,
    alt_text varchar(500),
    caption text,
    description text,
    copyright varchar(255),
    credit varchar(255),
    
    -- thumbnails
    thumbnail_id int8 not null references "23_media_storage"(id),
    medium_id int8 not null references "23_media_storage"(id),
    large_id int8 not null references "23_media_storage"(id)
);

-- indexes for media
create index idx_media_uploader on "24_media_catalog"(uploader_id);
create index idx_media_slug on "24_media_catalog"(slug);
