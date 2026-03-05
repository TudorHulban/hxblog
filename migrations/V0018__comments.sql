-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 04. comments
-- =====================================================

create table post_comments (
    id bigint primary key,
    post_id bigint not null references posts(id) on delete cascade,
    parent_id bigint references post_comments(id) on delete cascade,
    user_id bigint references users(id) on delete set null,
    
    -- commenter info (for guest comments)
    author_name varchar(100),
    author_email varchar(255),
    author_url varchar(500),
    author_ip inet,
    
    -- content
    content text not null,
    
    -- status
    status_id smallint not null default 1 references config_09_comment_statuses(id),
    
    -- engagement
    like_count integer default 0,
    dislike_count integer default 0,
    report_count integer default 0,
    
    -- moderation
    moderation_reason text,
    moderated_by bigint references users(id),
    moderated_at bigint,
    
    -- metadata
    updated_at bigint default null,
    deleted_at bigint default null
);

-- indexes for comments
create index idx_comments_post_id on post_comments(post_id);
create index idx_comments_user_id on post_comments(user_id);
create index idx_comments_status on post_comments(status_id);
create index idx_comments_parent_id on post_comments(parent_id);