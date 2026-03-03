-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 01. configuration - account status
-- =====================================================

create table if not exists "04_config_user_statuses" (
    id smallserial primary key,
    status_name varchar(50) not null unique,
    description text
);

insert into "04_config_user_statuses" (status_name, description) values
    ('pending', 'Immediately after creation'),
    ('active', 'Requires email verification'),
    ('suspended', 'Manual suspension'),
    ('inactive', 'Soft deletion')
on conflict (status_name) do nothing;
