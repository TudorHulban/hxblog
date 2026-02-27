-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 03. taxonomies (categories and tags)
-- =====================================================

-- categories table (hierarchical) - “What is this post generally about?”
create table "06_taxonomy_categories" (
    id bigint primary key,
    name varchar(100) not null,
    slug varchar(120) not null unique,
    description text,
    parent_id bigint references "06_taxonomy_categories"(id) on delete cascade,
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

create index idx_categories_slug on "06_taxonomy_categories"(slug);
create index idx_categories_parent_id on "06_taxonomy_categories"(parent_id);
create index idx_categories_path on "06_taxonomy_categories" using gist(path);

-- tags table - “What topics, tools, or ideas appear in this post?”
create table "07_taxonomy_tags" (
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

create index idx_tags_slug on "07_taxonomy_tags"(slug);
create index idx_tags_name on "07_taxonomy_tags"(name);

