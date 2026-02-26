-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 02. users and authentication
-- =====================================================

-- enum types for user roles and status
-- todo: move to own tables
create type user_role as enum ('admin', 'editor', 'author', 'contributor', 'subscriber');
create type account_status as enum ('active', 'inactive', 'suspended', 'pending');

-- users table
create table users (
    id bigint not null primary key,
    email varchar(255) unique not null,
    username varchar(50) unique not null,
    password_hash varchar(255) not null,
    first_name varchar(100),
    last_name varchar(100),
    display_name varchar(150) generated always as (
        case 
            when first_name is not null and last_name is not null then first_name || ' ' || last_name
            when first_name is not null then first_name
            else username
        end
    ) stored,
    bio text,
    avatar_url varchar(500),
    role user_role not null default 'subscriber',
    status account_status not null default 'pending',
    
    -- email verification
    email_verified boolean default false,
    email_verified_at bigint,
    email_verification_token uuid,
    email_verification_sent_at bigint,
    
    -- security
    two_factor_enabled boolean default false,
    two_factor_secret varchar(255),
    backup_codes text[],
    
    -- password reset
    password_reset_token uuid,
    password_reset_expires_at bigint,
    
    -- session tracking
    last_login_at bigint,
    last_login_ip inet,
    login_counts_today integer default 0,
    
    -- metadata
    updated_at bigint,
    deleted_at bigint -- soft delete
);

-- indexes for users table
create index idx_users_email on users(email);
create index idx_users_username on users(username);
create index idx_users_role on users(role);
create index idx_users_status on users(status);
create index idx_users_deleted_at on users(deleted_at) where deleted_at is null;


-- user sessions table
create table user_sessions (
    id bigint primary key,
    user_id bigint not null references users(id) on delete cascade,
    session_token uuid not null unique,
    refresh_token uuid unique,
    ip_address inet,
    user_agent text,
    device_type varchar(50), -- 'desktop', 'mobile', 'tablet'
    browser varchar(100),
    os varchar(100),
    location_city varchar(100),
    location_country varchar(100),
    expires_at bigint not null,
    last_activity_at bigint not null,
    is_current boolean default false
);

create index idx_user_sessions_user_id on user_sessions(user_id);
create index idx_user_sessions_expires_at on user_sessions(expires_at);
create index idx_user_sessions_last_activity on user_sessions(last_activity_at);
