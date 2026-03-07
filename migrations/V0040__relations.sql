-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 06. post relations - many-to-many relationship
-- =====================================================

create table relation_01_post_categories (
    post_id int8 not null references posts(id) on delete cascade,
    category_id int8 not null references config_dynamic_01_taxonomy_categories(id) on delete cascade,
    primary key (post_id, category_id)
);

create index idx_post_categories on relation_01_post_categories(category_id);


create table relation_02_post_tags (
    post_id int8 not null references posts(id) on delete cascade,
    tag_id int8 not null references config_dynamic_02_taxonomy_tags(id) on delete cascade,
    primary key (post_id, tag_id)
);

create index idx_post_tags on relation_02_post_tags(tag_id);


create table relation_03_post_media (
    post_id int8 not null references posts(id) on delete cascade,
    media_id int8 not null references media_catalog(id) on delete cascade,
    primary key (post_id, media_id)
);

create index idx_post_media on relation_03_post_media(media_id);