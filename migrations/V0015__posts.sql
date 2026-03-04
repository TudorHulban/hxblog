-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 03. posts and content
-- =====================================================

create table if not exists "25_posts" (
    id bigint primary key,
    author_id bigint not null references "20_users"(id) on delete cascade,
    title varchar(500) not null,
    slug varchar(500) not null unique,
    excerpt text,
    content text not null,
    content_html text generated always as ( -- for search indexing
        regexp_replace(content, '<[^>]+>', '', 'g')
    ) stored,
    
    -- status and visibility
    status_id smallint not null references "05_config_post_statuses"(id),
    
    -- publishing
    scheduled_at bigint,
    published_at bigint,
    published_to bigint,
    
    -- featured image
    featured_image_id bigint,
    
    -- seo
    meta_title varchar(70),
    meta_description varchar(160),
    meta_keywords text[],
    canonical_url varchar(500),
    og_image varchar(500),
    
    -- settings
    allow_comments boolean default false,
    is_featured boolean default false,
    is_sticky boolean default false,
    password_hint varchar(255),
    
    -- stats
    view_count integer default 0,
    comment_count integer default 0,
    like_count integer default 0,
    share_count integer default 0,
    
    -- metadata
    updated_at bigint,
    deleted_at bigint,
    
    -- full text search vector
    search_vector tsvector generated always as (
        setweight(to_tsvector('english', coalesce(title, '')), 'a') ||
        setweight(to_tsvector('english', coalesce(excerpt, '')), 'b') ||
        setweight(to_tsvector('english', coalesce(content, '')), 'c')
    ) stored
);

-- indexes for posts table
create index idx_posts_author_id on "25_posts"(author_id);
create index idx_posts_slug on "25_posts"(slug);
create index idx_posts_status on "05_config_post_statuses"(id);
create index idx_posts_published_at on "25_posts"(published_at);
create index idx_posts_featured on "25_posts"(is_featured) where is_featured = true;
create index idx_posts_sticky on "25_posts"(is_sticky) where is_sticky = true;
create index idx_posts_search on "25_posts" using gin(search_vector);


-- post revisions for version control
create table if not exists "26_post_revisions" (
    id bigint not null primary key,
    post_id bigint not null references "25_posts"(id) on delete cascade,
    revision_number integer not null,
    title varchar(500) not null,
    content text not null,
    excerpt text,
    created_by bigint references "20_users"(id),
    unique(post_id, revision_number)
);

create index idx_post_revisions_post_id on "26_post_revisions"(post_id);

