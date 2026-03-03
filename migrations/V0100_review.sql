-- =====================================================
-- 5. MEDIA LIBRARY
-- =====================================================

-- Enum for file types
CREATE TYPE file_type AS ENUM ('image', 'document', 'audio', 'video', 'archive', 'other');

-- Media table
CREATE TABLE media (
    id BIGSERIAL PRIMARY KEY,
    uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
    uploader_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- File info
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    file_path VARCHAR(500) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_type file_type NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL, -- in bytes
    file_hash VARCHAR(64), -- SHA-256 hash
    
    -- Image specific
    width INTEGER,
    height INTEGER,
    aspect_ratio DECIMAL(5,2) GENERATED ALWAYS AS (
        CASE 
            WHEN width > 0 AND height > 0 THEN ROUND(width::DECIMAL / height, 2)
            ELSE NULL
        END
    ) STORED,
    alt_text VARCHAR(500),
    caption TEXT,
    description TEXT,
    copyright VARCHAR(255),
    credit VARCHAR(255),
    
    -- Thumbnails
    thumbnail_url VARCHAR(500),
    thumbnail_width INTEGER,
    thumbnail_height INTEGER,
    medium_url VARCHAR(500),
    medium_width INTEGER,
    medium_height INTEGER,
    large_url VARCHAR(500),
    large_width INTEGER,
    large_height INTEGER,
    
    -- Stats
    download_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    
    -- Folder structure
    folder_path LTREE,
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Indexes for media
CREATE INDEX idx_media_uploader ON media(uploader_id);
CREATE INDEX idx_media_file_type ON media(file_type);
CREATE INDEX idx_media_slug ON media(slug);
CREATE INDEX idx_media_created_at ON media(created_at);
CREATE INDEX idx_media_folder_path ON media USING GIST(folder_path);

-- Media usage tracking (where files are used)
CREATE TABLE media_usage (
    id BIGSERIAL PRIMARY KEY,
    media_id BIGINT NOT NULL REFERENCES media(id) ON DELETE CASCADE,
    post_id BIGINT REFERENCES posts(id) ON DELETE CASCADE,
    comment_id BIGINT REFERENCES comments(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    usage_type VARCHAR(50) NOT NULL, -- 'featured', 'content', 'avatar', 'gallery'
    usage_context TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_media_usage_media ON media_usage(media_id);
CREATE INDEX idx_media_usage_post ON media_usage(post_id);

-- =====================================================
-- 6. AUTHORS & CONTRIBUTORS
-- =====================================================

-- Author profiles (extends users)
CREATE TABLE author_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    -- Professional info
    job_title VARCHAR(200),
    company VARCHAR(200),
    location VARCHAR(200),
    expertise TEXT[], -- Array of expertise areas
    
    -- Social links
    twitter_url VARCHAR(500),
    github_url VARCHAR(500),
    linkedin_url VARCHAR(500),
    website_url VARCHAR(500),
    youtube_url VARCHAR(500),
    
    -- Stats
    total_posts INTEGER DEFAULT 0,
    total_views BIGINT DEFAULT 0,
    total_comments INTEGER DEFAULT 0,
    follower_count INTEGER DEFAULT 0,
    
    -- Contributor settings
    contributor_since DATE NOT NULL DEFAULT CURRENT_DATE,
    is_featured_author BOOLEAN DEFAULT false,
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_author_profiles_user ON author_profiles(user_id);
CREATE INDEX idx_author_profiles_featured ON author_profiles(is_featured_author) WHERE is_featured_author = true;

-- Author followers
CREATE TABLE author_followers (
    id BIGSERIAL PRIMARY KEY,
    author_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    follower_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(author_id, follower_id)
);

CREATE INDEX idx_author_followers_author ON author_followers(author_id);
CREATE INDEX idx_author_followers_follower ON author_followers(follower_id);

-- =====================================================
-- 7. ANALYTICS & STATS
-- =====================================================

-- Page views tracking
CREATE TABLE page_views (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT REFERENCES posts(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    
    -- Request info
    ip_address INET,
    user_agent TEXT,
    referer_url VARCHAR(500),
    session_id UUID,
    
    -- Location (from IP)
    country VARCHAR(100),
    city VARCHAR(100),
    
    -- Device info
    device_type VARCHAR(50),
    browser VARCHAR(100),
    os VARCHAR(100),
    
    -- Timing
    time_on_page INTEGER, -- seconds
    scroll_depth INTEGER, -- percentage
    
    -- Metadata
    viewed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_page_views_post ON page_views(post_id);
CREATE INDEX idx_page_views_viewed_at ON page_views(viewed_at);
CREATE INDEX idx_page_views_country ON page_views(country);

-- Daily post stats aggregation
CREATE TABLE daily_post_stats (
    id BIGSERIAL PRIMARY KEY,
    post_id BIGINT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    views INTEGER DEFAULT 0,
    unique_visitors INTEGER DEFAULT 0,
    comments INTEGER DEFAULT 0,
    likes INTEGER DEFAULT 0,
    shares INTEGER DEFAULT 0,
    avg_time_on_page INTEGER,
    bounce_rate DECIMAL(5,2),
    UNIQUE(post_id, date)
);

CREATE INDEX idx_daily_stats_post ON daily_post_stats(post_id);
CREATE INDEX idx_daily_stats_date ON daily_post_stats(date);

-- =====================================================
-- 8. NEWSLETTER & SUBSCRIPTIONS
-- =====================================================

-- Newsletter subscribers
CREATE TABLE newsletter_subscribers (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    
    -- Subscription details
    status VARCHAR(50) NOT NULL DEFAULT 'active', -- 'active', 'unsubscribed', 'bounced'
    subscribed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    unsubscribed_at TIMESTAMPTZ,
    unsubscribe_token UUID UNIQUE,
    
    -- Preferences
    frequency VARCHAR(20) DEFAULT 'weekly', -- 'daily', 'weekly', 'monthly'
    categories INTEGER[], -- Array of category IDs to follow
    
    -- Source
    source VARCHAR(50), -- 'footer', 'popup', 'sidebar', 'registration'
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_newsletter_email ON newsletter_subscribers(email);
CREATE INDEX idx_newsletter_status ON newsletter_subscribers(status);

-- Newsletter campaigns
CREATE TABLE newsletter_campaigns (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    
    -- Targeting
    target_categories INTEGER[],
    target_status VARCHAR(50) DEFAULT 'active',
    
    -- Schedule
    scheduled_at TIMESTAMPTZ,
    sent_at TIMESTAMPTZ,
    
    -- Stats
    recipient_count INTEGER DEFAULT 0,
    open_count INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,
    bounce_count INTEGER DEFAULT 0,
    unsubscribe_count INTEGER DEFAULT 0,
    
    -- Metadata
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- 9. AUDIT & LOGS
-- =====================================================

-- Audit log table
CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    
    -- Action details
    action VARCHAR(100) NOT NULL, -- 'create', 'update', 'delete', 'login', 'export'
    entity_type VARCHAR(50) NOT NULL, -- 'post', 'comment', 'user', 'media'
    entity_id BIGINT,
    old_values JSONB,
    new_values JSONB,
    
    -- Request info
    ip_address INET,
    user_agent TEXT,
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);

-- =====================================================
-- 10. SETTINGS & CONFIGURATION
-- =====================================================

-- Blog settings table
CREATE TABLE settings (
    id BIGSERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type VARCHAR(20) DEFAULT 'string', -- 'string', 'integer', 'boolean', 'json'
    description TEXT,
    group_name VARCHAR(100),
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_settings_key ON settings(setting_key);
CREATE INDEX idx_settings_group ON settings(group_name);

-- Insert default settings
INSERT INTO settings (setting_key, setting_value, setting_type, description, group_name, is_public) VALUES
    ('blog_title', 'DevBlog', 'string', 'Blog title', 'general', true),
    ('blog_description', 'A community for developers', 'string', 'Blog description', 'general', true),
    ('posts_per_page', '10', 'integer', 'Posts per page', 'reading', false),
    ('allow_comments', 'true', 'boolean', 'Allow comments globally', 'discussion', false),
    ('comment_moderation', 'true', 'boolean', 'Require comment moderation', 'discussion', false),
    ('timezone', 'UTC', 'string', 'Default timezone', 'regional', false),
    ('date_format', 'F j, Y', 'string', 'Date format', 'regional', false),
    ('maintenance_mode', 'false', 'boolean', 'Maintenance mode', 'system', false),
    ('maintenance_message', 'Site under maintenance', 'string', 'Maintenance message', 'system', false);

-- =====================================================
-- 11. FUNCTIONS & TRIGGERS
-- =====================================================

-- Update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply timestamp triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_media_updated_at BEFORE UPDATE ON media
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update post comment count
CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.status = 'approved' THEN
        UPDATE posts SET comment_count = comment_count + 1 WHERE id = NEW.post_id;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.status != 'approved' AND NEW.status = 'approved' THEN
            UPDATE posts SET comment_count = comment_count + 1 WHERE id = NEW.post_id;
        ELSIF OLD.status = 'approved' AND NEW.status != 'approved' THEN
            UPDATE posts SET comment_count = comment_count - 1 WHERE id = NEW.post_id;
        END IF;
    ELSIF TG_OP = 'DELETE' AND OLD.status = 'approved' THEN
        UPDATE posts SET comment_count = comment_count - 1 WHERE id = OLD.post_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_post_comment_count
    AFTER INSERT OR UPDATE OR DELETE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_post_comment_count();

-- Update category/tag post counts
CREATE OR REPLACE FUNCTION update_category_post_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE categories SET post_count = post_count + 1 WHERE id = NEW.category_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE categories SET post_count = post_count - 1 WHERE id = OLD.category_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_category_count
    AFTER INSERT OR DELETE ON post_categories
    FOR EACH ROW EXECUTE FUNCTION update_category_post_count();

CREATE OR REPLACE FUNCTION update_tag_post_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE tags SET post_count = post_count + 1 WHERE id = NEW.tag_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE tags SET post_count = post_count - 1 WHERE id = OLD.tag_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_tag_count
    AFTER INSERT OR DELETE ON post_tags
    FOR EACH ROW EXECUTE FUNCTION update_tag_post_count();

-- =====================================================
-- 12. VIEWS FOR COMMON QUERIES
-- =====================================================

-- Published posts view
CREATE VIEW published_posts AS
SELECT 
    p.*,
    u.display_name as author_name,
    u.avatar_url as author_avatar,
    COALESCE(
        (SELECT json_agg(json_build_object('id', c.id, 'name', c.name, 'slug', c.slug))
         FROM post_categories pc
         JOIN categories c ON pc.category_id = c.id
         WHERE pc.post_id = p.id),
        '[]'::json
    ) as categories,
    COALESCE(
        (SELECT json_agg(json_build_object('id', t.id, 'name', t.name, 'slug', t.slug))
         FROM post_tags pt
         JOIN tags t ON pt.tag_id = t.id
         WHERE pt.post_id = p.id),
        '[]'::json
    ) as tags
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.status = 'published' AND p.deleted_at IS NULL;

-- Popular posts view (last 30 days)
CREATE VIEW popular_posts AS
SELECT 
    p.*,
    COALESCE(dps.views, 0) as views_30d,
    COALESCE(dps.unique_visitors, 0) as visitors_30d
FROM posts p
LEFT JOIN (
    SELECT post_id, SUM(views) as views, SUM(unique_visitors) as unique_visitors
    FROM daily_post_stats
    WHERE date > NOW() - INTERVAL '30 days'
    GROUP BY post_id
) dps ON p.id = dps.post_id
WHERE p.status = 'published' AND p.deleted_at IS NULL
ORDER BY views_30d DESC NULLS LAST;

-- =====================================================
-- 13. GRANTS & PERMISSIONS
-- =====================================================

-- Create application user
CREATE USER devblog_app WITH PASSWORD 'secure_password_here';
GRANT CONNECT ON DATABASE devblog TO devblog_app;
GRANT USAGE ON SCHEMA public TO devblog_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO devblog_app;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO devblog_app;

-- Create read-only user for reporting
CREATE USER devblog_readonly WITH PASSWORD 'readonly_password_here';
GRANT CONNECT ON DATABASE devblog TO devblog_readonly;
GRANT USAGE ON SCHEMA public TO devblog_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO devblog_readonly;
GRANT SELECT ON ALL VIEWS IN SCHEMA public TO devblog_readonly;

-- =====================================================
-- NOTES
-- =====================================================
/*
1. Run extensions first: CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
2. Run ltree extension for hierarchical categories: CREATE EXTENSION IF NOT EXISTS "ltree";
3. Adjust sequence starts based on existing data
4. Update passwords for application users
5. Consider partitioning for large tables (page_views, audit_logs)
6. Set up regular VACUUM and ANALYZE schedules
7. Configure appropriate backup strategies
*/