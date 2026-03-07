-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 03. taxonomies (categories and tags)
-- =====================================================

-- categories table (hierarchical) - “What is this post generally about?”
create table config_dynamic_01_taxonomy_categories (
    id int8 primary key,
    name text not null,
    slug text not null unique,
    description text,
    parent_id int8 references config_dynamic_01_taxonomy_categories(id) on delete cascade,
    color varchar(7) default '#3b82f6',
    icon text,
    
    -- seo
    meta_title text,
    meta_description text,
    
    -- stats
    post_count integer default 0,
    
    -- display settings
    display_order integer not null default 0,
    is_visible boolean not null default true,
    
    -- metadata
    updated_at int8,
    
    -- path for hierarchical queries
    path ltree -- postgresql ltree extension for hierarchical queries
);

create index idx_categories_slug on config_dynamic_01_taxonomy_categories(slug);
create index idx_categories_parent_id on config_dynamic_01_taxonomy_categories(parent_id);
create index idx_categories_path on config_dynamic_01_taxonomy_categories using gist(path);

-- tags table - “What topics, tools, or ideas appear in this post?”
create table config_dynamic_02_taxonomy_tags (
    id int8 primary key,
    name text not null,
    slug text not null unique,
    description text,
    
    -- seo
    meta_title text,
    meta_description text,
    
    -- stats
    post_count integer not null default 0,
    
    -- metadata
    updated_at int8
);

create index idx_tags_slug on config_dynamic_02_taxonomy_tags(slug);
create index idx_tags_name on config_dynamic_02_taxonomy_tags(name);

