-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 04. comments
-- =====================================================

create table post_comments (
    id int8 primary key,
    post_id int8 not null references posts(id) on delete cascade,
    parent_id int8 references post_comments(id) on delete cascade,
    user_id int8 references users(id) on delete set null,
    
    -- commenter info (for guest comments)
    author_name text,
    author_email citext,
    author_url text,
    author_ip inet,
    
    -- content
    content text not null,
    
    -- status
    status_id smallint not null default 1 references config_09_comment_statuses(id),
    
    -- moderation
    moderation_reason text,
    moderated_by int8 references users(id),
    moderated_at int8,
    
    -- metadata
    updated_at int8 default null,
    deleted_at int8 default null
);

-- indexes for comments
create index idx_comments_post_id on post_comments(post_id);
create index idx_comments_user_id on post_comments(user_id);
create index idx_comments_status on post_comments(status_id);
create index idx_comments_parent_id on post_comments(parent_id);


create table if not exists post_comments_votes (
    comment_id int8 primary key references post_comments(id),
    votes_report integer default 0,
    votes_dislike integer default 0,
    votes_like integer default 0 -- most hit column last
);