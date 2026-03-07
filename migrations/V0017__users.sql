-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 02. users and authentication
-- All timestamps stored as unix epoch milliseconds (UTC).
-- =====================================================

-- GDPR info:

-- Legitimate Interest (Article 6(1)(f)): 
-- Storing login times is necessary for security (detecting unauthorized access) 
-- and system administration (identifying inactive accounts).
-- You have a right to protect your server from DDoS attacks, SQL injection, 
-- and unauthorized access. Tracking IPs is necessary for this.

create table if not exists users (
    id int8 not null primary key,
    email citext unique not null,
    username text unique not null,
    password_hash text not null, -- initial password sent by email
    first_name text,
    last_name text,
    display_name text generated always as (
        case 
            when first_name is not null and last_name is not null then first_name || ' ' || last_name
            when first_name is not null then first_name
            else username
        end
    ) stored,
    bio text,
    avatar_url text,
    role_id smallint not null references  config_06_user_roles(id) on delete restrict,
    status_id smallint not null references config_07_user_statuses(id) on delete restrict,
    
    -- email verification
    email_verified boolean not null default false,
    email_verified_at int8,
    email_verification_token uuid,
    email_verification_sent_at int8,
    
    -- security
    two_factor_enabled boolean not null default false,
    two_factor_secret text,
    
    -- password reset
    password_reset_token uuid,
    password_reset_expires_at int8,
    
    -- session tracking, see GDPR note above
    last_login_at int8,
    last_login_ip inet,
    login_counts_today integer not null default 0,
    
    -- metadata
    updated_at int8,
    deleted_at int8 -- soft delete
);

-- indexes for users table
create index idx_users_role on users(role_id);
create index idx_users_status on users(status_id);
create index idx_users_not_deleted on users(id) where deleted_at is null;
create unique index idx_users_email_verification_token on users(email_verification_token) where email_verification_token is not null;
create unique index idx_users_password_reset_token on users(password_reset_token) where password_reset_token is not null;

alter table users add constraint chk_users_login_counts_today_non_negative check (login_counts_today >= 0);
alter table users add constraint chk_users_email_verified_consistency check (
    email_verified = false
    or (email_verified = true and email_verified_at is not null)
);


create table if not exists user_sessions (
    id int8 primary key,
    user_id int8 not null references users(id) on delete cascade,
    session_token uuid not null unique,
    refresh_token uuid unique,
    ip_address inet,
    user_agent text,
    device_type int2 references config_03_device_types(id),
    browser int2 references config_05_browsers(id),
    os int2 references config_04_operating_systems(id),
    location_city text,
    location_country text,
    expires_at int8 not null,
    last_activity_at int8 not null,
    is_current boolean not null default false
);

create index idx_user_sessions_user_id on user_sessions(user_id);
create index idx_user_sessions_expires_at on user_sessions(expires_at);
create index idx_user_sessions_last_activity on user_sessions(last_activity_at);
create index idx_user_sessions_user_current on user_sessions(user_id, is_current);
create unique index idx_user_sessions_one_current on user_sessions(user_id) where is_current = true;
