-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 03. taxonomies (categories and tags)
-- =====================================================

-- categories table (hierarchical)
create table "06_categories" (
    id bigint primary key,
    name varchar(100) not null,
    slug varchar(120) not null unique,
    description text,
    parent_id bigint references "06_categories"(id) on delete cascade,
    color varchar(7) default '#3b82f6',
    icon varchar(50),
    
    -- seo
    meta_title varchar(70),
    meta_description varchar(160),
    
    -- stats
    post_count integer default 0,
    
    -- display settings
    display_order integer not null default 0,
    is_visible boolean not null default true,
    
    -- metadata
    updated_at bigint,
    
    -- path for hierarchical queries
    path ltree -- postgresql ltree extension for hierarchical queries
);

create index idx_categories_slug on "06_categories"(slug);
create index idx_categories_parent_id on "06_categories"(parent_id);
create index idx_categories_path on "06_categories" using gist(path);

-- tags table
create table "07_tags" (
    id bigint primary key,
    name varchar(100) not null,
    slug varchar(120) not null unique,
    description text,
    
    -- seo
    meta_title varchar(70),
    meta_description varchar(160),
    
    -- stats
    post_count integer not null default 0,
    
    -- metadata
    updated_at bigint
);

create index idx_tags_slug on "07_tags"(slug);
create index idx_tags_name on "07_tags"(name);

-- many-to-many relationship
create table "08_post_categories" (
    post_id bigint not null references "05_posts"(id) on delete cascade,
    category_id bigint not null references "06_categories"(id) on delete cascade,
    primary key (post_id, category_id)
);

create index idx_post_categories_category on "08_post_categories"(category_id);

-- many-to-many relationship
create table "09_post_tags" (
    post_id bigint not null references "05_posts"(id) on delete cascade,
    tag_id bigint not null references "07_tags"(id) on delete cascade,
    primary key (post_id, tag_id)
);

create index idx_post_tags_tag on "09_post_tags"(tag_id);