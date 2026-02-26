-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 02. users and authentication
-- All timestamps stored as unix epoch milliseconds (UTC).
-- =====================================================

-- enum types for user roles and status
-- todo: move to own tables
create type user_role as enum ('admin', 'editor', 'author', 'contributor', 'subscriber');
create type account_status as enum ('active', 'inactive', 'suspended', 'pending');

-- users table
create table if not exists "03_users" (
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
    email_verified boolean not null default false,
    email_verified_at bigint,
    email_verification_token uuid,
    email_verification_sent_at bigint,
    
    -- security
    two_factor_enabled boolean not null default false,
    two_factor_secret varchar(255),
    backup_codes text[],
    
    -- password reset
    password_reset_token uuid,
    password_reset_expires_at bigint,
    
    -- session tracking
    last_login_at bigint,
    last_login_ip inet,
    login_counts_today integer not null default 0,
    
    -- metadata
    updated_at bigint,
    deleted_at bigint -- soft delete
);

-- indexes for users table
create index idx_users_role on "03_users"(role);
create index idx_users_status on "03_users"(status);
create index idx_users_not_deleted on "03_users"(id) where deleted_at is null;
create unique index idx_users_email_verification_token on "03_users"(email_verification_token) where email_verification_token is not null;
create unique index idx_users_password_reset_token on "03_users"(password_reset_token) where password_reset_token is not null;

alter table "03_users" add constraint chk_users_login_counts_today_non_negative check (login_counts_today >= 0);
alter table "03_users" add constraint chk_users_email_verified_consistency check (
    email_verified = false
    or (email_verified = true and email_verified_at is not null)
);

-- user sessions table
create table if not exists "04_user_sessions" (
    id bigint primary key,
    user_id bigint not null references "03_users"(id) on delete cascade,
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
    is_current boolean not null default false
);

create index idx_user_sessions_user_id on "04_user_sessions"(user_id);
create index idx_user_sessions_expires_at on "04_user_sessions"(expires_at);
create index idx_user_sessions_last_activity on "04_user_sessions"(last_activity_at);
create index idx_user_sessions_user_current on "04_user_sessions"(user_id, is_current);
create unique index idx_user_sessions_one_current on "04_user_sessions"(user_id) where is_current = true;

alter table "04_user_sessions" add constraint chk_user_sessions_device_type
check (
    device_type in ('desktop','mobile','tablet')
    or device_type is null
);
