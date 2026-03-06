-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 03. posts and content
-- =====================================================

create table if not exists posts (
    id int8 primary key,
    author_id int8 not null references users(id) on delete cascade,
    title varchar(500) not null,
    slug varchar(500) not null unique,
    excerpt text,
    content text not null,
    
    -- status and visibility
    status_id smallint not null references config_08_post_statuses(id),
    
    -- publishing
    scheduled_at int8,
    published_at int8,
    visible_until int8,
    
    -- featured image
    featured_image_id int8,
    
    -- seo
    meta_title varchar(70),         -- Title shown in search engines
    meta_description varchar(160),  -- Description shown in search engines
    meta_keywords text[],           -- Legacy SEO keywords (rarely used today)
    canonical_url varchar(500),     -- Preferred URL for search engines
    og_image varchar(500),          -- open graph tag, image used for social media link previews, ex. <meta property="og:image" content="https://example.com/og/my-page.jpg">
    
    -- settings
    allow_comments boolean default false,
    is_featured boolean default false,
    is_sticky boolean default false,
    password_hint varchar(255),
       
    -- metadata
    updated_at int8,
    deleted_at int8,
    
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
create index idx_posts_status on config_08_post_statuses(id);
create index idx_posts_published_at on posts(published_at);
create index idx_posts_featured on posts(is_featured) where is_featured = true;
create index idx_posts_sticky on posts(is_sticky) where is_sticky = true;
create index idx_posts_search on posts using gin(search_vector);


-- post revisions for version control
create table if not exists post_revisions (
    id int8 not null primary key,
    post_id int8 not null references posts(id) on delete cascade,
    revision_number integer not null,
    title varchar(500) not null,
    content text not null,
    excerpt text,
    created_by int8 references users(id),
    unique(post_id, revision_number)
);

create index idx_post_revisions_post_id on post_revisions(post_id);

