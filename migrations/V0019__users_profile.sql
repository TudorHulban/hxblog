-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 02. user (as author) profile and contributors
-- =====================================================

CREATE TABLE author_profile (
    author_id int8 primary key references users(id),
    
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
    
    -- Contributor settings
    contributor_since int8,
    is_featured_author BOOLEAN DEFAULT false,
    
    updated_at int8
);

CREATE INDEX idx_author_profiles_user ON author_profile(author_id);
CREATE INDEX idx_author_profiles_featured ON author_profile(is_featured_author) WHERE is_featured_author = true;


CREATE TABLE author_followers (
    author_id int8 NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    follower_id int8 NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at int8 NOT NULL,

    UNIQUE(author_id, follower_id)
);

CREATE INDEX idx_author_followers_author ON author_followers(author_id);
CREATE INDEX idx_author_followers_follower ON author_followers(follower_id);