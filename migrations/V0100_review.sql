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