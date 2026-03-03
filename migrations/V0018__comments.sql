-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 04. comments
-- =====================================================

-- Comments table
CREATE TABLE "30_comments" (
    id bigint PRIMARY KEY,
    post_id BIGINT NOT NULL REFERENCES "25_posts"(id) ON DELETE CASCADE,
    parent_id BIGINT REFERENCES "30_comments"(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES "20_users"(id) ON DELETE SET NULL,
    
    -- Commenter info (for guest comments)
    author_name VARCHAR(100),
    author_email VARCHAR(255),
    author_url VARCHAR(500),
    author_ip INET,
    
    -- Content
    content TEXT NOT NULL,
    content_html TEXT GENERATED ALWAYS AS (
        regexp_replace(content, '<[^>]+>', '', 'g')
    ) STORED,
    
    -- Status
    status_id smallint not null references "06_config_comment_statuses"(id),
    
    -- Engagement
    like_count INTEGER DEFAULT 0,
    dislike_count INTEGER DEFAULT 0,
    report_count INTEGER DEFAULT 0,
    
    -- Moderation
    moderation_reason TEXT,
    moderated_by BIGINT REFERENCES "20_users"(id),
    moderated_at BIGINT,
    
    -- Metadata
    updated_at bigint,
    deleted_at bigint
);

-- Indexes for comments
CREATE INDEX idx_comments_post_id ON "30_comments"(post_id);
CREATE INDEX idx_comments_user_id ON "30_comments"(user_id);
CREATE INDEX idx_comments_status ON "30_comments"(status_id);
CREATE INDEX idx_comments_parent_id ON "30_comments"(parent_id);