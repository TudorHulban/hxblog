-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 06. post relations - many-to-many relationship
-- =====================================================

create table "32_relation_post_categories" (
    post_id int8 not null references "25_posts"(id) on delete cascade,
    category_id int8 not null references "10_taxonomy_categories"(id) on delete cascade,
    primary key (post_id, category_id)
);

create index idx_post_categories on "32_relation_post_categories"(category_id);


create table "33_relation_post_tags" (
    post_id int8 not null references "25_posts"(id) on delete cascade,
    tag_id int8 not null references "11_taxonomy_tags"(id) on delete cascade,
    primary key (post_id, tag_id)
);

create index idx_post_tags on "33_relation_post_tags"(tag_id);


create table "34_relation_post_media" (
    post_id int8 not null references "25_posts"(id) on delete cascade,
    media_id int8 not null references "23_media_catalog"(id) on delete cascade,
    primary key (post_id, media_id)
);

create index idx_post_media on "34_relation_post_media"(media_id);