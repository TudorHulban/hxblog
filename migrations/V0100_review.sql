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