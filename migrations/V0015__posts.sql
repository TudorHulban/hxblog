-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 03. posts and content
-- =====================================================

-- enum types for posts
create type post_status as enum ('draft', 'published', 'scheduled', 'pending_review', 'trash');
create type post_format as enum ('standard', 'video', 'audio', 'gallery', 'link', 'quote');

-- posts table
create table posts (
    id bigint primary key,
    author_id bigint not null references users(id) on delete cascade,
    title varchar(500) not null,
    slug varchar(500) not null unique,
    excerpt text,
    content text not null,
    content_html text generated always as ( -- for search indexing
        regexp_replace(content, '<[^>]+>', '', 'g')
    ) stored,
    
    -- status and visibility
    status post_status not null default 'draft',
    format post_format default 'standard',
    visibility varchar(20) default 'public', -- 'public', 'private', 'password'
    password varchar(255), -- for password-protected posts
    
    -- publishing
    published_at bigint,
    scheduled_at bigint,
    
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
create index idx_posts_author_id on posts(author_id);
create index idx_posts_slug on posts(slug);
create index idx_posts_status on posts(status);
create index idx_posts_published_at on posts(published_at);
create index idx_posts_featured on posts(is_featured) where is_featured = true;
create index idx_posts_sticky on posts(is_sticky) where is_sticky = true;
create index idx_posts_search on posts using gin(search_vector);


-- post revisions for version control
create table post_revisions (
    id bigint not null primary key,
    post_id bigint not null references posts(id) on delete cascade,
    revision_number integer not null,
    title varchar(500) not null,
    content text not null,
    excerpt text,
    created_by bigint references users(id),
    unique(post_id, revision_number)
);

create index idx_post_revisions_post_id on post_revisions(post_id);